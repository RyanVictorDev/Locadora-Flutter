import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/models/publisher_model.dart';
import 'package:locadora_flutter/src/services/publisher_service.dart';

class PublisherUpdate extends StatefulWidget {
  final int id;
  const PublisherUpdate({super.key, required this.id});

  @override
  State<PublisherUpdate> createState() => _PublisherUpdateState();
}

class _PublisherUpdateState extends State<PublisherUpdate> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _siteController = TextEditingController();

  final PublisherService _publisherService = PublisherService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPublisher();
  }

  Future<void> _fetchPublisher() async {
    try {
      final publisher = await _publisherService.getById(id: widget.id);
      if (publisher != null) {
        setState(() {
          _nameController.text = publisher.name;
          _emailController.text = publisher.email;
          _telephoneController.text = publisher.telephone.toString();
          _siteController.text = publisher.site ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar editora: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final email = _emailController.text;
      final telephone = int.tryParse(_telephoneController.text) ?? 0;
      final site = _siteController.text;

      try {
        await _publisherService.updatePublisher(
          id: widget.id,
          name: name,
          email: email,
          telephone: telephone,
          site: site,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Editora atualizada com sucesso!')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar editora: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Editora'),
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
                      controller: _siteController,
                      decoration: const InputDecoration(
                        labelText: 'Site',
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
    _siteController.dispose();
    super.dispose();
  }
}
