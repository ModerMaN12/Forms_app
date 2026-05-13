import '../models/question_model.dart';
import '../models/local_response.dart';

class LocalSurvey {
  final String id;
  String title;
  String description;
  List<QuestionModel> questions;
  List<LocalResponse> responses;
  DateTime createdAt;
  DateTime updatedAt;

  LocalSurvey({
    required this.id,
    required this.title,
    this.description = '',
    List<QuestionModel>? questions,
    List<LocalResponse>? responses,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : questions = questions ?? [],
        responses = responses ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get responseCount => responses.length;

  factory LocalSurvey.fromJson(Map<String, dynamic> json) {
    return LocalSurvey(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      questions: (json['questions'] as List?)
              ?.map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      responses: (json['responses'] as List?)
              ?.map((r) => LocalResponse.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'responses': responses.map((r) => r.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  LocalSurvey copyWith({
    String? title,
    String? description,
  }) {
    return LocalSurvey(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions,
      responses: responses,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
