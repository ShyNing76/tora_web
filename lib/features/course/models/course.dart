class Course {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final CourseType type;
  final CourseLevel level;
  final int durationInHours;
  final int studentsEnrolled;
  final double rating;
  final int reviewsCount;
  final bool isPaid;
  final double? price;
  final bool isEnrolled;
  final double? progress; // 0.0 to 1.0, only if enrolled
  final String? bookId;
  final List<dynamic>? chapters;
  final List<dynamic>? quizzes;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.level,
    required this.durationInHours,
    required this.studentsEnrolled,
    required this.rating,
    required this.reviewsCount,
    required this.isPaid,
    this.price,
    required this.isEnrolled,
    this.progress,
    this.bookId,
    this.chapters,
    this.quizzes,
  });

  // Getter for backward compatibility
  String get title => name;
  int get totalHours => durationInHours;
  int get studentCount => studentsEnrolled;
  List<String> get tags => [type.displayName, level.displayName];

  factory Course.fromJson(Map<String, dynamic> json) {
    // Parse attributes (TextBook, SoftSkills)
    CourseType courseType = CourseType.textbook;
    String attributes = json['attributes'] ?? '';
    if (attributes.toLowerCase() == 'textbook') {
      courseType = CourseType.textbook;
    } else if (attributes.toLowerCase() == 'softskills') {
      courseType = CourseType.softSkills;
    }

    // Parse level (Easy, Medium, Hard)
    CourseLevel courseLevel = CourseLevel.intermediate;
    String levelStr = json['level'] ?? '';
    if (levelStr.toLowerCase() == 'easy') {
      courseLevel = CourseLevel.basic;
    } else if (levelStr.toLowerCase() == 'medium') {
      courseLevel = CourseLevel.intermediate;
    } else if (levelStr.toLowerCase() == 'hard') {
      courseLevel = CourseLevel.advanced;
    }

    return Course(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Khóa học',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      type: courseType,
      level: courseLevel,
      durationInHours: json['durationInHours'] ?? 0,
      studentsEnrolled: json['studentsEnrolled'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
      isPaid: (json['price'] ?? 0) > 0,
      price: json['price']?.toDouble(),
      isEnrolled: false, // TODO: Get from user enrollment status
      progress: null, // TODO: Get from user progress
      bookId: json['bookId'],
      chapters: json['chapters'],
      quizzes: json['quizzes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
      'level': level.toString().split('.').last,
      'totalHours': totalHours,
      'studentCount': studentCount,
      'rating': rating,
      'isPaid': isPaid,
      'price': price,
      'isEnrolled': isEnrolled,
      'progress': progress,
      // 'instructor': instructor,
      'tags': tags,
    };
  }
}

enum CourseType {
  textbook, // Khóa học theo SGK
  softSkills, // Khóa học kỹ năng mềm
}

enum CourseLevel {
  basic, // Trung bình
  intermediate, // Khá
  advanced, // Giỏi
}

extension CourseTypeExtension on CourseType {
  String get displayName {
    switch (this) {
      case CourseType.textbook:
        return 'Theo SGK';
      case CourseType.softSkills:
        return 'Kỹ năng mềm';
    }
  }

  String get icon {
    switch (this) {
      case CourseType.textbook:
        return '📚';
      case CourseType.softSkills:
        return '🎯';
    }
  }
}

extension CourseLevelExtension on CourseLevel {
  String get displayName {
    switch (this) {
      case CourseLevel.basic:
        return 'Trung bình';
      case CourseLevel.intermediate:
        return 'Khá';
      case CourseLevel.advanced:
        return 'Giỏi';
    }
  }
}