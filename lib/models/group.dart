class Group {
  final String id;
  final String name;
  final String description; // Optional
  final DateTime createdAt;
  final int memberCount; // For screenshot "Henüz grup yok"

  Group({
    required this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
    this.memberCount = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'memberCount': memberCount,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      memberCount: map['memberCount'] ?? 1,
    );
  }
}
