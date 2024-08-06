import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class ChatRoomsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Rooms'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data?.docs
              .where((user) => user.id != currentUser?.uid)
              .toList();
          return ListView.builder(
            itemCount: users?.length,
            itemBuilder: (context, index) {
              final user = users?[index];
              return ListTile(
                title: Text(user?['name']),
                onTap: () {
                  _createOrOpenChatRoom(
                      context, "${currentUser?.uid}", "${user?.id}");
                },
              );
            },
          );
        },
      ),
    );
  }

  void _createOrOpenChatRoom(
      BuildContext context, String currentUserId, String otherUserId) async {
    final chatRooms = FirebaseFirestore.instance.collection('chatRooms');

    // Fetch the names of the users
    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    final otherUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .get();

    final currentUserName = currentUserDoc.data()?['name'] ?? 'Unknown';
    final otherUserName = otherUserDoc.data()?['name'] ?? 'Unknown';

    // Format the room name
    final roomName = '${currentUserName} - ${otherUserName}';
    final roomId = _generateRoomId(currentUserId, otherUserId);

    // Check if the room already exists
    final roomQuerySnapshot = await chatRooms.doc(roomId).get();
    if (roomQuerySnapshot.exists) {
      // Room already exists, navigate to it
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(roomId: roomId),
        ),
      );
    } else {
      // Create a new room
      await chatRooms.doc(roomId).set({
        'users': [currentUserId, otherUserId],
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
        'roomName': roomName,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(roomId: roomId),
        ),
      );
    }
  }

// Generate a unique room ID based on the user IDs
  String _generateRoomId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('-');
  }
}
