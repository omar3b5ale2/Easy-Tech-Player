import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/utils/constants/app_constants.dart';

class ApiService {
  final String baseUrl;
  ApiService({required this.baseUrl});

  // Method to perform GET requests with authorization headers
  Future<http.Response?> auth({
    required String endpoint,
    required String authToken,
    required String courseId,
    required String lessonId,
    required String app_version,
    required String build_number,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final body = {
        "course_id": courseId,
        "lesson_id": lessonId,
        "app_version": app_version,
        "build_number": build_number,

      };
      if (kDebugMode) {
        print("Sending data to API (auth): $body");
      }

      final response = await http.post(
        url,
        headers: {
          'auth': authToken,
          'Authorization': AppConstants.apiKey,
        },
        body: body,
      );

      if (kDebugMode) {
        print("Status Code (auth): ${response.statusCode}");
      }
      if (response.statusCode == 200) {
        return response;
      } else {
        if (kDebugMode) {
          print("Response Body (auth): ${response.body}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception (auth): $e');
      }
      return null;
    }
  }

  // New POST request method
  Future<http.Response?> postRequest({
    required String endpoint,
    required String authToken,
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {

      final response = await http.post(
        url,
        headers: {
          'auth': authToken,
          // 'Authorization': AppConstants.apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (kDebugMode) {
        print("Status Code (postRequest): ${response.statusCode}");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        if (kDebugMode) {
          print("Response Body (postRequest): ${response.statusCode}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception (postRequest): $e');
      }
      return null;
    }
  }

  // Method to fetch courses
  Future<List<Map<String, dynamic>>> fetchCourses(
      {
        required String baseUrl,
      }
      ) async {
    const endpoint = AppConstants.endPoint;
    final url = Uri.parse('$baseUrl/$endpoint');
    if (kDebugMode) {
      print('fetchCourses on: ${'$baseUrl/$endpoint'}');
    }
    try {
      final response = await http.get(url);
      if (kDebugMode) {
        print("Status Code (fetchCourses): ${response.statusCode}");
      }
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedBody);
        return List<Map<String, dynamic>>.from(data);
      } else {
        if (kDebugMode) {
          print('Error fetching courses: ${response.statusCode}');
        }
        return [];
      }
    } catch (error) {
      if (kDebugMode) {
        print('Exception (fetchCourses): $error');
      }
      return [];
    }
  }
}
