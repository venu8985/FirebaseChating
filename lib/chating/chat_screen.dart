import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String recieverName;

  ChatScreen({required this.roomId, required this.recieverName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _currentUserId;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isSendingImage = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markMessagesAsSeen();
      _scrollToBottom();
    });
  }

  Future<void> _markMessagesAsSeen() async {
    try {
      final messages = await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.roomId)
          .collection('messages')
          .where('senderId', isNotEqualTo: _currentUserId)
          .where('status', isEqualTo: 'sent')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var message in messages.docs) {
        batch.update(message.reference, {
          'status': 'seen',
          'statusTimestamp': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      print('Error updating message status to seen: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.1),
        title: Text(widget.recieverName.toString()),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () => _clearAllChats(context),
          ),
        ],
      ),
      body: _selectedImage == null
          ? Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chatRooms')
                        .doc(widget.roomId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!.docs;

                      // Group messages by date
                      final groupedMessages = _groupMessagesByDate(messages);

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true, // Ensure new messages are at the bottom
                        itemCount: groupedMessages.length,
                        itemBuilder: (context, index) {
                          final date = groupedMessages.keys.elementAt(index);
                          final messages = groupedMessages[date]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Center(
                                  child: Text(
                                    _formatDate(date),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                              ...messages.map((message) {
                                final data =
                                    message.data() as Map<String, dynamic>;
                                final isSender =
                                    data['senderId'] == _currentUserId;
                                final imageUrl = data['imageUrl'] as String?;
                                final text = data['text'] as String?;
                                final isDeleted = data['deleted'] ?? false;
                                final status = data['status'] ?? 'loading';
                                final statusTimestamp =
                                    data['timestamp'] as Timestamp?;
                                final recieverStatusTimestamp =
                                    data['statusTimestamp'] as Timestamp?;

                                return GestureDetector(
                                  onLongPress: () => _showDeleteOptions(
                                      context, message.id, isSender),
                                  child: Align(
                                    alignment: isSender
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isDeleted
                                            ? Colors.red[100]
                                            : isSender
                                                ? Colors.blueAccent
                                                : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: isSender
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          if (isDeleted)
                                            Text(
                                              'This message was deleted',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          if (!isDeleted && imageUrl != null)
                                            Stack(
                                              children: [
                                                Image.network(
                                                  imageUrl,
                                                  width: 200,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Text(
                                                        'Failed to load image');
                                                  },
                                                ),
                                                if (status == 'loading')
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                if (status == 'sent')
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: Icon(
                                                      Icons.check,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                if (status == 'seen')
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 10,
                                                    child: Icon(
                                                      Icons.done_all,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          if (!isDeleted &&
                                              text != null &&
                                              text.isNotEmpty)
                                            Text(
                                              text,
                                              style: TextStyle(
                                                color: isSender
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                          if (isSender == true)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (statusTimestamp != null)
                                                  Text(
                                                    '${statusTimestamp.toDate().hour}:${statusTimestamp.toDate().minute}',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                if (status == 'loading')
                                                  SizedBox(
                                                    width: 10,
                                                    height: 10,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                if (status == 'sent')
                                                  Icon(
                                                    Icons.check,
                                                    color: Colors.black,
                                                    size: 10,
                                                  ),
                                                if (status == 'seen')
                                                  Icon(
                                                    Icons.done_all,
                                                    color: Colors.black,
                                                    size: 10,
                                                  ),
                                              ],
                                            ),
                                          if (isSender != true)
                                            if (recieverStatusTimestamp != null)
                                              Text(
                                                '${recieverStatusTimestamp.toDate().hour}:${recieverStatusTimestamp.toDate().minute}',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10,
                                                ),
                                              ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.photo),
                        onPressed: _pickImage,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Enter your message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.white, size: 30),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.black54,
                            hintText: 'Enter your message',
                            hintStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      _isSendingImage
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : IconButton(
                              icon: Icon(Icons.send,
                                  color: Colors.white, size: 30),
                              onPressed: _sendMessage,
                            ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Map<DateTime, List<QueryDocumentSnapshot>> _groupMessagesByDate(
      List<QueryDocumentSnapshot> messages) {
    final groupedMessages = <DateTime, List<QueryDocumentSnapshot>>{};
    final now = DateTime.now();

    // Sort messages by timestamp in ascending order
    messages.sort((a, b) {
      final timestampA =
          (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp;
      final timestampB =
          (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp;
      return timestampA.compareTo(timestampB);
    });

    for (var message in messages) {
      final timestamp =
          (message.data() as Map<String, dynamic>)['timestamp'] as Timestamp;
      final messageDate = timestamp.toDate();
      final startOfDay =
          DateTime(messageDate.year, messageDate.month, messageDate.day);

      // Group messages by date
      groupedMessages.putIfAbsent(startOfDay, () => []).add(message);
    }

    return groupedMessages;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final startOfDay = DateTime(date.year, date.month, date.day);

    if (now.isSameDay(startOfDay)) {
      return 'Today';
    } else if (now.subtract(Duration(days: 1)).isSameDay(startOfDay)) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateMessageStatus(String messageId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.roomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'status': status,
        'statusTimestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating message status: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedImage == null)
      return;

    try {
      if (_selectedImage != null) {
        setState(() {
          _isSendingImage = true;
        });

        final imageUrl = await _uploadImage();
        final docRef = await FirebaseFirestore.instance
            .collection('chatRooms')
            .doc(widget.roomId)
            .collection('messages')
            .add({
          'senderId': _currentUserId,
          'imageUrl': imageUrl,
          'text': _messageController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'loading',
          'deleted': false,
        });

        setState(() {
          _selectedImage = null;
          _isSendingImage = false;
        });

        await _updateMessageStatus(docRef.id, 'sent');
      } else {
        await FirebaseFirestore.instance
            .collection('chatRooms')
            .doc(widget.roomId)
            .collection('messages')
            .add({
          'senderId': _currentUserId,
          'text': _messageController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'sent',
          'deleted': false,
        });
      }

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<String> _uploadImage() async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child('$fileName.jpg');

      await ref.putFile(_selectedImage!);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  void _clearAllChats(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Chats'),
        content: Text('Are you sure you want to clear all chats?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Clear'),
          ),
        ],
      ),
    );

    if (result) {
      try {
        final batch = FirebaseFirestore.instance.batch();
        final messages = await FirebaseFirestore.instance
            .collection('chatRooms')
            .doc(widget.roomId)
            .collection('messages')
            .get();

        for (var message in messages.docs) {
          batch.delete(message.reference);
        }

        await batch.commit();
      } catch (e) {
        print('Error clearing chats: $e');
      }
    }
  }

  void _showDeleteOptions(
      BuildContext context, String messageId, bool isSender) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Message'),
        content: Text('Do you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('chatRooms')
                  .doc(widget.roomId)
                  .collection('messages')
                  .doc(messageId)
                  .update({'deleted': true});
              Navigator.pop(context);
            },
            child: Text('Delete for me only'),
          ),
          if (isSender)
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('chatRooms')
                    .doc(widget.roomId)
                    .collection('messages')
                    .doc(messageId)
                    .delete();
                Navigator.pop(context);
              },
              child: Text('Delete for both'),
            ),
        ],
      ),
    );
  }
}

extension DateTimeComparison on DateTime {
  bool isSameDay(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}
