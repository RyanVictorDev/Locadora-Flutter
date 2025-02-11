import 'dart:convert';

class RentsPerRentersModel {
  final String name;
  final int rentsQuantity;
  final int rentsActive;

  RentsPerRentersModel({
    required this.name,
    required this.rentsQuantity, 
    required this.rentsActive
  });

  factory RentsPerRentersModel.fromJson(Map<String, dynamic> json) {
    return RentsPerRentersModel(
      name: json['name'],
      rentsQuantity: json['rentsQuantity'],
      rentsActive: json['rentsActive'],
    );
  }

  static List<RentsPerRentersModel> fromJsonList(String jsonStr) {
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((json) => RentsPerRentersModel.fromJson(json)).toList();
  }
}