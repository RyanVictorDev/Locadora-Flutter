import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/api/api.dart';
import 'package:locadora_flutter/src/models/book_model.dart';
import 'dart:convert';

import 'package:locadora_flutter/src/models/publisher_model.dart';
import 'package:locadora_flutter/src/models/renter_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BookService {
  static const String baseURL =
      'https://locadora-ryan-back.altislabtech.com.br';

  Future<void> createBook({
    required String name,
    required String author,
    required String launchDate,
    required int totalQuantity,
    required int publisherId,
  }) async {
    final url = Uri.parse('$baseURL/book');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final body = jsonEncode({
      "name": name,
      "author": author,
      "launchDate": launchDate,
      "totalQuantity": totalQuantity,
      "publisherId": publisherId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        print("Livro criado com sucesso!");
      } else {
        print('Erro ao criar livro: ${response.statusCode} - ${response.body} - $body');
      }
    } catch (e) {
      throw Exception('Erro na requisição POST: $e');
    }
  }

  Future<List<BookModel>> fetchBooks(String search, int page) async {
    final apiService = ApiService();
    final response =
        await apiService.fetchData('/book?search=$search&page=$page');

    final Map<String, dynamic> jsonData = jsonDecode(response.body);
    final List<dynamic> content = jsonData["content"];

    return content.map((value) => BookModel.fromJson(value)).toList();
  }

  Future<BookModel?> getById({required int id}) async {
    final url = Uri.parse('$baseURL/book/$id');
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
        print(BookModel.fromJson(jsonData));
        return BookModel.fromJson(jsonData);
      } else {
        print('Erro: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      throw Exception('Erro na requisição GET: $e');
    }
  }

  Future<void> updateBook({
    required int id,
    required String name,
    required String author,
    required String launchDate,
    required int totalQuantity,
    required int publisherId,
  }) async {
    final url = Uri.parse('$baseURL/book/$id');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final body = jsonEncode({
      "name": name,
      "author": author,
      "launchDate": launchDate,
      "totalQuantity": totalQuantity,
      "publisherId": publisherId,
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("Livro editado com sucesso!");
      } else {
        print(
            'Erro ao editar livro: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro na requisição POST: $e');
    }
  }

  Future<bool> deleteBook(
      {required int id, required BuildContext context}) async {
    final url = Uri.parse('$baseURL/book/$id');
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
            content: Text("Livro excluído com sucesso!"),
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
