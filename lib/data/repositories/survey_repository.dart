import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/survey_model.dart';

class SurveyRepository {
  final Dio dio;

  SurveyRepository({required this.dio});

  Future<List<SurveyModel>> getMySurveys() async {
    try {
      final response = await dio.get(ApiConstants.surveysEndpoint);
      return (response.data as List)
          .map((s) => SurveyModel.fromJson(s as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<SurveyModel> createSurvey({
    required String title,
    required String description,
    required String accessType,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.surveysEndpoint,
        data: {
          'title': title,
          'description': description,
          'access_type': accessType,
          'questions': questions,
        },
      );
      return SurveyModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<SurveyModel> updateSurvey({
    required int surveyId,
    String? title,
    String? description,
    String? accessType,
    List<Map<String, dynamic>>? questions,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (accessType != null) data['access_type'] = accessType;
      if (questions != null) data['questions'] = questions;

      final response = await dio.put(
        '${ApiConstants.surveysEndpoint}/$surveyId',
        data: data,
      );
      return SurveyModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteSurvey(int surveyId) async {
    try {
      await dio.delete('${ApiConstants.surveysEndpoint}/$surveyId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<SurveyModel> publishSurvey(int surveyId) async {
    try {
      final response = await dio.post(
        '${ApiConstants.surveysEndpoint}/$surveyId/publish',
      );
      return SurveyModel.fromJson(response.data);
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
