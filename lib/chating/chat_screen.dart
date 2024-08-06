import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final String roomId;

  ChatScreen({required this.roomId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _currentUserId;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _imageUrl;
  bool _isSendingImage = false; // Track if sending image

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
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

                    return messages.isNotEmpty
                        ? ListView.builder(
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index].data()
                                  as Map<String, dynamic>;
                              final isSender =
                                  message['senderId'] == _currentUserId;
                              final imageUrl = message.containsKey('imageUrl')
                                  ? message['imageUrl']
                                  : null;
                              final text = message.containsKey('text')
                                  ? message['text']
                                  : '';
                              final isDeleted = message.containsKey('deleted')
                                  ? message['deleted']
                                  : false;
                              final status = message.containsKey('status')
                                  ? message['status']
                                  : 'loading'; // Default status

                              return GestureDetector(
                                onLongPress: () => _showDeleteOptions(
                                    context, messages[index].id, isSender),
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
                                                  right: 0,
                                                  child: Icon(
                                                    Icons.done_all,
                                                    color: Colors.blue,
                                                    size: 20,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        if (!isDeleted && text.isNotEmpty)
                                          Text(
                                            text,
                                            style: TextStyle(
                                              color: isSender
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text('The chats are empty'),
                          );
                  },
                )),
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
                      _isSendingImage == true
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

  void _updateMessageStatus(String messageId, String status) async {
    await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(widget.roomId)
        .collection('messages')
        .doc(messageId)
        .update({
      'status': status,
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedImage == null)
      return;

    // If an image is selected
    if (_selectedImage != null) {
      // Show the image in the chat immediately
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
        'status': 'loading', // Initial status
        'deleted': false,
      });

      setState(() {
        _selectedImage = null;
      });

      // Update status to 'sent' after image upload
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.roomId)
          .collection('messages')
          .doc(docRef.id)
          .update({'status': 'sent'});
    } else {
      // Send a text message
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
  }

  Future<String> _uploadImage() async {
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef =
        FirebaseStorage.instance.ref().child('chat_images').child(fileName);

    try {
      final uploadTask = storageRef.putFile(_selectedImage!);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image. Please try again.')),
      );
      return '';
    }
  }

  Future<void> _uploadImageAndSendMessage() async {
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef =
        FirebaseStorage.instance.ref().child('chat_images').child(fileName);

    try {
      final uploadTask = storageRef.putFile(_selectedImage!);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final messagesRef = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.roomId)
          .collection('messages');

      // Update the previously sent message with the image URL
      final querySnapshot = await messagesRef
          .where('imageUrl', isEqualTo: '')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;

        await doc.reference.update({
          'imageUrl': downloadUrl,
          'status': 'sent', // Update status to sent
        });
      }

      // Update the message status when seen
      FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.roomId)
          .collection('messages')
          .where('imageUrl', isEqualTo: downloadUrl)
          .where('status', isEqualTo: 'sent')
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((doc) {
          doc.reference.update({'status': 'seen'});
        });
      });
    } catch (e) {
      print('Image upload failed: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showDeleteOptions(
      BuildContext context, String messageId, bool isSender) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.delete_forever),
                title: Text('Delete for both'),
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteMessageForBoth(messageId);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete for me only'),
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteMessageForMe(messageId, isSender);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteMessageForMe(String messageId, bool isSender) async {
    if (isSender) {
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.roomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'senderDeleted': true,
      });
    } else {
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.roomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'receiverDeleted': true,
      });
    }
  }

  void _deleteMessageForBoth(String messageId) async {
    await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(widget.roomId)
        .collection('messages')
        .doc(messageId)
        .update({
      'deleted': true,
      'status': 'deleted', // Optional: mark as deleted
    });
  }

  void _clearAllChats(BuildContext context) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm'),
        content: Text('Are you sure you want to clear all chats?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      // Clear all messages in the current chat room
      final batch = FirebaseFirestore.instance.batch();
      final messagesRef = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.roomId)
          .collection('messages');

      final snapshot = await messagesRef.get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All messages have been cleared.')),
      );
    }
  }
}
