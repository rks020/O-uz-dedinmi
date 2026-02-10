enum CategoryType { income, expense, both }

class AppCategory {
  final String id;
  final String name;
  final int colorValue; // Hex
  final String? iconCodePoint; // Material Icon code
  final CategoryType type;

  AppCategory({
    required this.id,
    required this.name,
    required this.colorValue,
    this.iconCodePoint,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconCodePoint': iconCodePoint,
      'type': type.name,
    };
  }

  factory AppCategory.fromMap(Map<String, dynamic> map) {
    return AppCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      colorValue: map['colorValue'] ?? 0xFF000000,
      iconCodePoint: map['iconCodePoint'],
      type: CategoryType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CategoryType.expense,
      ),
    );
  }
}
