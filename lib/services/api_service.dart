import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dish.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.29.130:3000/api'; // For Android emulator

  Future<http.Response> registerUser(String username, String email, 
      String mobileNumber, String password) async {
    return await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'mobileNumber': mobileNumber,
        'password': password
      }),
    );
  }

  Future<http.Response> login(String identifier, String password) async {
    return await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': identifier.contains('@') ? identifier : null,
        'mobileNumber': identifier.contains('@') ? null : identifier,
        'password': password
      }),
    );
  }


Future<List<Dish>> getDishes() async {
  try {
    final Uri uri = Uri.parse('$baseUrl/dishes');

    log('Fetching dishes from: ${uri.toString()}'); // Removed "as num"
    final response = await http.get(uri);

    log('Response status: ${response.statusCode}'); // Removed "as num"
    log('Response body: ${response.body}'); // Removed "as num"

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isEmpty) {
        log('Received empty dishes list'); // Removed "as num"
        return [];
      }
      return data.map((json) => Dish.fromJson(json)).toList();
    } else {
      log('Error response: ${response.body}'); // Removed "as num"
      throw Exception('Failed to load dishes: ${response.statusCode}');
    }
  } on FormatException catch (e) {
    log('JSON decoding error: $e'); // Removed "as num"
    throw Exception('Invalid data format received');
  } on http.ClientException catch (e) {
    log('Network error: $e'); // Removed "as num"
    throw Exception('Network error: Check your connection');
  } catch (e) {
    log('Unexpected error: $e'); // Removed "as num"
    throw Exception('Failed to load dishes: $e');
  }
}

  Future<Dish> getDishDetails(int dishId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dishes/$dishId'),
    );
    
    if (response.statusCode == 200) {
      return Dish.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dish details');
    }
  }

  Future<http.Response> addDish(
    String title,
    String description,
    String category,
    File image,
    String token,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/dishes'),
    );
    
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['category'] = category;
    request.files.add(
      await http.MultipartFile.fromPath('image', image.path),
    );

    return await http.Response.fromStream(await request.send());
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}