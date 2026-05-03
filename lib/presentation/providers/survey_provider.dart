import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/survey_model.dart';
import '../../data/repositories/survey_repository.dart';
import '../../data/repositories/providers.dart';

class SurveyState {
  final bool isLoading;
  final String? error;
  final List<SurveyModel> surveys;

  const SurveyState({
    this.isLoading = false,
    this.error,
    this.surveys = const [],
  });

  SurveyState copyWith({
    bool? isLoading,
    String? error,
    List<SurveyModel>? surveys,
  }) {
    return SurveyState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      surveys: surveys ?? this.surveys,
    );
  }
}

class SurveyNotifier extends StateNotifier<SurveyState> {
  final SurveyRepository _repository;

  SurveyNotifier(this._repository) : super(const SurveyState());

  Future<void> loadSurveys() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final surveys = await _repository.getMySurveys();
      state = state.copyWith(isLoading: false, surveys: surveys);
    } catch (e) {
      state = SurveyState(error: e.toString());
    }
  }

  Future<void> createSurvey({
    required String title,
    required String description,
    required String accessType,
    required List<Map<String, dynamic>> questions,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createSurvey(
        title: title,
        description: description,
        accessType: accessType,
        questions: questions,
      );
      await loadSurveys();
    } catch (e) {
      state = SurveyState(error: e.toString());
    }
  }

  Future<void> updateSurvey({
    required int surveyId,
    String? title,
    String? description,
    String? accessType,
    List<Map<String, dynamic>>? questions,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateSurvey(
        surveyId: surveyId,
        title: title,
        description: description,
        accessType: accessType,
        questions: questions,
      );
      await loadSurveys();
    } catch (e) {
      state = SurveyState(error: e.toString());
    }
  }

  Future<void> deleteSurvey(int surveyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteSurvey(surveyId);
      await loadSurveys();
    } catch (e) {
      state = SurveyState(error: e.toString());
    }
  }

  Future<void> publishSurvey(int surveyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.publishSurvey(surveyId);
      await loadSurveys();
    } catch (e) {
      state = SurveyState(error: e.toString());
    }
  }
}

final surveyProvider = StateNotifierProvider<SurveyNotifier, SurveyState>((ref) {
  return SurveyNotifier(SurveyRepository(dio: ref.watch(dioProvider)));
});
