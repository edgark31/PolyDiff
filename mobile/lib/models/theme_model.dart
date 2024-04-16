class ThemeModel {
  final String mode;

  ThemeModel({
    required this.mode,
  });

  Map<String, dynamic> toJson() => {
        'mobileTheme': mode,
      };

  factory ThemeModel.fromJson(Map<String, dynamic> json) => ThemeModel(
        mode: json['mobileTheme'],
      );
}
