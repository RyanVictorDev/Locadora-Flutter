import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/services/user_service.dart';

class UserCreate extends StatefulWidget {
  const UserCreate({super.key});

  @override
  State<UserCreate> createState() => _UserCreateState();
}

class _UserCreateState extends State<UserCreate> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = 'USER';
  bool _isLoading = false;

  final UserService _userService = UserService();

Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      _showLoadingDialog();

      final name = _nameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;
      final role = _selectedRole;

      try {
        await _userService.createUser(
          name: name,
          email: email,
          password: password,
          role: role,
        );

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário criado com sucesso!')),
        );

        Navigator.pop(context);

      } catch (e) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Criando usuário..."),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Criação de usuário',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Selecione o papel do usuário:'),
              Column(
                children: [
                  RadioListTile(
                    title: const Text('Editor'),
                    value: 'ADMIN',
                    groupValue: _selectedRole,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Usuário'),
                    value: 'USER',
                    groupValue: _selectedRole,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value.toString();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 124, 87),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isLoading
                      ? null
                      : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
