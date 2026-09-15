import 'package:cloud_firestore/cloud_firestore.dart';

class MockTestModel {
  final String id;
  final String title;
  final int duration;
  final int totalQuestions;
  final int totalMarks;
  final double negativeMarks;
  final bool isPublished;
  final Timestamp createdAt;

  MockTestModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.totalQuestions,
    required this.totalMarks,
    required this.negativeMarks,
    required this.isPublished,
    required this.createdAt,
  });


  factory MockTestModel.fromMap(
      Map<String, dynamic> map, String documentId) {
    return MockTestModel(
      id: documentId,
      title: map['title'] ?? '',
      duration: map['duration'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      totalMarks: map['totalMarks'] ?? 0,
      negativeMarks: (map['negativeMarks'] ?? 0).toDouble(),
      isPublished: map['isPublished'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'duration': duration,
      'totalQuestions': totalQuestions,
      'totalMarks': totalMarks,
      'negativeMarks': negativeMarks,
      'isPublished': isPublished,
      'createdAt': createdAt,
    };
  }
}