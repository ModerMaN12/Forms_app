import 'question_model.dart';

enum AccessType {
  anonymous('anonymous'),
  authenticated('authenticated');

  const AccessType(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case anonymous:
        return 'Anonymous (optional name)';
      case authenticated:
        return 'Authenticated only';
    }
  }
}

class SurveyModel {
  final int id;
  final int ownerId;
  final String title;
  final String description;
  final AccessType accessType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<QuestionModel> questions;
  final int responseCount;

  SurveyModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.accessType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.questions = const [],
    this.responseCount = 0,
  });

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: json['id'] as int,
      ownerId: json['owner_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      accessType: AccessType.values.firstWhere(
        (e) => e.value == json['access_type'],
        orElse: () => AccessType.anonymous,
      ),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      questions: (json['questions'] as List?)
              ?.map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      responseCount: json['response_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'access_type': accessType.value,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'response_count': responseCount,
    };
  }

  SurveyModel copyWith({
    String? title,
    String? description,
    AccessType? accessType,
    bool? isActive,
    List<QuestionModel>? questions,
  }) {
    return SurveyModel(
      id: id,
      ownerId: ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      accessType: accessType ?? this.accessType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      questions: questions ?? this.questions,
      responseCount: responseCount,
    );
  }
}
