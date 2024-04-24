// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:web_socket_channel/io.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Chat App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: ChatPage(),
//     );
//   }
// }

// class ChatPage extends StatefulWidget {
//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final databaseReference = FirebaseDatabase.instance.reference();
//   final channel = IOWebSocketChannel.connect('ws://your_server_address');

//   TextEditingController _messageController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () async {
//               await _auth.signOut();
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream: databaseReference.child('messages').onValue,
//               builder: (context, AsyncSnapshot<Event> snapshot) {
//                 if (snapshot.hasData &&
//                     !snapshot.hasError &&
//                     snapshot.data!.snapshot.value != null) {
//                   Map data = snapshot.data!.snapshot.value;
//                   List<dynamic> messages = data.values.toList();
//                   return ListView.builder(
//                     itemCount: messages.length,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         title: Text(messages[index]['text']),
//                         subtitle: Text(messages[index]['sender']),
//                       );
//                     },
//                   );
//                 } else {
//                   return Center(child: CircularProgressIndicator());
//                 }
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: () {
//                     String message = _messageController.text.trim();
//                     if (message.isNotEmpty) {
//                       sendMessage(message);
//                       _messageController.clear();
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void sendMessage(String message) {
//     databaseReference.child('messages').push().set({
//       'text': message,
//       'sender': _auth.currentUser!.uid,
//       'timestamp': DateTime.now().millisecondsSinceEpoch,
//     });
//     channel.sink.add(message); // Sending message over WebSocket
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     channel.sink.close();
//     super.dispose();
//   }
// }
