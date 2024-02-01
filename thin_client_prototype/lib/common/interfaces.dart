import "enums.dart";

class ChatMessageGlobal {
  MessageTag tag;
  String message;
  String userName;
  String timestamp;
  ChatMessageGlobal(this.tag, this.message, this.userName, this.timestamp);

  static ChatMessageGlobal fromJson(Map<String, dynamic> json) {
    return ChatMessageGlobal(
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
