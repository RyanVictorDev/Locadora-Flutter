import 'dart:convert';

class MoreRentedBookModel {
  final String name;
  final int totalRents;

  MoreRentedBookModel({
    required this.name,
    required this.totalRents,
  });

  factory MoreRentedBookModel.fromJson(Map<String, dynamic> json) {
    return MoreRentedBookModel(
      name: json['name'],
      totalRents: json['totalRents'],
    );
  }

  static List<MoreRentedBookModel> fromJsonList(String jsonStr) {
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((json) => MoreRentedBookModel.fromJson(json)).toList();
  }
}
