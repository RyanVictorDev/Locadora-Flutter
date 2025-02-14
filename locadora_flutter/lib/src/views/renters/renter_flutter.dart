import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/api/api.dart';
import 'package:locadora_flutter/src/models/renter_model.dart';
import 'package:locadora_flutter/src/services/renter_service.dart';
import 'package:locadora_flutter/src/views/renters/renter_create.dart';
import 'package:locadora_flutter/src/views/renters/renter_details.dart';
import 'package:locadora_flutter/src/views/renters/renter_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RenterFlutter extends StatefulWidget {
  @override
  _RenterFlutterState createState() => _RenterFlutterState();
}

class _RenterFlutterState extends State<RenterFlutter> {
  String role = '';
  late Future<List<RenterModel>> rentersFuture;
  int page = 0;
  String search = "";
  final TextEditingController _searchController = TextEditingController();
  Map<int, bool> expandedState = {};

  @override
  void initState() {
    super.initState();
    _loadRenters();
    _loadRole();
  }

  void _loadRenters() {
    setState(() {
      rentersFuture = RenterService().fetchRenters(search, page);
    });
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? 'USER';
    });
  }

  void _updateSearch(String value) {
    setState(() {
      search = value;
      page = 0;
      _loadRenters();
    });
  }

  void _toggleExpansion(int index) {
    setState(() {
      expandedState[index] = !(expandedState[index] ?? false);
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
          children: [
            Row(
              children: [
                if (role == 'ADMIN')
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RenterCreate()),
                    ).then((value) => _loadRenters());
                  },
                  child: Text('Registrar'),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: "Pesquisar Locatário",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        search = value;
                        page = 0;
                        _loadRenters();
                      });
                    },
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
                  return ListView.builder(
                    itemCount: renters.length,
                    itemBuilder: (context, index) {
                      final renter = renters[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(renter.name,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(renter.email),
                            trailing: Icon(expandedState[index] == true
                                ? Icons.expand_less
                                : Icons.expand_more),
                            onTap: () => _toggleExpansion(index),
                          ),
                          if (expandedState[index] == true)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
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
                                              RenterDetails(id: renter.id),
                                        ),
                                      );
                                    },
                                  ),
                                  if (role == 'ADMIN')
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.green),
                                    tooltip: 'Editar',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RenterUpdate(id: renter.id),
                                        ),
                                      ).then((value) => _loadRenters());
                                    },
                                  ),
                                  if (role == 'ADMIN')
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Excluir',
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(
                                          context, renter.id);
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
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: page > 0
                      ? _previousPage
                      : null, // Desabilita o botão de voltar se estiver na página 0
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
                try {
                  await RenterService().deleteRenter(id: id, context: context);
                  Navigator.of(context).pop();
                  _loadRenters();
                } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())),
                  );
                }

              },
              child: Text("Excluir", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
