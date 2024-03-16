class Theme {
  String name;
  String? color;
  String? backgroundColor;
  String? buttonColor;

  Theme({
    required this.name,
    this.color,
    this.backgroundColor,
    this.buttonColor,
  });

  factory Theme.fromJson(Map<String, dynamic> json) {
    return Theme(
      name: json['name'],
      color: json['color'],
      backgroundColor: json['backgroundColor'],
      buttonColor: json['buttonColor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color,
      'backgroundColor': backgroundColor,
      'buttonColor': buttonColor,
    };
  }
}
