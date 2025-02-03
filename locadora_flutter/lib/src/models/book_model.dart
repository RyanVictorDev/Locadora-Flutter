import 'dart:convert';
import 'publisher_model.dart';

class BookModel {
  final int id;
  final String name;
  final String author;
  final String launchDate;
  final int totalQuantity;
  final int totalInUse;
  final PublisherModel publisher;

  BookModel({
    required this.id,
    required this.name,
    required this.author,
    required this.launchDate,
    required this.totalQuantity,
    required this.totalInUse,
    required this.publisher,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      name: json['name'],
      author: json['author'],
      launchDate: json['launchDate'],
      totalQuantity: json['totalQuantity'],
      totalInUse: json['totalInUse'],
      publisher: PublisherModel.fromJson(json['publisher']),
    );
  }

  static List<BookModel> fromJsonList(String jsonStr) {
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((json) => BookModel.fromJson(json)).toList();
  }
}