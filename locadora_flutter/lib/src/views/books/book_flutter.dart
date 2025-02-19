import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/components/app_title.dart';
import 'package:locadora_flutter/src/enum/enum_role.dart';
import 'package:locadora_flutter/src/models/book_model.dart';
import 'package:locadora_flutter/src/models/user_model.dart';
import 'package:locadora_flutter/src/services/book_service.dart';
import 'package:locadora_flutter/src/views/books/book_create.dart';
import 'package:locadora_flutter/src/views/books/book_details.dart';
import 'package:locadora_flutter/src/views/books/book_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookFlutter extends StatefulWidget {
  @override
  _BookFlutterState createState() => _BookFlutterState();
}

class _BookFlutterState extends State<BookFlutter> {
  String role = '';
  late Future<List<BookModel>> booksFuture;
  int page = 0;
  String search = "";
  final TextEditingController _searchController = TextEditingController();
  Map<int, bool> expandedState = {};

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _loadRole();
  }

  void _loadBooks() {
    setState(() {
      booksFuture = BookService().fetchBooks(search, page);
    });
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? EnumRole.USER.name;
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
          content: Text("Tem certeza de que deseja excluir este livro?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await BookService().deleteBook(id: id, context: context);
                  Navigator.of(context).pop();
                  _loadBooks();
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())),);
                }
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
        title: AppTitle(title: 'Livros')
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                if (role == EnumRole.ADMIN.name)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookCreate()),
                    ).then((value) => _loadBooks());
                  },
                  child: Text('Registrar'),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: "Pesquisar Livro",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        search = value;
                        page = 0;
                        _loadBooks();
                      });
                    },
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
                  return ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(book.name,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(book.author),
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
                                                BookDetails(id: book.id)),
                                      );
                                    },
                                  ),
                                  if (role == EnumRole.ADMIN.name)
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.green),
                                    tooltip: 'Editar',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BookUpdate(id: book.id)),
                                      ).then((value) => _loadBooks());
                                    },
                                  ),
                                  if (role == EnumRole.ADMIN.name)
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Excluir',
                                    onPressed: () =>
                                        _showDeleteConfirmationDialog(
                                            context, book.id),
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
                            _loadBooks();
                          })
                      : null,
                  child: Text('<'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      page += 1;
                      _loadBooks();
                    });
                  },
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
