import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/models/rent_model.dart';
import 'package:locadora_flutter/src/services/rent_service.dart';
import 'package:locadora_flutter/src/views/books/book_create.dart';
import 'package:locadora_flutter/src/views/books/book_update.dart';
import 'package:locadora_flutter/src/views/rents/rent_create.dart';
import 'package:locadora_flutter/src/views/rents/rent_update.dart';

class RentFlutter extends StatefulWidget {
  @override
  _RentFlutterState createState() => _RentFlutterState();
}

class _RentFlutterState extends State<RentFlutter> {
  late Future<List<RentModel>> rentsFuture;
  int page = 0;
  String search = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRents();
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

  void _loadRents() {
    setState(() {
      rentsFuture = RentService().fetchRents(search, page);
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
        backgroundColor: const Color.fromARGB(0, 0, 83, 94),
        title: Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Text(
            'Aluguéis',
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
                        builder: (context) => RentCreate(),
                      ),
                    );
                  },
                  child: Text('Registrar'),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: "Pesquisar Aluguel",
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
              child: FutureBuilder<List<RentModel>>(
                future: rentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar dados'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nenhum dado disponível'));
                  }

                  final rents = snapshot.data!;
                  return DataTableRent(rents: rents);
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

class DataTableRent extends StatelessWidget {
  final List<RentModel> rents;

  const DataTableRent({
    super.key,
    required this.rents,
  });

  void _showDeliveryConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Entrega"),
          content: Text("Tem certeza de que deseja entregar este livro?"),
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
                await RentService().deliveryRent(id: id, context: context);
              },
              child: Text("Entregar", style: TextStyle(color: Colors.red)),
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
                  'Locatário',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              DataColumn(
                label: Text(
                  'Livro',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              DataColumn(
                label: Text(
                  'Alugado',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              DataColumn(
                label: Text(
                  'Devolução',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              DataColumn(
                label: Text(
                  'Status',
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
            rows: rents.map((rent) {
              return DataRow(
                cells: [
                  DataCell(Text(rent.renter.name)),
                  DataCell(Text(rent.book.name)),
                  DataCell(Text(rent.rentDate)),
                  DataCell(Text(rent.deadLine)),
                  DataCell(Text(_translateStatus(rent.status))),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _showDeliveryConfirmationDialog(context, rent.id);
                          },
                          icon: Icon(Icons.bookmark_border),
                          tooltip: 'Devolver',
                          color: Colors.blueAccent,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RentUpdate(id: rent.id),
                              ),
                            );
                          },
                          icon: Icon(Icons.edit),
                          tooltip: 'Editar',
                          color: const Color.fromARGB(255, 81, 207, 146),
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
