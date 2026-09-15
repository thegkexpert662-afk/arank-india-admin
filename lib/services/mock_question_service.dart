import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';

class MockQuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String collection = "questions";

  Stream<List<QuestionModel>> getQuestionsByMockTest(String mockTestId) {
    return _firestore
        .collection('questions')
        .where('mockTestId', isEqualTo: mockTestId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return QuestionModel.fromMap(
          doc.id,
          "",
          "",
          doc.data(),
        );
      }).toList();
    });
  }
  Future<void> deleteMockQuestion(String id) async {
    await _firestore
        .collection('questions')
        .doc(id)
        .delete();
  }

  Future<void> addQuestion(QuestionModel question) async {
    await _firestore
        .collection('questions')
        .doc(question.id)
        .set(question.toMap());
  }

  Future<void> deleteQuestion(String id) async {
    await _firestore
        .collection('questions')
        .doc(id)
        .delete();
  }

  Future<void> updateQuestion(QuestionModel question) async {
    await _firestore
        .collection('questions')
        .doc(question.id)
        .update(question.toMap());
  }
  Future<List<QuestionModel>> getQuestionsByMockTestFuture(
      String mockTestId) async {
    final snapshot = await _firestore
        .collection('questions')
        .where('mockTestId', isEqualTo: mockTestId)
        .get();

    return snapshot.docs.map((doc) {
      return QuestionModel.fromMap(
        doc.id,
        "",
        "",
        doc.data(),
      );
    }).toList();
  }
}