class Observers {
  final String name;
  Observers(this.name);

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
