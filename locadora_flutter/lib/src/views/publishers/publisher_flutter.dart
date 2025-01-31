import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/api/api.dart';
import 'package:locadora_flutter/src/models/publisher_model.dart';
import 'package:locadora_flutter/src/services/publisher_service.dart';
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
  String search = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPublishers();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _loadPublishers() {
    setState(() {
      publishersFuture = PublisherService().fetchPublishers(search, page);
    });
  }

    void _updateSearch(String value) {
    setState(() {
      search = value;
      page = 0;
      _loadPublishers();
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
            Row(
              children: [
                SizedBox(width: 10),
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
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: "Pesquisar Locatário",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: _updateSearch,
                  ),
                ),
              ],
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
                  return DataTablePublisher(
                    publishers: publishers,
                  );
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

  const DataTablePublisher({
    super.key,
    required this.publishers,
  });

  void _showDeleteConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Exclusão"),
          content: Text("Tem certeza de que deseja excluir esta editora?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await PublisherService().deletePublisher(id: id, context: context);
              },
              child: Text("Excluir", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

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
                            _showDeleteConfirmationDialog(
                                context, publisher.id);
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
