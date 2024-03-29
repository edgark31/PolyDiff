class Observer {
  final String accountId;
  final String name;
  Observer(
    this.accountId,
    this.name,
  );

  factory Observer.fromJson(Map<String, dynamic> json) {
    return Observer(
      json['accountId'],
      json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'name': name,
    };
  }
}
