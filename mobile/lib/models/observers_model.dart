// TODO: Change to singular on server ??

class Observers {
  final String name;
  Observers(this.name);

  // TODO : add fromJson and toJson
  factory Observers.fromJson(Map<String, dynamic> json) {
    return Observers(
      json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
