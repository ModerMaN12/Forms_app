import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio dio;

  AuthRepository({required this.dio});

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.registerEndpoint,
        data: {'email': email, 'password': password, 'name': name},
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );
      final token = response.data['access_token'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return token;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  String _handleError(DioException e) {
    if (e.response?.data != null && e.response!.data['detail'] != null) {
      return e.response!.data['detail'].toString();
    }
    return 'Connection error. Please check server.';
  }
}
