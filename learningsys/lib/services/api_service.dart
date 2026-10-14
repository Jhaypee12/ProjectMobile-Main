import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    return 'http://localhost:3000/api';
  }

  static const _headers = {'Content-Type': 'application/json'};

  static dynamic _handle(http.Response res) {
    final data = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    if (res.statusCode >= 400) {
      throw Exception(
          (data is Map && data['message'] != null)
              ? data['message']
              : 'Request failed (${res.statusCode})');
    }
    return data;
  }

  static Future<Map<String, dynamic>> register(
      String firstName, String lastName, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      }),
    );
    return _handle(res);
  }

  static Future<AppUser> login(
      String email, String password, String role) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password, 'role': role}),
    );
    final data = _handle(res);
    return AppUser.fromJson(data);
  }

  static Future<Map<String, dynamic>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: _headers,
      body: jsonEncode({
        'userId': userId,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'newPassword': newPassword,
      }),
    );
    return _handle(res);
  }


  static Future<List<Map<String, dynamic>>> getUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/auth'));
    final data = _handle(res) as List;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth'),
      headers: _headers,
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> updateUser(
    String id, {
    required String firstName,
    required String lastName,
    required String email,
    String? password,
    required String role,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/auth/$id'),
      headers: _headers,
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
        if (password != null && password.isNotEmpty) 'password': password,
      }),
    );
    return _handle(res);
  }

  static Future<void> deleteUser(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/auth/$id'));
    _handle(res);
  }


  static Future<List<Map<String, dynamic>>> getCourses({
    String? studentId,
  }) async {
    final url = studentId != null
        ? '$baseUrl/courses?student=$studentId'
        : '$baseUrl/courses';
    final res = await http.get(Uri.parse(url));
    final data = _handle(res) as List;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> createCourse({
    required String name,
    required String instructor,
    required String description,
    required String grade,
    required int score,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/courses'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'instructor': instructor,
        'description': description,
        'grade': grade,
        'score': score,
      }),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> updateCourse(
    String id, {
    required String name,
    required String instructor,
    required String description,
    required String grade,
    required int score,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/courses/$id'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'instructor': instructor,
        'description': description,
        'grade': grade,
        'score': score,
      }),
    );
    return _handle(res);
  }

  static Future<void> deleteCourse(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/courses/$id'));
    _handle(res);
  }


  static Future<List<Map<String, dynamic>>> getMyCourses() async {
    final res = await http.get(Uri.parse('$baseUrl/mycourses'));
    final data = _handle(res) as List;
    return data.cast<Map<String, dynamic>>();
  }


  static Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final res = await http.get(Uri.parse('$baseUrl/announcements'));
    final data = _handle(res) as List;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> createAnnouncement({
    required String title,
    required String message,
    required String course,
    String? section,
    required String date,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/announcements'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'message': message,
        'course': course,
        'section': section ?? '',
        'date': date,
      }),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> updateAnnouncement(
    String id, {
    required String title,
    required String message,
    required String course,
    String? section,
    required String date,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/announcements/$id'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'message': message,
        'course': course,
        'section': section ?? '',
        'date': date,
      }),
    );
    return _handle(res);
  }

  static Future<void> deleteAnnouncement(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/announcements/$id'));
    _handle(res);
  }


  static Future<List<Map<String, dynamic>>> getAssessments({
    String? studentId,
  }) async {
    final url = studentId != null
        ? '$baseUrl/assessments?student=$studentId'
        : '$baseUrl/assessments';
    final res = await http.get(Uri.parse(url));
    final data = _handle(res) as List;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> createAssessment({
    required String name,
    required String course,
    required String type,
    required String due,
    required String status,
    String? description,
    String? section,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/assessments'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'course': course,
        'type': type,
        'due': due,
        'status': status,
        'description': description ?? '',
        'section': section ?? '',
      }),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> updateAssessment(
    String id, {
    required String name,
    required String course,
    required String type,
    required String due,
    required String status,
    String? description,
    String? section,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/assessments/$id'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'course': course,
        'type': type,
        'due': due,
        'status': status,
        'description': description ?? '',
        'section': section ?? '',
      }),
    );
    return _handle(res);
  }

  static Future<void> deleteAssessment(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/assessments/$id'));
    _handle(res);
  }


  static Future<List<Map<String, dynamic>>> getGrades() async {
    final res = await http.get(Uri.parse('$baseUrl/grades'));
    final data = _handle(res) as List;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> createGrade({
    required String course,
    required String studentId,
    String? assessmentId,
    required String submission,
    required int score,
    required int total,
    String? feedback,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/grades'),
      headers: _headers,
      body: jsonEncode({
        'course': course,
        'student': studentId,
        if (assessmentId != null && assessmentId.isNotEmpty)
          'assessment': assessmentId,
        'submission': submission,
        'score': score,
        'total': total,
        'feedback': feedback ?? '',
      }),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> updateGrade(
    String id, {
    required String course,
    required String studentId,
    String? assessmentId,
    required String submission,
    required int score,
    required int total,
    String? feedback,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/grades/$id'),
      headers: _headers,
      body: jsonEncode({
        'course': course,
        'student': studentId,
        if (assessmentId != null && assessmentId.isNotEmpty)
          'assessment': assessmentId,
        'submission': submission,
        'score': score,
        'total': total,
        'feedback': feedback ?? '',
      }),
    );
    return _handle(res);
  }

  static Future<void> deleteGrade(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/grades/$id'));
    _handle(res);
  }


  static Future<List<Map<String, dynamic>>> getEvents({
    String? studentId,
  }) async {
    final url = studentId != null
        ? '$baseUrl/events?student=$studentId'
        : '$baseUrl/events';
    final res = await http.get(Uri.parse(url));
    final data = _handle(res) as List;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> createEvent({
    required String title,
    required String type,
    required String date,
    String? course,
    String? section,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'type': type,
        'date': date,
        'course': course ?? '',
        'section': section ?? '',
      }),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> updateEvent(
    String id, {
    required String title,
    required String type,
    required String date,
    String? course,
    String? section,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/events/$id'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'type': type,
        'date': date,
        'course': course ?? '',
        'section': section ?? '',
      }),
    );
    return _handle(res);
  }

  static Future<void> deleteEvent(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/events/$id'));
    _handle(res);
  }


  static Future<Map<String, dynamic>> getStats({String? studentId}) async {
    final url = studentId != null
        ? '$baseUrl/stats?studentId=$studentId'
        : '$baseUrl/stats';
    final res = await http.get(Uri.parse(url));
    final data = _handle(res);
    return data as Map<String, dynamic>;
  }
}

class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        email: json['email'] ?? '',
        role: (json['role'] ?? 'STUDENT').toString(),
      );

  String get fullName => '$firstName $lastName'.trim();
}