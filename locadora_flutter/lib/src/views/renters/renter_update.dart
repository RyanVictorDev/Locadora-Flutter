import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:locadora_flutter/src/services/renter_service.dart';

class RenterUpdate extends StatefulWidget {
  final int id;
  const RenterUpdate({super.key, required this.id});

  @override
  State<RenterUpdate> createState() => _RenterUpdateState();
}

class _RenterUpdateState extends State<RenterUpdate> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = MaskedTextController(mask: '(00)00000-0000');
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cpfController = MaskedTextController(mask: '000.000.000-00');

  final RenterService _renterService = RenterService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRenter();
  }

  Future<void> _fetchRenter() async {
    try {
      final renter = await _renterService.getById(id: widget.id);
      if (renter != null) {
        setState(() {
          _nameController.text = renter.name;
          _emailController.text = renter.email;
          _telephoneController.text = renter.telephone;
          _addressController.text = renter.address;
          _cpfController.text = renter.cpf;
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar locatário: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      _showLoadingDialog();

      final name = _nameController.text;
      final email = _emailController.text;
      final telephone = _telephoneController.text;
      final address = _addressController.text;
      final cpf = _cpfController.text;

      try {
        await _renterService.updateRenter(
          id: widget.id,
          name: name,
          email: email,
          telephone: telephone,
          address: address,
          cpf: cpf,
        );

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Locatário atualizado com sucesso!')),
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
              Text("Editando locatário..."),
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
        title: const Text('Editar Locatário'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Insira o nome'
                          : null,
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
                          return 'Insira o email';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telephoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Insira o telefone'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Endereço',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cpfController,
                      decoration: const InputDecoration(
                        labelText: 'Cpf',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Salvar Alterações'),
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
    _telephoneController.dispose();
    _addressController.dispose();
    _cpfController.dispose();
    super.dispose();
  }
}
