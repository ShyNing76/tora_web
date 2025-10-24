class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String? imageUrl;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.imageUrl,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'imageUrl': imageUrl,
    };
  }
}