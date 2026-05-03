import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/results_model.dart';

class ResponseRepository {
  final Dio dio;

  ResponseRepository({required this.dio});

  Future<void> submitResponse({
    required int surveyId,
    String? respondentName,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      await dio.post(
        '${ApiConstants.responsesEndpoint}/$surveyId',
        data: {
          'respondent_name': respondentName,
          'answers': answers,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ResultsModel> getResults(int surveyId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.responsesEndpoint}/$surveyId/results',
      );
      return ResultsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response?.data != null && e.response!.data['detail'] != null) {
      return e.response!.data['detail'].toString();
    }
    return 'Connection error.';
  }
}
