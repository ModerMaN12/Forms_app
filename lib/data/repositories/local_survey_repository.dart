import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/question_model.dart';
import '../models/local_survey.dart';
import '../models/local_response.dart';

class LocalSurveyRepository {
  static const _storageKey = 'local_surveys';

  Future<List<LocalSurvey>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return [];
    final list = json.decode(data) as List;
    return list.map((e) => LocalSurvey.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<LocalSurvey?> getById(String id) async {
    final surveys = await getAll();
    try {
      return surveys.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(LocalSurvey survey) async {
    final surveys = await getAll();
    final idx = surveys.indexWhere((s) => s.id == survey.id);
    if (idx >= 0) {
      surveys[idx] = survey;
    } else {
      surveys.add(survey);
    }
    await _persist(surveys);
  }

  Future<void> delete(String id) async {
    final surveys = await getAll();
    surveys.removeWhere((s) => s.id == id);
    await _persist(surveys);
  }

  Future<LocalSurvey> create({
    required String title,
    required String description,
    required List<Map<String, dynamic>> questions,
  }) async {
    final survey = LocalSurvey(
      id: const Uuid().v4(),
      title: title,
      description: description,
      questions: questions.asMap().entries.map((e) {
        final q = Map<String, dynamic>.from(e.value);
        q['id'] = -(e.key + 1);
        return QuestionModel.fromJson(q);
      }).toList(),
    );
    await save(survey);
    return survey;
  }

  Future<LocalSurvey> update({
    required String id,
    String? title,
    String? description,
    List<Map<String, dynamic>>? questions,
  }) async {
    final survey = await getById(id);
    if (survey == null) throw Exception('Survey not found');

    final updated = survey.copyWith(
      title: title,
      description: description,
    );

    if (questions != null) {
      updated.questions.clear();
      updated.questions.addAll(questions.asMap().entries.map((e) {
        final q = Map<String, dynamic>.from(e.value);
        q['id'] = -(e.key + 1);
        return QuestionModel.fromJson(q);
      }).toList());
    }

    updated.updatedAt = DateTime.now();
    await save(updated);
    return updated;
  }

  Future<void> addResponse(String surveyId, LocalResponse response) async {
    final survey = await getById(surveyId);
    if (survey == null) throw Exception('Survey not found');
    survey.responses.add(response);
    await save(survey);
  }

  Future<void> _persist(List<LocalSurvey> surveys) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(surveys.map((s) => s.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }
}
