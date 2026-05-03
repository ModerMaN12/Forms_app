class QuestionStats {
  final int questionId;
  final String questionText;
  final String questionType;
  final int totalAnswers;
  final List<String> textAnswers;
  final Map<String, int> choiceCounts;
  final double? ratingAvg;
  final Map<String, int> ratingDistribution;

  QuestionStats({
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.totalAnswers,
    this.textAnswers = const [],
    this.choiceCounts = const {},
    this.ratingAvg,
    this.ratingDistribution = const {},
  });

  factory QuestionStats.fromJson(Map<String, dynamic> json) {
    return QuestionStats(
      questionId: json['question_id'] as int,
      questionText: json['question_text'] as String,
      questionType: json['question_type'] as String,
      totalAnswers: json['total_answers'] as int,
      textAnswers: (json['text_answers'] as List?)?.map((e) => e.toString()).toList() ?? [],
      choiceCounts: json['choice_counts'].map<String, int>((k, v) => MapEntry(k.toString(), (v as num).toInt())),
      ratingAvg: (json['rating_avg'] as num?)?.toDouble(),
      ratingDistribution: json['rating_distribution'].map<String, int>((k, v) => MapEntry(k.toString(), (v as num).toInt())),
    );
  }
}

class ResultsModel {
  final int surveyId;
  final String surveyTitle;
  final int totalResponses;
  final List<QuestionStats> questionStats;
  final List<Map<String, dynamic>> recentResponses;

  ResultsModel({
    required this.surveyId,
    required this.surveyTitle,
    required this.totalResponses,
    required this.questionStats,
    this.recentResponses = const [],
  });

  factory ResultsModel.fromJson(Map<String, dynamic> json) {
    return ResultsModel(
      surveyId: json['survey_id'] as int,
      surveyTitle: json['survey_title'] as String,
      totalResponses: json['total_responses'] as int,
      questionStats: (json['question_stats'] as List)
          .map((s) => QuestionStats.fromJson(s as Map<String, dynamic>))
          .toList(),
      recentResponses: (json['recent_responses'] as List?)
              ?.map((r) => Map<String, dynamic>.from(r as Map))
              .toList() ??
          [],
    );
  }
}
