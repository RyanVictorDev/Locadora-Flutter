import 'package:flutter/material.dart';

class PasswordRecoveryFlutter extends StatefulWidget {
  @override
  State<PasswordRecoveryFlutter> createState() => _PasswordRecoveryFlutterState();
}

class _PasswordRecoveryFlutterState extends State<PasswordRecoveryFlutter> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _recoverPassword() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;

      try {
        // await _userService.recoverPassword(email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail de recuperação enviado!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao recuperar senha: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}