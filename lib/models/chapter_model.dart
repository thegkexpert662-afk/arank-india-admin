class ChapterModel {
  final String id;
  final String subjectId;
  final String name;
  final int order;
  final bool isActive;

  ChapterModel({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.order,
    required this.isActive,
  });

  factory ChapterModel.fromMap(
      String id,
      String subjectId,
      Map<String, dynamic> data,
      ) {
    return ChapterModel(
      id: id,
      subjectId: subjectId,
      name: data['name'] ?? '',
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'order': order,
      'isActive': isActive,
    };
  }
}