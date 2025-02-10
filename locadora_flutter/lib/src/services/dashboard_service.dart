import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/api/api.dart';
import 'package:locadora_flutter/src/models/book_model.dart';
import 'package:locadora_flutter/src/models/more_rented_book_model.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DashboardService {
  static const String baseURL =
      'https://locadora-ryan-back.altislabtech.com.br';

  Future<int> getRentsQuantity({required int numberOfMonths}) async {
    try {
      final apiService = ApiService();
      final response = await apiService
          .fetchData('/dashboard/rentsQuantity?numberOfMonths=$numberOfMonths');

      print("Resposta da API: ${response.body}");

      final dynamic jsonData = jsonDecode(response.body);

      if (jsonData is int) {
        return jsonData;
      }

      throw Exception("Formato inesperado da resposta: $jsonData");
    } catch (e) {
      print("Erro ao obter quantidade de aluguéis: $e");
      return 9999;
    }
  }

  Future<int> getRentsLateQuantity({required int numberOfMonths}) async {
    try {
      final apiService = ApiService();
      final response = await apiService
          .fetchData('/dashboard/rentsLateQuantity?numberOfMonths=$numberOfMonths');

      print("Resposta da API: ${response.body}");

      final dynamic jsonData = jsonDecode(response.body);

      if (jsonData is int) {
        return jsonData;
      }

      throw Exception("Formato inesperado da resposta: $jsonData");
    } catch (e) {
      print("Erro ao obter quantidade de aluguéis atrasados: $e");
      return 9999;
    }
  }

  Future<int> getDeliveredInTimeQuantity({required int numberOfMonths}) async {
    try {
      final apiService = ApiService();
      final response = await apiService.fetchData('/dashboard/deliveredInTimeQuantity?numberOfMonths=$numberOfMonths');

      print("Resposta da API: ${response.body}");

      final dynamic jsonData = jsonDecode(response.body);

      if (jsonData is int) {
        return jsonData;
      }

      throw Exception("Formato inesperado da resposta: $jsonData");
    } catch (e) {
      print("Erro ao obter quantidade de aluguéis atrasados: $e");
      return 9999;
    }
  }

  Future<int> getDeliveredWithDelayQuantity({required int numberOfMonths}) async {
    try {
      final apiService = ApiService();
      final response = await apiService.fetchData('/dashboard/deliveredWithDelayQuantity?numberOfMonths=$numberOfMonths');

      print("Resposta da API: ${response.body}");

      final dynamic jsonData = jsonDecode(response.body);

      if (jsonData is int) {
        return jsonData;
      }

      throw Exception("Formato inesperado da resposta: $jsonData");
    } catch (e) {
      print("Erro ao obter quantidade de aluguéis atrasados: $e");
      return 9999;
    }
  }

Future<List<MoreRentedBookModel>> getMostRentedBooks({required int numberOfMonths}) async {
  try {
    final apiService = ApiService();
    final response = await apiService.fetchData('/dashboard/bookMoreRented?numberOfMonths=$numberOfMonths');

    print("Resposta da API: ${response.body}");

    final dynamic jsonData = jsonDecode(response.body);

    if (jsonData is List) {
      return MoreRentedBookModel.fromJsonList(response.body);
    }

    throw Exception("Formato inesperado da resposta: $jsonData");
  } catch (e) {
    print("Erro ao obter livros mais alugados: $e");
    return []; 
  }
}
}
