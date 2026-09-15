import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chapter_model.dart';

class ChapterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ChapterModel>> getChapters(String subjectId) {
    return _firestore
        .collection('subjects')
        .doc(subjectId)
        .collection('chapters')
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => ChapterModel.fromMap(
          doc.id,
          subjectId,
          doc.data(),
        ),
      )
          .toList(),
    );
  }

  Future<void> addChapter(ChapterModel chapter) async {
    await _firestore
        .collection('subjects')
        .doc(chapter.subjectId)
        .collection('chapters')
        .doc(chapter.id)
        .set(chapter.toMap());
  }

  Future<void> updateChapter(ChapterModel chapter) async {
    await _firestore
        .collection('subjects')
        .doc(chapter.subjectId)
        .collection('chapters')
        .doc(chapter.id)
        .update(chapter.toMap());
  }

  Future<void> deleteChapter(
      String subjectId,
      String chapterId,
      ) async {
    await _firestore
        .collection('subjects')
        .doc(subjectId)
        .collection('chapters')
        .doc(chapterId)
        .delete();
  }
}