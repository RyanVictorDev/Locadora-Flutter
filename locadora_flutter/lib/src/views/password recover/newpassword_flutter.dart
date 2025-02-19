import 'package:flutter/material.dart';
import 'package:locadora_flutter/main.dart';
import 'package:locadora_flutter/src/services/password_recover_service.dart';
import 'package:locadora_flutter/src/views/login/login_flutter.dart';

class NewpasswordFlutter extends StatefulWidget {
  const NewpasswordFlutter({super.key});

  @override
  State<NewpasswordFlutter> createState() =>
      _NewpasswordFlutterState();
}

class _NewpasswordFlutterState extends State<NewpasswordFlutter> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final PasswordRecoverService _passwordRecoverService =
      PasswordRecoverService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _recoverPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _passwordRecoverService.resetPassword(Token: _tokenController.text, newPassword: _newPasswordController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha alterada com sucesso!')),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: Padding(
        padding: const EdgeInsets.all(80.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                'https://media.licdn.com/dms/image/v2/D4D0BAQG1TnyLjqAfng/company-logo_200_200/company-logo_200_200/0/1690218015009/altislab_logo?e=2147483647&v=beta&t=fMlpVsIBYw2LadCX6g28enRYLhhyeqt463BGJdi9eco',
                height: 150.0,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tokenController,
                decoration: const InputDecoration(labelText: 'Token'),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'Nova Senha'),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _recoverPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 106, 145, 211),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Redefinir Senha'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
