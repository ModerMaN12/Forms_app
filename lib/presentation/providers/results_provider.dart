import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/results_model.dart';
import '../../data/repositories/response_repository.dart';
import '../../data/repositories/providers.dart';

class ResultsState {
  final bool isLoading;
  final String? error;
  final ResultsModel? results;

  const ResultsState({
    this.isLoading = false,
    this.error,
    this.results,
  });

  ResultsState copyWith({
    bool? isLoading,
    String? error,
    ResultsModel? results,
  }) {
    return ResultsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      results: results ?? this.results,
    );
  }
}

class ResultsNotifier extends StateNotifier<ResultsState> {
  final ResponseRepository _repository;

  ResultsNotifier(this._repository) : super(const ResultsState());

  Future<void> loadResults(int surveyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await _repository.getResults(surveyId);
      state = state.copyWith(isLoading: false, results: results);
    } catch (e) {
      state = ResultsState(error: e.toString());
    }
  }
}

final resultsProvider = StateNotifierProvider.family<ResultsNotifier, ResultsState, int>((ref, surveyId) {
  return ResultsNotifier(ResponseRepository(dio: ref.watch(dioProvider)));
});
