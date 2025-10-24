import 'flashcard.dart';

class Chapter {
  final String id;
  final String name;
  final String? description;
  final bool isFree;
  final int ordering;
  final String courseId;
  final List<Lesson> lessons;
  final ChapterQuiz? quiz;

  Chapter({
    required this.id,
    required this.name,
    this.description,
    required this.isFree,
    required this.ordering,
    required this.courseId,
    required this.lessons,
    this.quiz,
  });

  // Backward compatibility getters
  String get title => name;
  int get order => ordering;

  // Calculate progress of the chapter (0.0 to 1.0)
  double get progress {
    if (lessons.isEmpty) return 0.0;
    int completedLessons = lessons.where((lesson) => lesson.isCompleted).length;
    return completedLessons / lessons.length;
  }

  // Get total duration of all lessons in this chapter
  int get totalDuration {
    return lessons.fold(0, (sum, lesson) => sum + lesson.durationMinutes);
  }

  factory Chapter.fromJson(Map<String, dynamic> json) {
    var lessonsList = <Lesson>[];
    if (json['lessons'] != null) {
      lessonsList = (json['lessons'] as List)
          .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
          .toList();
      lessonsList.sort((a, b) => a.ordering.compareTo(b.ordering));
    }

    return Chapter(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      isFree: json['isFree'] ?? false,
      ordering: json['ordering'] ?? 0,
      courseId: json['courseId']?.toString() ?? '',
      lessons: lessonsList,
      quiz: json['quiz'] != null ? ChapterQuiz.fromJson(json['quiz'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isFree': isFree,
      'ordering': ordering,
      'courseId': courseId,
      'lessons': lessons.map((l) => l.toJson()).toList(),
      'quiz': quiz?.toJson(),
    };
  }
}

class Lesson {
  final String id;
  final String name;
  final String? description;
  final int timeInMinutes;
  final bool isCompleted;
  final int ordering;
  final String chapterId;
  final String? videoUrl;
  final String? content;
  final String? summary;
  final List<Flashcard> flashcards;

  Lesson({
    required this.id,
    required this.name,
    this.description,
    required this.timeInMinutes,
    required this.isCompleted,
    required this.ordering,
    required this.chapterId,
    this.videoUrl,
    this.content,
    this.summary,
    this.flashcards = const [],
  });

  // Backward compatibility getters
  String get title => name;
  int get durationMinutes => timeInMinutes;
  int get order => ordering;
  LessonType get type => this is QuizLesson ? LessonType.quiz : LessonType.lesson;
  bool get isLocked => false; // Locking logic moved to UI layer

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      timeInMinutes: json['timeInMinutes'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      ordering: json['ordering'] ?? 0,
      chapterId: json['chapterId']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString(),
      content: json['content']?.toString(),
      summary: json['summary']?.toString(),
      flashcards: json['flashcards'] != null
          ? (json['flashcards'] as List).map((f) => Flashcard.fromJson(f)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'timeInMinutes': timeInMinutes,
      'isCompleted': isCompleted,
      'ordering': ordering,
      'chapterId': chapterId,
      'videoUrl': videoUrl,
      'content': content,
      'summary': summary,
      'flashcards': flashcards.map((f) => f.toJson()).toList(),
    };
  }
}

// QuizLesson is a Lesson that represents a quiz
class QuizLesson extends Lesson {
  QuizLesson({
    required super.id,
    required super.name,
    super.description,
    required super.timeInMinutes,
    required super.isCompleted,
    required super.ordering,
    required super.chapterId,
    super.videoUrl,
    super.content,
    super.summary,
    super.flashcards,
  });
}

class ChapterQuiz {
  final String id;
  final String name;
  final int time;
  final String? description;
  final double passPercent;
  final String? chapterId;
  final String? lessonId;
  final String? courseId;
  final bool isActive;

  ChapterQuiz({
    required this.id,
    required this.name,
    required this.time,
    this.description,
    required this.passPercent,
    this.chapterId,
    this.lessonId,
    this.courseId,
    required this.isActive,
  });

  // Convert Quiz to QuizLesson for UI compatibility
  QuizLesson toLesson() {
    return QuizLesson(
      id: id,
      name: name,
      description: description ?? 'Bài kiểm tra',
      timeInMinutes: time,
      isCompleted: false,
      ordering: 9999, // Put quiz at the end
      chapterId: chapterId ?? '',
      videoUrl: null,
      content: null,
      summary: null,
      flashcards: [],
    );
  }

  factory ChapterQuiz.fromJson(Map<String, dynamic> json) {
    return ChapterQuiz(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      time: json['time'] ?? 0,
      description: json['description']?.toString(),
      passPercent: (json['passPercent'] ?? 0).toDouble(),
      chapterId: json['chapterId']?.toString(),
      lessonId: json['lessonId']?.toString(),
      courseId: json['courseId']?.toString(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'description': description,
      'passPercent': passPercent,
      'chapterId': chapterId,
      'lessonId': lessonId,
      'courseId': courseId,
      'isActive': isActive,
    };
  }
}

enum LessonType {
  lesson,   // Regular lesson
  quiz,     // Quiz/Test
}

extension LessonTypeExtension on LessonType {
  String get displayName {
    switch (this) {
      case LessonType.lesson:
        return 'Bài học';
      case LessonType.quiz:
        return 'Kiểm tra';
    }
  }

  String get icon {
    switch (this) {
      case LessonType.lesson:
        return '�';
      case LessonType.quiz:
        return '📝';
    }
  }
}