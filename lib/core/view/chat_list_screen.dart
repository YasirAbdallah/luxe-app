// import 'package:flutter/material.dart';
// import 'package:luxe/core/controller/product_controller.dart';
// import 'package:luxe/core/model/auth_model.dart';
// import 'package:luxe/core/model/chat_mode.dart';
// import 'package:luxe/core/view/chat_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ChatListScreen extends StatelessWidget {
//   final ProductController productController = ProductController();

//   ChatListScreen({super.key});

//   Future<String?> _getUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('userId');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chat List'),
//       ),
//       body: FutureBuilder<String?>(
//         future: _getUserId(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data == null) {
//             return const Center(child: Text('No User ID found'));
//           }

//           final userId = snapshot.data!;

//           return StreamBuilder<List<ChatModel>>(
//             stream: productController.getChats(userId),
//             builder: (ctx, chatSnapshot) {
//               if (chatSnapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (chatSnapshot.hasError) {
//                 return Center(child: Text('Error: ${chatSnapshot.error}'));
//               }
//               if (!chatSnapshot.hasData || chatSnapshot.data!.isEmpty) {
//                 return const Center(child: Text('No chats available.'));
//               }

//               final chatDocs = chatSnapshot.data!;

//               // Use a set to keep track of unique user IDs
//               Set<String> uniqueUserIds = {};

//               return ListView.builder(
//                 itemCount: chatDocs.length,
//                 itemBuilder: (ctx, index) {
//                   final chat = chatDocs[index];
//                   // Ensure each user appears only once
//                   if (uniqueUserIds.contains(chat.senderId)) {
//                     return const SizedBox.shrink(); // Skip this item
//                   } else {
//                     uniqueUserIds.add(chat.senderId); // Add user to set
//                   }

//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => ChatPage(
//                             productController: productController,
//                             senderId: userId,
//                             receiverId: chat.receiverId,
//                           ),
//                         ),
//                       );
//                     },
//                     child: FutureBuilder<UserModel>(
//                       future: productController.getUserById(chat.senderId),
//                       builder: (context, userSnapshot) {
//                         if (userSnapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(child: CircularProgressIndicator());
//                         }
//                         if (userSnapshot.hasError) {
//                           return Center(
//                               child: Text('Error: ${userSnapshot.error}'));
//                         }
//                         if (!userSnapshot.hasData) {
//                           return const Center(child: Text('User data not found'));
//                         }
                    
//                         final user = userSnapshot.data!;
                    
//                         return Card(
//                           child: ListTile(
//                             leading: user.photoURL != null
//                                 ?Image.network(user.photoURL!)
//                                 : const Icon(Icons.account_circle, size: 50),
//                             title: Text(user.username ?? 'No Username'),
//                             subtitle: Text(user.email),
//                             trailing: Text(chat.timestamp.toString()),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
