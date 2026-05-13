import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/local_survey.dart';
import '../../data/repositories/local_survey_repository.dart';

final localSurveyRepositoryProvider = Provider<LocalSurveyRepository>((ref) {
  return LocalSurveyRepository();
});

class LocalSurveyState {
  final bool isLoading;
  final String? error;
  final List<LocalSurvey> surveys;

  const LocalSurveyState({
    this.isLoading = false,
    this.error,
    this.surveys = const [],
  });

  LocalSurveyState copyWith({
    bool? isLoading,
    String? error,
    List<LocalSurvey>? surveys,
  }) {
    return LocalSurveyState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      surveys: surveys ?? this.surveys,
    );
  }
}

class LocalSurveyNotifier extends StateNotifier<LocalSurveyState> {
  final LocalSurveyRepository _repo;

  LocalSurveyNotifier(this._repo) : super(const LocalSurveyState());

  Future<void> loadSurveys() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final surveys = await _repo.getAll();
      surveys.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = state.copyWith(isLoading: false, surveys: surveys);
    } catch (e) {
      state = LocalSurveyState(error: e.toString());
    }
  }

  Future<void> createSurvey({
    required String title,
    required String description,
    required List<Map<String, dynamic>> questions,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.create(title: title, description: description, questions: questions);
      await loadSurveys();
    } catch (e) {
      state = LocalSurveyState(error: e.toString());
    }
  }

  Future<void> updateSurvey({
    required String id,
    String? title,
    String? description,
    List<Map<String, dynamic>>? questions,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.update(id: id, title: title, description: description, questions: questions);
      await loadSurveys();
    } catch (e) {
      state = LocalSurveyState(error: e.toString());
    }
  }

  Future<void> deleteSurvey(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.delete(id);
      await loadSurveys();
    } catch (e) {
      state = LocalSurveyState(error: e.toString());
    }
  }
}

final localSurveyProvider = StateNotifierProvider<LocalSurveyNotifier, LocalSurveyState>((ref) {
  return LocalSurveyNotifier(ref.watch(localSurveyRepositoryProvider));
});
