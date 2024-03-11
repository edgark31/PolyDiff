import 'package:mobile/constants/enums.dart';

class Chat {
  String raw;
  String name;
  MessageTag tag;
  String timestamp;
  Chat(this.raw, this.name, this.tag, this.timestamp);

  static Chat fromJson(Map<String, dynamic> json) {
    print('Chat.fromJson: $json');
    return Chat(
      json['raw'],
      json['name'],
      MessageTag.values.firstWhere((element) => element.name == json['tag']),
      json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'raw': raw,
      'name': name,
      'tag': tag.name,
      'timestamp': timestamp,
    };
  }
}
