class LocalResponse {
  final String id;
  final String? respondentName;
  final DateTime submittedAt;
  final Map<int, dynamic> answers;

  LocalResponse({
    String? id,
    this.respondentName,
    DateTime? submittedAt,
    Map<int, dynamic>? answers,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        submittedAt = submittedAt ?? DateTime.now(),
        answers = answers ?? {};

  factory LocalResponse.fromJson(Map<String, dynamic> json) {
    return LocalResponse(
      id: json['id'] as String?,
      respondentName: json['respondent_name'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      answers: (json['answers'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(int.parse(k), v),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'respondent_name': respondentName,
      'submitted_at': submittedAt.toIso8601String(),
      'answers': answers.map((k, v) => MapEntry(k.toString(), v)),
    };
  }
}
