import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/api/api.dart';
import 'package:locadora_flutter/src/models/publisher_model.dart';

class DashboardFlutter extends StatefulWidget {
  @override
  _DashboardFlutterState createState() => _DashboardFlutterState();
}

class _DashboardFlutterState extends State<DashboardFlutter> {
  Future<List<PublisherModel>> fetchPublishers() async {
    final apiService = ApiService();
    final response = await apiService.fetchData('/publisher?search=');

    final List<dynamic> jsonData = jsonDecode(response.body);

    final List<PublisherModel> data =
        jsonData.map((value) => PublisherModel.fromJson(value)).toList();

    return data;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(0, 0, 83, 94),
          title: Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Text('Dashboard',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)
            ),
          )
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('algo'),
      ),
    );
  }
}
