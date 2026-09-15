import 'package:cloud_firestore/cloud_firestore.dart';

class ContinueLearningModel {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String subject;
  final String chapter;
  final String thumbnailUrl;
  final String icon;
  final double progress;
  final String buttonText;
  final String targetType;
  final String targetId;
  final bool isActive;
  final int sortOrder;

  const ContinueLearningModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.subject,
    required this.chapter,
    required this.thumbnailUrl,
    required this.icon,
    required this.progress,
    required this.buttonText,
    required this.targetType,
    required this.targetId,
    required this.isActive,
    required this.sortOrder,
  });

  factory ContinueLearningModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return ContinueLearningModel(
      id: doc.id,
      title: '${d['title'] ?? ''}',
      subtitle: '${d['subtitle'] ?? ''}',
      description: '${d['description'] ?? ''}',
      subject: '${d['subject'] ?? ''}',
      chapter: '${d['chapter'] ?? ''}',
      thumbnailUrl: '${d['thumbnailUrl'] ?? ''}',
      icon: '${d['icon'] ?? 'menu_book'}',
      progress: ((d['progress'] as num?)?.toDouble() ?? 0).clamp(0.0, 1.0),
      buttonText: '${d['buttonText'] ?? 'Continue'}',
      targetType: '${d['targetType'] ?? 'mockTest'}',
      targetId: '${d['targetId'] ?? ''}',
      isActive: d['isActive'] != false,
      sortOrder: (d['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'subject': subject,
        'chapter': chapter,
        'thumbnailUrl': thumbnailUrl,
        'icon': icon,
        'progress': progress,
        'buttonText': buttonText,
        'targetType': targetType,
        'targetId': targetId,
        'isActive': isActive,
        'sortOrder': sortOrder,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
