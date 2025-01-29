import 'package:locadora_flutter/src/api/api.dart';
import 'dart:convert';

import 'package:locadora_flutter/src/models/publisher_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PublisherService {
  static const String baseURL = 'https://locadora-ryan-back.altislabtech.com.br';

  Future<void> createPublisher({
    required String name,
    required String email,
    required int telephone,
    required String site,
  }) async {
    final url = Uri.parse('$baseURL/publisher');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final body = jsonEncode({
      "name": name,
      "email": email,
      "telephone": telephone,
      "site": site,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        print("Publisher criado com sucesso!");
      } else {
        print(
            'Erro ao criar publisher: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro na requisição POST: $e');
    }
  }

  Future<List<PublisherModel>> fetchPublishers(String search, int page) async {
    final apiService = ApiService();
    final response = await apiService.fetchData('/publisher?search=$search&page=$page');

    final Map<String, dynamic> jsonData = jsonDecode(response.body);
    final List<dynamic> content = jsonData["content"];

    return content.map((value) => PublisherModel.fromJson(value)).toList();
  }

  Future<PublisherModel?> getById({required int id}) async {
    final url = Uri.parse('$baseURL/publisher/$id');
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
        print(PublisherModel.fromJson(jsonData));
        return PublisherModel.fromJson(jsonData);
      } else {
        print('Erro: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      throw Exception('Erro na requisição GET: $e');
    }
  }

  Future<void> updatePublisher({
    required int id,
    required String name,
    required String email,
    required int telephone,
    required String site,
  }) async {
    final url = Uri.parse('$baseURL/publisher/$id');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final body = jsonEncode({
      "name": name,
      "email": email,
      "telephone": telephone,
      "site": site,
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("Editora editada com sucesso!");
      } else {
        print(
            'Erro ao editar editora: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro na requisição POST: $e');
    }
  }

}