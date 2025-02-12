import 'package:flutter/material.dart';
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
  Map<int, bool> expandedState = {};

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

  void _toggleExpansion(int index) {
    setState(() {
      expandedState[index] = !(expandedState[index] ?? false);
    });
  }

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
                _loadPublishers();
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
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Text(
            'Editoras',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PublisherCreate()),
                    ).then((value) => _loadPublishers());
                  },
                  child: Text('Registrar'),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: "Pesquisar Editora",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        search = value;
                        page = 0;
                        _loadPublishers();
                      });
                    },
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
                  return ListView.builder(
                    itemCount: publishers.length,
                    itemBuilder: (context, index) {
                      final publisher = publishers[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(publisher.name,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(publisher.email),
                            trailing: Icon(expandedState[index] == true
                                ? Icons.expand_less
                                : Icons.expand_more),
                            onTap: () => _toggleExpansion(index),
                          ),
                          if (expandedState[index] == true)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.visibility,
                                        color: Colors.blueAccent),
                                    tooltip: 'Ver mais',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PublisherDetails(
                                                  id: publisher.id),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.green),
                                    tooltip: 'Editar',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PublisherUpdate(id: publisher.id),
                                        ),
                                      ).then((value) => _loadPublishers());
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Excluir',
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(
                                          context, publisher.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          Divider(),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: page > 0
                        ? () => setState(() {
                              page -= 1;
                              _loadPublishers();
                            })
                        : null,
                    child: Text('<')),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        page += 1;
                        _loadPublishers();
                      });
                    },
                    child: Text('>')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
