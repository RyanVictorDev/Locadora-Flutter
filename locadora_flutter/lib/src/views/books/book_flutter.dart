import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/api/api.dart';
import 'package:locadora_flutter/src/models/book_model.dart';
import 'package:locadora_flutter/src/models/renter_model.dart';
import 'package:locadora_flutter/src/services/book_service.dart';
import 'package:locadora_flutter/src/services/renter_service.dart';
import 'package:locadora_flutter/src/views/books/book_create.dart';
import 'package:locadora_flutter/src/views/books/book_details.dart';
import 'package:locadora_flutter/src/views/books/book_update.dart';
import 'package:locadora_flutter/src/views/renters/renter_create.dart';
import 'package:locadora_flutter/src/views/renters/renter_details.dart';
import 'package:locadora_flutter/src/views/renters/renter_update.dart';

class BookFlutter extends StatefulWidget {
  @override
  _BookFlutterState createState() => _BookFlutterState();
}

class _BookFlutterState extends State<BookFlutter> {
  late Future<List<BookModel>> booksFuture;
  int page = 0;
  String search = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBooks();
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

  void _loadBooks() {
    setState(() {
      booksFuture = BookService().fetchBooks(search, page);
    });
  }

  void _updateSearch(String value) {
    setState(() {
      search = value;
      page = 0;
      _loadBooks();
    });
  }

  void _nextPage() {
    setState(() {
      page += 1;
      _loadBooks();
    });
  }

  void _previousPage() {
    if (page > 0) {
      setState(() {
        page -= 1;
        _loadBooks();
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
            'Livros',
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
                        builder: (context) => BookCreate(),
                      ),
                    );
                  },
                  child: Text('Registrar'),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: "Pesquisar Livro",
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
              child: FutureBuilder<List<BookModel>>(
                future: booksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar dados'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nenhum dado disponível'));
                  }

                  final books = snapshot.data!;
                  return DataTableBook(books: books);
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

class DataTableBook extends StatelessWidget {
  final List<BookModel> books;

  const DataTableBook({
    super.key,
    required this.books,
  });

  void _showDeleteConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Exclusão"),
          content: Text("Tem certeza de que deseja excluir este livro?"),
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
                await BookService().deleteBook(id: id, context: context);
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
                  'Autor',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              DataColumn(
                label: Text(
                  'Disponíveis',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              DataColumn(
                label: Text(
                  'Alugados',
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
            rows: books.map((book) {
              return DataRow(
                cells: [
                  DataCell(Text(book.name)),
                  DataCell(Text(book.author)),
                  DataCell(Text(book.totalQuantity.toString())),
                  DataCell(Text(book.totalInUse.toString())),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookDetails(id: book.id),
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
                                    BookUpdate(id: book.id),
                              ),
                            );
                          },
                          icon: Icon(Icons.edit),
                          tooltip: 'Editar',
                          color: const Color.fromARGB(255, 81, 207, 146),
                        ),
                        IconButton(
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, book.id);
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
