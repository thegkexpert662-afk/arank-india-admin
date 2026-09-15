import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';

class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;




  Stream<List<QuestionModel>> getQuestions(
      String subjectId,
      String chapterId,
      ) {
    return _firestore
        .collection('subjects')
        .doc(subjectId)
        .collection('chapters')
        .doc(chapterId)
        .collection('questions')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => QuestionModel.fromMap(
          doc.id,
          subjectId,
          chapterId,
          doc.data(),
        ),
      )
          .toList(),
    );
  }

  Future<void> addQuestion(QuestionModel question) async {
    await _firestore
        .collection('subjects')
        .doc(question.subjectId)
        .collection('chapters')
        .doc(question.chapterId)
        .collection('questions')
        .doc(question.id)
        .set(question.toMap());
  }
  Stream<List<QuestionModel>> getQuestionsByMockTest(String mockTestId) {
    return FirebaseFirestore.instance
        .collection("questions")
        .where("mockTestId", isEqualTo: mockTestId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => QuestionModel.fromMap(
      doc.id,
      "",
      "",
      doc.data(),
    ))
        .toList());
  }

  Future<void> addMockTestQuestion(QuestionModel question) async {
    await _firestore
        .collection('mock_tests')
        .doc(question.mockTestId)
        .collection('questions')
        .doc(question.id)
        .set(question.toMap());
  }

  Future<void> updateQuestion(QuestionModel question) async {
    await _firestore
        .collection('subjects')
        .doc(question.subjectId)
        .collection('chapters')
        .doc(question.chapterId)
        .collection('questions')
        .doc(question.id)
        .update(question.toMap());
  }

  Future<void> deleteQuestion(
      String subjectId,
      String chapterId,
      String questionId,
      ) async {
    await _firestore
        .collection('subjects')
        .doc(subjectId)
        .collection('chapters')
        .doc(chapterId)
        .collection('questions')
        .doc(questionId)
        .delete();
  }
}