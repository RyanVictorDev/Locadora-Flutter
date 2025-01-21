import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // URL base da API
  static const String baseURL = 'https://locadora-ryan-back.altislabtech.com.br';

  // Função para autenticação
  Future<void> authenticate(String username, String password) async {
    final url = Uri.parse('$baseURL/auth/login');
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "email": username,
      "password": password,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final role = data['role'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);
          await prefs.setString('role', role);
        }
      } else {
        throw Exception(
            'Erro na autenticação: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro na autenticação: $e');
    }
  }

  // Função para requisições GET com token
  Future<http.Response> fetchData(String endpoint) async {
    final url = Uri.parse('$baseURL$endpoint');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(
            'Erro na requisição GET: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro na requisição GET: $e');
    }
  }
}
