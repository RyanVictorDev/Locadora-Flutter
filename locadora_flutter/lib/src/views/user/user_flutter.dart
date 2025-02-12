import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/models/user_model.dart';
import 'package:locadora_flutter/src/services/user_service.dart';
import 'package:locadora_flutter/src/views/user/user_create.dart';
import 'package:locadora_flutter/src/views/user/user_details.dart';
import 'package:locadora_flutter/src/views/user/user_update.dart';

class UserFlutter extends StatefulWidget {
  @override
  _UserFlutterState createState() => _UserFlutterState();
}

class _UserFlutterState extends State<UserFlutter> {
  late Future<List<UserModel>> usersFuture;
  int page = 0;
  String search = "";
  final TextEditingController _searchController = TextEditingController();
  Map<int, bool> expandedState = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      usersFuture = UserService().fetchUsers(search, page);
    });
  }

  void _toggleExpansion(int index) {
    setState(() {
      expandedState[index] = !(expandedState[index] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Text(
            'Usuários',
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
                          builder: (context) => UserCreate()),
                    ).then((value) => _loadUsers());
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
                        _loadUsers();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<UserModel>>(
                future: usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar dados'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nenhum dado disponível'));
                  }

                  final users = snapshot.data!;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(user.name,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(user.role.toString()),
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
                                              UserDetails(
                                                  id: user.id),
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
                                              UserUpdate(id: user.id),
                                        ),
                                      ).then((value) => _loadUsers());
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
                              _loadUsers();
                            })
                        : null,
                    child: Text('<')),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        page += 1;
                        _loadUsers();
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
