import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/api/api.dart';
import 'package:locadora_flutter/src/models/renter_model.dart';
import 'package:locadora_flutter/src/services/renter_service.dart';
import 'package:locadora_flutter/src/views/renters/renter_create.dart';
import 'package:locadora_flutter/src/views/renters/renter_details.dart';
import 'package:locadora_flutter/src/views/renters/renter_update.dart';

class RenterFlutter extends StatefulWidget {
  @override
  _RenterFlutterState createState() => _RenterFlutterState();
}

class _RenterFlutterState extends State<RenterFlutter> {
  late Future<List<RenterModel>> rentersFuture;
  int page = 0;
  String search = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRenters();
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

  void _loadRenters() {
    setState(() {
      rentersFuture = RenterService().fetchRenters(search, page);
    });
  }

  void _updateSearch(String value) {
    setState(() {
      search = value;
      page = 0;
      _loadRenters();
    });
  }

  void _nextPage() {
    setState(() {
      page += 1;
      _loadRenters();
    });
  }

  void _previousPage() {
    if (page > 0) {
      setState(() {
        page -= 1;
        _loadRenters();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 0, 83, 94),
        title: Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Text(
            'Locatários',
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
                        builder: (context) => RenterCreate(),
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
              child: FutureBuilder<List<RenterModel>>(
                future: rentersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar dados'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nenhum dado disponível'));
                  }

                  final renters = snapshot.data!;
                  return DataTableRenter(renters: renters);
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

class DataTableRenter extends StatelessWidget {
  final List<RenterModel> renters;

  const DataTableRenter({
    super.key,
    required this.renters,
  });

  void _showDeleteConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Exclusão"),
          content: Text("Tem certeza de que deseja excluir este locatário?"),
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
                await RenterService().deleteRenter(id: id, context: context);
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
            rows: renters.map((renter) {
              return DataRow(
                cells: [
                  DataCell(Text(renter.name)),
                  DataCell(Text(renter.email)),
                  DataCell(Text(renter.telephone)),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RenterDetails(id: renter.id),
                              ),
                            );
                          },
                          icon: Icon(Icons.visibility),
                          tooltip: 'Ver mais',
                          color: Colors.blueAccent,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RenterUpdate(id: renter.id),
                              ),
                            );
                          },
                          icon: Icon(Icons.edit),
                          tooltip: 'Editar',
                          color: const Color.fromARGB(255, 81, 207, 146),
                        ),
                        IconButton(
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, renter.id);
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
