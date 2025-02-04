import 'dart:convert';
import 'package:locadora_flutter/src/models/book_model.dart';
import 'package:locadora_flutter/src/models/renter_model.dart';

class RentModel {
  final int id;
  final RenterModel renter;
  final BookModel book;
  final String deadLine;
  final String rentDate;
  final String status;

  RentModel({
    required this.id,
    required this.renter,
    required this.book,
    required this.deadLine,
    required this.rentDate,
    required this.status,
  });

  factory RentModel.fromJson(Map<String, dynamic> json) {
    return RentModel(
      id: json['id'],
      renter: RenterModel.fromJson(json['renter']),
      book: BookModel.fromJson(json['book']),
      deadLine: json['deadLine'],
      rentDate: json['rentDate'],
      status: json['status'],
    );
  }

  static List<RentModel> fromJsonList(String jsonStr) {
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((json) => RentModel.fromJson(json)).toList();
  }
}
