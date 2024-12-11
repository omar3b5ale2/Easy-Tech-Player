import 'dart:convert';
import 'package:flutter/material.dart';
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
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final body = {
        "course_id": courseId,
        "lesson_id": lessonId,
      };
      debugPrint("Sending data to API (auth): $body");

      final response = await http.post(
        url,
        headers: {
          'auth': authToken,
          'Authorization': AppConstants.apiKey,
        },
        body: body,
      );

      debugPrint("Status Code (auth): ${response.statusCode}");
      if (response.statusCode == 200) {
        return response;
      } else {
        debugPrint("Response Body (auth): ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint('Exception (auth): $e');
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
      debugPrint("Status Code (postRequest): ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        debugPrint("Response Body (postRequest): ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint('Exception (postRequest): $e');
      return null;
    }
  }

  // Method to fetch courses
  Future<List<Map<String, dynamic>>> fetchCourses() async {
    const endpoint = AppConstants.endPoint;
    final url = Uri.parse('$baseUrl/$endpoint');
    debugPrint('fetchCourses on: ${'$baseUrl/$endpoint'}');
    try {
      final response = await http.get(url);
      debugPrint("Status Code (fetchCourses): ${response.statusCode}");
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedBody);
        return List<Map<String, dynamic>>.from(data);
      } else {
        debugPrint('Error fetching courses: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      debugPrint('Exception (fetchCourses): $error');
      return [];
    }
  }
}
