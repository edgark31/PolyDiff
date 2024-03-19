import 'package:mobile/models/chat_model.dart';

class ChatLog {
  List<Chat> chat;
  String channelName;
  ChatLog(this.chat, this.channelName);

  static ChatLog fromJson(Map<String, dynamic> json) {
    return ChatLog(
      json['chat'].map<Chat>((chat) => Chat.fromJson(chat)).toList(),
      json['channelName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat': chat.map((chat) => chat.toJson()).toList(),
      'channelName': channelName,
    };
  }
}
