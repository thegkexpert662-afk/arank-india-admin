

class QuestionModel {
  final String id;

  // Subject Wise
  final String subjectId;
  final String chapterId;

  // Mock Test Wise
  final String mockTestId;
  final String subject;

  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final String explanation;
  final String difficulty;
  final int marks;
  final double negativeMarks;
  final bool isActive;

  QuestionModel({
    required this.id,
    required this.subjectId,
    required this.chapterId,
    required this.mockTestId,
    required this.subject,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
    required this.marks,
    required this.negativeMarks,
    required this.isActive,
  });

  factory QuestionModel.fromMap(
      String id,
      String subjectId,
      String chapterId,
      Map<String, dynamic> data,
      ) {
    return QuestionModel(
      id: id,
      subjectId: subjectId,
      chapterId: chapterId,
      mockTestId: data['mockTestId'] ?? '',
      subject: (data['subject'] ?? '').toString().trim().toUpperCase(),
      question: data['question'] ?? '',
      optionA: data['optionA'] ?? '',
      optionB: data['optionB'] ?? '',
      optionC: data['optionC'] ?? '',
      optionD: data['optionD'] ?? '',
      correctAnswer: data['correctAnswer'] ?? 'A',
      explanation: data['explanation'] ?? '',
      difficulty: data['difficulty'] ?? 'Easy',
      marks: data['marks'] ?? 2,
      negativeMarks: (data['negativeMarks'] ?? 0.5).toDouble(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mockTestId': mockTestId,
      'subject': subject,
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'difficulty': difficulty,
      'marks': marks,
      'negativeMarks': negativeMarks,
      'isActive': isActive,
    };
  }
}