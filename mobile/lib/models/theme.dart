class Theme {
  final String theme;

  Theme({
    required this.theme,
  });

  Map<String, dynamic> toJson() => {
        'mobileTheme': theme,
      };

  factory Theme.fromJson(Map<String, dynamic> json) => Theme(
        theme: json['mobileTheme'],
      );
}
