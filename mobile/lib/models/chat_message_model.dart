import 'package:mobile/common/enums.dart';

class ChatMessageModel {
  MessageTag tag;
  String message;
  String userName;
  String timestamp;

  ChatMessageModel({
    required this.tag,
    required this.message,
    required this.userName,
    required this.timestamp,
  });
}
