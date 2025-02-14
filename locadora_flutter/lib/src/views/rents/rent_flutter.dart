import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/models/rent_model.dart';
import 'package:locadora_flutter/src/services/rent_service.dart';
import 'package:locadora_flutter/src/views/rents/rent_create.dart';
import 'package:locadora_flutter/src/views/rents/rent_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RentFlutter extends StatefulWidget {
  @override
  _RentFlutterState createState() => _RentFlutterState();
}

class _RentFlutterState extends State<RentFlutter> {
  String role = '';
  late Future<List<RentModel>> rentsFuture;
  int page = 0;
  String search = "";
  final TextEditingController _searchController = TextEditingController();
  Map<int, bool> expandedState = {};

  @override
  void initState() {
    super.initState();
    _loadRents();
    _loadRole();
  }

  void _loadRents() {
    setState(() {
      rentsFuture = RentService().fetchRents(search, page);
    });
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? 'USER';
    });
  }

  void _toggleExpansion(int index) {
    setState(() {
      expandedState[index] = !(expandedState[index] ?? false);
    });
  }

  void _updateSearch(String value) {
    setState(() {
      search = value;
      page = 0;
      _loadRents();
    });
  }

  void _nextPage() {
    setState(() {
      page += 1;
      _loadRents();
    });
  }

  void _previousPage() {
    if (page > 0) {
      setState(() {
        page -= 1;
        _loadRents();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Text(
            'Alugueis',
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
                      MaterialPageRoute(builder: (context) => RentCreate()),
                    ).then((value) => _loadRents());
                  },
                  child: Text('Registrar'),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: "Pesquisar Aluguel",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        search = value;
                        page = 0;
                        _loadRents();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<RentModel>>(
                future: rentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar dados'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nenhum aluguel encontrado'));
                  }

                  final rents = snapshot.data!;
                  return ListView.builder(
                    itemCount: rents.length,
                    itemBuilder: (context, index) {
                      final rent = rents[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(rent.renter.name,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Livro: ${rent.book.name}"),
                                Text("Alugado: ${rent.rentDate}"),
                                Text("Devolução: ${rent.deadLine}"),
                                Text("Status: ${_translateStatus(rent.status)}"),
                              ],
                            ),
                            trailing: Icon(expandedState[index] == true
                                ? Icons.expand_less
                                : Icons.expand_more),
                            onTap: () => _toggleExpansion(index),
                          ),
                          if (expandedState[index] == true &&
                              rent.status == 'RENTED' || rent.status == 'LATE' && role == 'ADMIN')
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.bookmark_border,
                                        color: Colors.blueAccent),
                                    tooltip: 'Devolver',
                                    onPressed: () =>
                                        _showDeliveryConfirmationDialog(
                                            context, rent.id),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.green),
                                    tooltip: 'Editar',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RentUpdate(id: rent.id),
                                        ),
                                      ).then((value) => _loadRents());
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
                        ? () => setState(() {
                              page -= 1;
                              _loadRents();
                            })
                        : null,
                    child: Text('<')),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        page += 1;
                        _loadRents();
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

  void _showDeliveryConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Entrega"),
          content: Text("Tem certeza de que deseja entregar este livro?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await RentService().deliveryRent(id: id, context: context);
                  Navigator.of(context).pop();
                  _loadRents();
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: Text("Entregar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'RENTED':
        return 'Alugado';
      case 'IN_TIME':
        return 'Devolvido no prazo';
      case 'LATE':
        return 'Atrasado';
      case 'DELIVERED_WITH_DELAY':
        return 'Devolvido fora do prazo';
      default:
        return status;
    }
  }
}
