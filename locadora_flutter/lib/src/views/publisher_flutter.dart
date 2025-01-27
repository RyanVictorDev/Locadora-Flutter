import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/api/api.dart';
import 'package:locadora_flutter/src/models/publisher_model.dart';
import 'package:locadora_flutter/src/views/dashboard_flutter.dart';

class PublisherFlutter extends StatefulWidget {
  @override
  _PublisherFlutterState createState() => _PublisherFlutterState();
}

class _PublisherFlutterState extends State<PublisherFlutter> {
  late Future<List<PublisherModel>> publishersFuture;

  @override
  void initState() {
    super.initState();
    publishersFuture = fetchPublishers();
  }

  Future<List<PublisherModel>> fetchPublishers() async {
    final apiService = ApiService();
    final response = await apiService.fetchData('/publisher?search=');

    final List<dynamic> jsonData = jsonDecode(response.body);

    return jsonData.map((value) => PublisherModel.fromJson(value)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 0, 83, 94),
        title: Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Text(
          'Publisher', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
          ),
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<PublisherModel>>(
          future: publishersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar dados'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Nenhum dado disponível'));
            }

            final publishers = snapshot.data!;
            return DataTablePublisher(publishers: publishers);
          },
        ),
      ),
    );
  }
}

class DataTablePublisher extends StatelessWidget {
  final List<PublisherModel> publishers;

  const DataTablePublisher({super.key, required this.publishers});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 218, 218, 218),
        ),
        columns: const [
          DataColumn(
            label: Text(
              'Nome',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          DataColumn(
            label: Text(
              'Email',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          DataColumn(
            label: Text(
              'Telefone',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          DataColumn(
            label: Text(
              'Ações',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        rows: publishers.map((publisher) {
          return DataRow(
            cells: [
              DataCell(Text(publisher.name)),
              DataCell(Text(publisher.email)),
              DataCell(Text(publisher.telephone)),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DashboardFlutter(),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      onPressed: () {
                        // Aqui pode ser adicionada lógica para exclusão
                        print('Excluir publisher: ${publisher.name}');
                      },
                      icon: Icon(Icons.delete),
                      tooltip: 'Excluir',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
