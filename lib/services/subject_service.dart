import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/subject_model.dart';

class SubjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<SubjectModel>> getSubjects() {
    return _firestore
        .collection('subjects')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SubjectModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> addSubject(SubjectModel subject) async {
    await _firestore.collection('subjects').doc(subject.id).set(subject.toMap());
  }

  Future<void> updateSubject(SubjectModel subject) async {
    await _firestore
        .collection('subjects')
        .doc(subject.id)
        .update(subject.toMap());
  }

  Future<void> deleteSubject(String id) async {
    await _firestore.collection('subjects').doc(id).delete();
  }
}