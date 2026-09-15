import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mock_test_model.dart';

class MockTestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String collection = "mock_tests";

  // Add Mock Test
  Future<void> addMockTest(MockTestModel mockTest) async {
    await _firestore.collection(collection).add(mockTest.toMap());
  }

  // Update Mock Test
  Future<void> updateMockTest(MockTestModel mockTest) async {
    await _firestore
        .collection(collection)
        .doc(mockTest.id)
        .update(mockTest.toMap());
  }

  // Delete Mock Test
  Future<void> deleteMockTest(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  // Live Mock Test List
  Stream<List<MockTestModel>> getMockTests() {
    return _firestore
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MockTestModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  // Publish / Unpublish Mock Test
  Future<void> publishMockTest(
      String id,
      bool isPublished,
      ) async {
    await _firestore
        .collection(collection)
        .doc(id)
        .update({
      'isPublished': isPublished,
    });
  }
}