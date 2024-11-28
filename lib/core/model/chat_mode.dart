
enum MessageType {
  text,
  image,
  video,
}

class ChatModel {
  final String  senderId;
  final String receiverId;
  final String message;
  final MessageType type;
  final DateTime timestamp;

  ChatModel({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      message: map['message'],
      type: MessageType.values[map['type']],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
