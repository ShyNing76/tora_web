class Quiz {
  final String id;
  final String title;
  final String description;
  final int timeLimit; // in minutes
  final List<QuizQuestion> questions;
  final int passingScore; // percentage

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.timeLimit,
    required this.questions,
    this.passingScore = 70,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      timeLimit: json['timeLimit'],
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
      passingScore: json['passingScore'] ?? 70,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timeLimit': timeLimit,
      'questions': questions.map((q) => q.toJson()).toList(),
      'passingScore': passingScore,
    };
  }
}

enum QuestionType {
  singleChoice,
  multipleChoice,
  trueFalse;

  static QuestionType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'singlechoice':
        return QuestionType.singleChoice;
      case 'multiplechoice':
        return QuestionType.multipleChoice;
      case 'truefalse':
        return QuestionType.trueFalse;
      default:
        return QuestionType.singleChoice;
    }
  }

  String get displayName {
    switch (this) {
      case QuestionType.singleChoice:
        return 'Một đáp án';
      case QuestionType.multipleChoice:
        return 'Nhiều đáp án';
      case QuestionType.trueFalse:
        return 'Đúng/Sai';
    }
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<QuizAnswer> answers;
  final String correctAnswerId;
  final String? explanation;
  final QuestionType questionType;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswerId,
    this.explanation,
    this.questionType = QuestionType.singleChoice,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      question: json['question'],
      answers: (json['answers'] as List)
          .map((a) => QuizAnswer.fromJson(a))
          .toList(),
      correctAnswerId: json['correctAnswerId'],
      explanation: json['explanation'],
      questionType: json['questionType'] != null 
          ? QuestionType.fromString(json['questionType'])
          : QuestionType.singleChoice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answers': answers.map((a) => a.toJson()).toList(),
      'correctAnswerId': correctAnswerId,
      'explanation': explanation,
      'questionType': questionType.name,
    };
  }
}

class QuizAnswer {
  final String id;
  final String text;

  QuizAnswer({
    required this.id,
    required this.text,
  });

  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      id: json['id'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }
}

class QuizResult {
  final String id;
  final String quizId;
  final String userId;
  final DateTime completedAt;
  final int score; // percentage
  final List<UserAnswer> userAnswers;
  final int timeSpent; // in seconds
  final bool isPassed;

  QuizResult({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.completedAt,
    required this.score,
    required this.userAnswers,
    required this.timeSpent,
    required this.isPassed,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'],
      quizId: json['quizId'],
      userId: json['userId'],
      completedAt: DateTime.parse(json['completedAt']),
      score: json['score'],
      userAnswers: (json['userAnswers'] as List)
          .map((ua) => UserAnswer.fromJson(ua))
          .toList(),
      timeSpent: json['timeSpent'],
      isPassed: json['isPassed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'userId': userId,
      'completedAt': completedAt.toIso8601String(),
      'score': score,
      'userAnswers': userAnswers.map((ua) => ua.toJson()).toList(),
      'timeSpent': timeSpent,
      'isPassed': isPassed,
    };
  }
}

class UserAnswer {
  final String questionId;
  final String? selectedAnswerId; // For single choice
  final List<String>? selectedAnswerIds; // For multiple choice
  final bool isCorrect;

  UserAnswer({
    required this.questionId,
    this.selectedAnswerId,
    this.selectedAnswerIds,
    required this.isCorrect,
  });

  factory UserAnswer.fromJson(Map<String, dynamic> json) {
    return UserAnswer(
      questionId: json['questionId'],
      selectedAnswerId: json['selectedAnswerId'],
      selectedAnswerIds: json['selectedAnswerIds'] != null
          ? List<String>.from(json['selectedAnswerIds'])
          : null,
      isCorrect: json['isCorrect'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedAnswerId': selectedAnswerId,
      'selectedAnswerIds': selectedAnswerIds,
      'isCorrect': isCorrect,
    };
  }
}