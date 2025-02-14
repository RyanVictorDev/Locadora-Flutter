import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PasswordRecoverService {
  static const String baseURL =
      'https://locadora-ryan-back.altislabtech.com.br';

  Future<void> emailSend({
    required String email
  }) async {
    final url = Uri.parse('$baseURL/api/forgot');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final body = jsonEncode({
      "email": email,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("Sucesso!");
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

  Future<void> resetPassword({required String newPassword, required String Token}) async {
    final url = Uri.parse('$baseURL/api/reset-password');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final body = jsonEncode({
      "newPassword": newPassword,
      "token": Token,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("Sucesso!");
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
