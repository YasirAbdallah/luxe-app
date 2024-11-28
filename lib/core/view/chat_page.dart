// // ignore_for_file: avoid_print

// import 'dart:convert';
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:luxe/core/controller/product_controller.dart';
// import 'package:luxe/core/model/auth_model.dart';
// import 'package:luxe/core/model/chat_mode.dart';
// import 'package:mime/mime.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:uuid/uuid.dart';

// class ChatPage extends StatefulWidget {
//   const ChatPage({
//     super.key,
//     required this.productController,
//     required this.senderId,
//     required this.receiverId,
//   });

//   final ProductController productController;
//   final String senderId;
//   final String receiverId;

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   List<types.Message> _messages = [];
//   final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
//   UserModel? _receiver;

//   @override
//   void initState() {
//     super.initState();
//     _loadMessages();
//     _setupChatStream();
//     _fetchReceiverDetails();
//   }

//   Future<void> _fetchReceiverDetails() async {
//     UserModel? receiver =
//         await widget.productController.getUser(widget.receiverId);
//     setState(() {
//       _receiver = receiver;
//     });
//   }

//   void _addMessage(types.Message message) {
//     setState(() {
//       _messages.insert(0, message);
//     });
//   }

//   void _setupChatStream() {
//     widget.productController
//         .getChatStream(widget.senderId, widget.receiverId)
//         .listen((chatMessages) {
//       final messages = chatMessages.map((chatModel) {
//         switch (chatModel.type) {
//           case MessageType.text:
//             return types.TextMessage(
//               author: types.User(id: chatModel.senderId),
//               createdAt: chatModel.timestamp.millisecondsSinceEpoch,
//               id: const Uuid().v4(),
//               text: chatModel.message,
//             );
//           case MessageType.image:
//             return types.ImageMessage(
//               author: types.User(id: chatModel.senderId),
//               createdAt: chatModel.timestamp.millisecondsSinceEpoch,
//               height: 0, // Add actual image height
//               id: const Uuid().v4(),
//               name: chatModel.message,
//               size: 0, // Add actual image size
//               uri: chatModel.message,
//               width: 0, // Add actual image width
//             );
//           case MessageType.video:
//             return types.FileMessage(
//               author: types.User(id: chatModel.senderId),
//               createdAt: chatModel.timestamp.millisecondsSinceEpoch,
//               id: const Uuid().v4(),
//               mimeType: 'video/mp4', // Adjust as necessary
//               name: chatModel.message,
//               size: 0, // Add actual video size
//               uri: chatModel.message,
//             );
//           default:
//             return types.TextMessage(
//               author: types.User(id: chatModel.senderId),
//               createdAt: chatModel.timestamp.millisecondsSinceEpoch,
//               id: const Uuid().v4(),
//               text: chatModel.message,
//             );
//         }
//       }).toList();

//       // Ensure messages are sorted by createdAt in ascending order
//       messages.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

//       setState(() {
//         _messages = messages;
//       });
//     });
//   }

//   void _handleAttachmentPressed() {
//     showModalBottomSheet<void>(
//       context: context,
//       builder: (BuildContext context) => SafeArea(
//         child: SizedBox(
//           height: 144,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   _handleImageSelection();
//                 },
//                 child: const Align(
//                   alignment: AlignmentDirectional.centerStart,
//                   child: Text('Photo'),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   _handleFileSelection();
//                 },
//                 child: const Align(
//                   alignment: AlignmentDirectional.centerStart,
//                   child: Text('File'),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Align(
//                   alignment: AlignmentDirectional.centerStart,
//                   child: Text('Cancel'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleFileSelection() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.any);

//     if (result != null && result.files.single.path != null) {
//       final file = File(result.files.single.path!);
//       final message = types.FileMessage(
//         author: _user,
//         createdAt: DateTime.now().millisecondsSinceEpoch,
//         id: const Uuid().v4(),
//         mimeType: lookupMimeType(result.files.single.path!),
//         name: result.files.single.name,
//         size: result.files.single.size,
//         uri: result.files.single.path!,
//       );

//       _addMessage(message);

//       final chat = ChatModel(
//         senderId: widget.senderId,
//         receiverId: widget.receiverId,
//         message: '',
//         type: MessageType.video,
//         timestamp: DateTime.now(),
//       );

//       await widget.productController.sendMessage(chat, file: file);
//     }
//   }

//   void _handleImageSelection() async {
//     final result = await ImagePicker().pickImage(
//         imageQuality: 70, maxWidth: 1440, source: ImageSource.gallery);

//     if (result != null) {
//       final file = File(result.path);
//       final bytes = await result.readAsBytes();
//       final image = await decodeImageFromList(bytes);

//       final message = types.ImageMessage(
//         author: _user,
//         createdAt: DateTime.now().millisecondsSinceEpoch,
//         height: image.height.toDouble(),
//         id: const Uuid().v4(),
//         name: result.name,
//         size: bytes.length,
//         uri: result.path,
//         width: image.width.toDouble(),
//       );

//       _addMessage(message);

//       final chat = ChatModel(
//         senderId: widget.senderId,
//         receiverId: widget.receiverId,
//         message: '',
//         type: MessageType.image,
//         timestamp: DateTime.now(),
//       );

//       await widget.productController.sendMessage(chat, file: file);
//     }
//   }

//   void _handleMessageTap(BuildContext _, types.Message message) async {
//     if (message is types.FileMessage) {
//       var localPath = message.uri;

//       if (message.uri.startsWith('http')) {
//         try {
//           final index =
//               _messages.indexWhere((element) => element.id == message.id);
//           final updatedMessage =
//               (_messages[index] as types.FileMessage).copyWith(isLoading: true);

//           setState(() {
//             _messages[index] = updatedMessage;
//           });

//           final client = http.Client();
//           final request = await client.get(Uri.parse(message.uri));
//           final bytes = request.bodyBytes;
//           final documentsDir = (await getApplicationDocumentsDirectory()).path;
//           localPath = '$documentsDir/${message.name}';

//           if (!File(localPath).existsSync()) {
//             final file = File(localPath);
//             await file.writeAsBytes(bytes);
//           }
//         } finally {
//           final index =
//               _messages.indexWhere((element) => element.id == message.id);
//           final updatedMessage =
//               (_messages[index] as types.FileMessage).copyWith(isLoading: null);

//           setState(() {
//             _messages[index] = updatedMessage;
//           });
//         }
//       }

//       await OpenFilex.open(localPath);
//     }
//   }

//   void _handlePreviewDataFetched(
//     types.TextMessage message,
//     types.PreviewData previewData,
//   ) {
//     final index = _messages.indexWhere((element) => element.id == message.id);
//     final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
//       previewData: previewData,
//     );

//     setState(() {
//       _messages[index] = updatedMessage;
//     });
//   }

//   void _handleSendPressed(types.PartialText message) async {
//     final textMessage = types.TextMessage(
//       author: _user,
//       createdAt: DateTime.now().millisecondsSinceEpoch,
//       id: const Uuid().v4(),
//       text: message.text,
//     );

//     _addMessage(textMessage);

//     final chat = ChatModel(
//       senderId: widget.senderId,
//       receiverId: widget.receiverId,
//       message: message.text,
//       type: MessageType.text,
//       timestamp: DateTime.now(),
//     );

//     await widget.productController.sendMessage(chat);
//   }

//   Future<void> _loadMessages() async {
//     final response = await rootBundle.loadString('assets/data/messages.json');
//     final messages = (jsonDecode(response) as List)
//         .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
//         .toList();

//     setState(() {
//       _messages = messages;
//     });
//   }

//   void _onDeleteChat() async {
//     try {
//       await widget.productController.deleteAllChats(
//         widget.senderId,
//         widget.receiverId,
//       );
//       // After deleting, update any necessary UI-related state variables
//       setState(() {
//         _messages.clear(); // Clear the messages list or update as needed
//       });
//     } catch (e) {
//       print('Error deleting chat: $e');
//     }
//   }


//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: AppBar(
//           title: _receiver != null
//               ? Row(
//                   children: [
//                     CircleAvatar(
//                       backgroundImage: _receiver!.photoURL != null
//                           ? NetworkImage(_receiver!.photoURL!)
//                           : const AssetImage('assets/default_avatar.jpg'),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(_receiver!.username ?? ''),
//                   ],
//                 )
//               : null,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: _onDeleteChat,
//             ),
//           ],
//         ),
//         body: Chat(
//           messages: _messages,
//           onAttachmentPressed: _handleAttachmentPressed,
//           onMessageTap: _handleMessageTap,
//           onPreviewDataFetched: _handlePreviewDataFetched,
//           onSendPressed: _handleSendPressed,
//           user: _user,
//         ),
//       );
// }
