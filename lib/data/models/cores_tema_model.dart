class CoresTemaModel {
  const CoresTemaModel({
    required this.primary,
    required this.secondary,
  });

  final String primary;
  final String secondary;

  factory CoresTemaModel.fromMap(Map<String, dynamic> map) {
    return CoresTemaModel(
      primary: map['primary'] as String? ?? '#1A1A2E',
      secondary: map['secondary'] as String? ?? '#E94560',
    );
  }

  Map<String, dynamic> toMap() => {
        'primary': primary,
        'secondary': secondary,
      };
}
