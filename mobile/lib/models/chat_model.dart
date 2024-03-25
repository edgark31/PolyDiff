import 'package:mobile/constants/enums.dart';

class Chat {
  String raw;
  String? accountId;
  String? name;
  MessageTag? tag;
  String? timestamp;
  Chat(
    this.raw,
    this.accountId,
    this.name,
    this.tag,
    this.timestamp,
  );

  static Chat fromJson(Map<String, dynamic> json) {
    MessageTag? tag;
    if (json['tag'] != null) {
      tag = MessageTag.values
          .firstWhere((element) => element.name == json['tag']);
    }
    return Chat(
      json['raw'],
      json['accountId'],
      json['name'],
      tag,
      json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'raw': raw,
      'accountId': accountId,
      'name': name,
      'tag': tag?.name,
      'timestamp': timestamp,
    };
  }
}
