import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/api/api.dart';
import 'package:locadora_flutter/src/models/publisher_model.dart';

class DashboardFlutter extends StatefulWidget {
  @override
  _DashboardFlutterState createState() => _DashboardFlutterState();
}

class _DashboardFlutterState extends State<DashboardFlutter> {
  late List<PublisherModel> _publishersFuture;

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
        leading: Icon(Icons.menu, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 0, 83, 94),
        title: Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<PublisherModel>>(
          future: fetchPublishers(),
          builder: (context, snapshot) {
            print(snapshot);

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));

              } else if (snapshot.hasData) {
                final models = snapshot.data!;

                return ListView.builder(
                  itemCount: models.length,
                  itemBuilder: (context, index) {
                    final model = models[index];
                    return Row(
                      children: [
                        Text(model.name, style: TextStyle(color: Colors.amber),),
                        SizedBox(width:16.0),
                        Text(model.email)
                      ],
                    );
                  },
                );
              } else {
                return Center(child: Text('Nenhum dado disponível.'));
              }
            }
        ),
      ),
    );
  }
}
