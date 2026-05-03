enum QuestionType {
  singleChoice('single_choice'),
  multipleChoice('multiple_choice'),
  text('text'),
  rating('rating'),
  scale('scale');

  const QuestionType(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case singleChoice:
        return 'Single Choice';
      case multipleChoice:
        return 'Multiple Choice';
      case text:
        return 'Text';
      case rating:
        return 'Rating (1-5)';
      case scale:
        return 'Scale (1-10)';
    }
  }
}

class QuestionModel {
  final int? id;
  final String text;
  final QuestionType questionType;
  final List<String>? options;
  final bool isRequired;
  final int order;

  QuestionModel({
    this.id,
    required this.text,
    required this.questionType,
    this.options,
    this.isRequired = true,
    this.order = 0,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int?,
      text: json['text'] as String,
      questionType: QuestionType.values.firstWhere(
        (e) => e.value == json['question_type'],
        orElse: () => QuestionType.text,
      ),
      options: (json['options'] as List?)?.map((e) => e.toString()).toList(),
      isRequired: json['is_required'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'text': text,
      'question_type': questionType.value,
      'options': options,
      'is_required': isRequired,
      'order': order,
    };
  }

  QuestionModel copyWith({
    String? text,
    QuestionType? questionType,
    List<String>? options,
    bool? isRequired,
    int? order,
  }) {
    return QuestionModel(
      id: id,
      text: text ?? this.text,
      questionType: questionType ?? this.questionType,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
      order: order ?? this.order,
    );
  }
}
