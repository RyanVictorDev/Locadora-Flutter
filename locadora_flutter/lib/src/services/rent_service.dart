import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/api/api.dart';
import 'package:locadora_flutter/src/models/book_model.dart';
import 'dart:convert';

import 'package:locadora_flutter/src/models/publisher_model.dart';
import 'package:locadora_flutter/src/models/rent_model.dart';
import 'package:locadora_flutter/src/models/renter_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RentService {
  static const String baseURL =
      'https://locadora-ryan-back.altislabtech.com.br';

  Future<void> createRent({
    required int renterId,
    required int bookId,
    required String deadLine
  }) async {
    final url = Uri.parse('$baseURL/rent');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final body = jsonEncode({
      "renterId": renterId,
      "bookId": bookId,
      "deadLine": deadLine,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        print("Aluguel criado com sucesso!");
      } else {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        final errorMessage = responseBody['error'] ?? 'Erro desconhecido';

        throw errorMessage;
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw "Erro de conexão: ${e.message}";
      } else if (e is FormatException) {
        throw "Erro ao processar resposta do servidor.";
      } else if (e is String) {
        throw e;
      } else {
        throw "Erro inesperado: ${e.toString()}";
      }
    }
  }

  Future<List<RentModel>> fetchRents(String search, int page) async {
    final apiService = ApiService();
    final response =
        await apiService.fetchData('/rent?search=$search&page=$page&status=');

    final Map<String, dynamic> jsonData = jsonDecode(response.body);
    final List<dynamic> content = jsonData["content"];

    return content.map((value) => RentModel.fromJson(value)).toList();
  }

  Future<RentModel?> getById({required int id}) async {
    final url = Uri.parse('$baseURL/rent/$id');
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
        print(RentModel.fromJson(jsonData));
        return RentModel.fromJson(jsonData);
      } else {
        print('Erro: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      throw Exception('Erro na requisição GET: $e');
    }
  }

  Future<void> updateRent({
    required int id,
    required int renterId,
    required int bookId,
    required String deadLine,
  }) async {
    final url = Uri.parse('$baseURL/rent/update/$id');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final body = jsonEncode({
      "renterId": renterId,
      "bookId": bookId,
      "deadLine": deadLine,
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("Aluguel editado com sucesso!");
      } else {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        final errorMessage = responseBody['error'] ?? 'Erro desconhecido';

        throw errorMessage;
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw "Erro de conexão: ${e.message}";
      } else if (e is FormatException) {
        throw "Erro ao processar resposta do servidor.";
      } else if (e is String) {
        throw e;
      } else {
        throw "Erro inesperado: ${e.toString()}";
      }
    }
  }

  Future<void> deliveryRent(
      {required int id, required BuildContext context}) async {
    final url = Uri.parse('$baseURL/rent/$id');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    try {
      final response = await http.put(url, headers: headers);

      if (response.statusCode == 200) {
        print("Aluguel entregue com sucesso!");
      } else {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        final errorMessage = responseBody['error'] ?? 'Erro desconhecido';

        throw errorMessage;
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw "Erro de conexão: ${e.message}";
      } else if (e is FormatException) {
        throw "Erro ao processar resposta do servidor.";
      } else if (e is String) {
        throw e;
      } else {
        throw "Erro inesperado: ${e.toString()}";
      }
    }
  }
}
