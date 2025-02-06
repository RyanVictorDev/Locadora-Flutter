import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/api/api.dart';
import 'dart:convert';

import 'package:locadora_flutter/src/models/publisher_model.dart';
import 'package:locadora_flutter/src/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseURL =
      'https://locadora-ryan-back.altislabtech.com.br';

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('$baseURL/user');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final body = jsonEncode({
      "name": name,
      "email": email,
      "password": password,
      "role": role,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        print("Usuario criado com sucesso!");
      } else {
        print(
            'Erro ao criar usuario: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro na requisição POST: $e');
    }
  }

  Future<List<UserModel>> fetchUsers(String search, int page) async {
    final apiService = ApiService();
    final response =
        await apiService.fetchData('/user?search=$search&page=$page&role=');

    final Map<String, dynamic> jsonData = jsonDecode(response.body);
    final List<dynamic> content = jsonData["content"];

    return content.map((value) => UserModel.fromJson(value)).toList();
  }

  Future<List<UserModel>> fetchAllUsers(String search) async {
    final apiService = ApiService();
    final response = await apiService.fetchData('/user?search=$search');

    final dynamic jsonData = jsonDecode(response.body);

    final List<dynamic> content =
        jsonData is List ? jsonData : jsonData["content"];

    return content.map((value) => UserModel.fromJson(value)).toList();
  }

  Future<UserModel?> getById({required int id}) async {
    final url = Uri.parse('$baseURL/user/$id');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        print("sucesso!");

        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        print(UserModel.fromJson(jsonData));
        return UserModel.fromJson(jsonData);
      } else {
        print('Erro: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      throw Exception('Erro na requisição GET: $e');
    }
  }

  Future<void> updateUser({
    required int id,
    required String name,
    required String email,
    required String role,
  }) async {
    final url = Uri.parse('$baseURL/user/$id');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final body = jsonEncode({
      "name": name,
      "email": email,
      "role": role,
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("Usuario editada com sucesso!");
      } else {
        print(
            'Erro ao editar usuario: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro na requisição POST: $e');
    }
  } 
}
