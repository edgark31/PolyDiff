class Theme {
  final String name;
  final String? color;
  final String? backgroundColor;
  final String? buttonColor;

  Theme({
    required this.name,
    this.color,
    this.backgroundColor,
    this.buttonColor,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (color != null) 'color': color,
        if (backgroundColor != null) 'backgroundColor': backgroundColor,
        if (buttonColor != null) 'buttonColor': buttonColor,
      };

  factory Theme.fromJson(Map<String, dynamic> json) => Theme(
        name: json['name'],
        color: json['color'],
        backgroundColor: json['backgroundColor'],
        buttonColor: json['buttonColor'],
      );
}
