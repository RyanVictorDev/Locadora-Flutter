import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/api/api.dart';
import 'package:locadora_flutter/src/models/publisher_model.dart';
import 'package:locadora_flutter/src/services/publisher_service.dart';
import 'package:locadora_flutter/src/views/dashboard_flutter.dart';
import 'package:locadora_flutter/src/views/publishers/publisher_create.dart';
import 'package:locadora_flutter/src/views/publishers/publisher_details.dart';
import 'package:locadora_flutter/src/views/publishers/publisher_update.dart';

class PublisherFlutter extends StatefulWidget {
  @override
  _PublisherFlutterState createState() => _PublisherFlutterState();
}

class _PublisherFlutterState extends State<PublisherFlutter> {
  late Future<List<PublisherModel>> publishersFuture;
  int page = 0;
  final String search = "";

  @override
  void initState() {
    super.initState();
    _loadPublishers();
  }

  void _loadPublishers() {
    setState(() {
      publishersFuture = PublisherService().fetchPublishers(search, page);
    });
  }

  void _nextPage() {
    setState(() {
      page += 1; 
      _loadPublishers(); 
    });
  }

  void _previousPage() {
    setState(() {
      page -= 1;
      _loadPublishers();
    });
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
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PublisherCreate(),
                  ),
                );
              },
              child: Text('Registrar'),
            ),
            SizedBox(height: 10),
            Expanded(
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
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _previousPage,
                  child: Text('<'),
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  child: Text('>'),
                ),
              ],
            ),
          ],
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
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 231, 231, 231),
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
                                builder: (context) =>
                                    PublisherDetails(id: publisher.id),
                              ),
                            );
                          },
                          icon: Icon(Icons.visibility),
                          tooltip: 'Ver mais',
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PublisherUpdate(id: publisher.id),
                              ),
                            );
                          },
                          icon: Icon(Icons.edit),
                          tooltip: 'Editar',
                        ),
                        IconButton(
                          onPressed: () {
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
        ),
      ),
    );
  }
}
