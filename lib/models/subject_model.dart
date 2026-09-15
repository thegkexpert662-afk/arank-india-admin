class SubjectModel {
  final String id;
  final String name;
  final String category;
  final int order;
  final bool isActive;

  SubjectModel({
    required this.id,
    required this.name,
    required this.category,
    required this.order,
    required this.isActive,
  });

  factory SubjectModel.fromMap(String id, Map<String, dynamic> data) {
    return SubjectModel(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'order': order,
      'isActive': isActive,
    };
  }
}