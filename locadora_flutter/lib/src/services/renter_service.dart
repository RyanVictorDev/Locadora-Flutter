import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/api/api.dart';
import 'dart:convert';

import 'package:locadora_flutter/src/models/publisher_model.dart';
import 'package:locadora_flutter/src/models/renter_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RenterService {
  static const String baseURL = 'https://locadora-ryan-back.altislabtech.com.br';

  Future<void> createRenter({
    required String name,
    required String email,
    required String telephone,
    required String address,
    required String cpf,
  }) async {
    final url = Uri.parse('$baseURL/renter');
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
      "address": address,
      "cpf": cpf,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        print("Locatario criado com sucesso!");
      } else {
        print(
            'Erro ao criar locatario: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro na requisição POST: $e');
    }
  }

  Future<List<RenterModel>> fetchRenters(String search, int page) async {
    final apiService = ApiService();
    final response =
        await apiService.fetchData('/renter?search=$search&page=$page');

    final Map<String, dynamic> jsonData = jsonDecode(response.body);
    final List<dynamic> content = jsonData["content"];

    return content.map((value) => RenterModel.fromJson(value)).toList();
  }

  Future<List<RenterModel>> fetchAllRenters(String search) async {
    final apiService = ApiService();
    final response =
        await apiService.fetchData('/renter?search=$search');

    final dynamic jsonData = jsonDecode(response.body);

    final List<dynamic> content = jsonData is List ? jsonData : jsonData["content"];

    return content.map((value) => RenterModel.fromJson(value)).toList();
  }

  Future<RenterModel?> getById({required int id}) async {
    final url = Uri.parse('$baseURL/renter/$id');
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
        print(RenterModel.fromJson(jsonData));
        return RenterModel.fromJson(jsonData);

      } else {
        print('Erro: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      throw Exception('Erro na requisição GET: $e');
    }
  }

  Future<void> updateRenter({
    required int id,
    required String name,
    required String email,
    required String telephone,
    required String address,
    required String cpf,
  }) async {
    final url = Uri.parse('$baseURL/renter/$id');
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
      "address": address,
      "cpf": cpf,
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("Locatario editado com sucesso!");
      } else {
        print('Erro ao editar locatario: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro na requisição POST: $e');
    }
  }

  Future<bool> deleteRenter(
      {required int id, required BuildContext context}) async {
    final url = Uri.parse('$baseURL/renter/$id');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Locatario excluído com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro na requisição DELETE: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}
