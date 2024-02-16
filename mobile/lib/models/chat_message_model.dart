import 'package:mobile/constants/enums.dart';

class ChatMessage {
  MessageTag tag;
  String message;
  String userName;
  String timestamp;
  ChatMessage(this.tag, this.message, this.userName, this.timestamp);

  static ChatMessage fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      MessageTag.values.firstWhere((element) => element.name == json['tag']),
      json['message'],
      json['userName'],
      json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag.name,
      'message': message,
      'userName': userName,
      'timestamp': timestamp,
    };
  }
}
