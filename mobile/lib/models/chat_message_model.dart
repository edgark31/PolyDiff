import 'package:mobile/common/enums.dart';

class ChatMessageModel {
  MessageTag tag;
  String message;
  String userName;
  String timestamp;
  ChatMessageModel(this.tag, this.message, this.userName, this.timestamp);

  // ChatMessageModel({
  //   required this.tag,
  //   required this.message,
  //   required this.userName,
  //   required this.timestamp,
  // })

  static ChatMessageModel fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
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
