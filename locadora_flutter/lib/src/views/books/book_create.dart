import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:locadora_flutter/src/models/publisher_model.dart';
import 'package:locadora_flutter/src/services/book_service.dart';
import 'package:locadora_flutter/src/services/publisher_service.dart';

class BookCreate extends StatefulWidget {
  const BookCreate({super.key});

  @override
  State<BookCreate> createState() => _BookCreateState();
}

class _BookCreateState extends State<BookCreate> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final MaskedTextController _launchDateController = MaskedTextController(mask: '00/00/0000');
  final TextEditingController _totalQuantityController = TextEditingController();

  final BookService _bookService = BookService();
  final PublisherService _publisherService = PublisherService();

  PublisherModel? _selectedPublisher;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final author = _authorController.text;
      final totalQuantity = int.tryParse(_totalQuantityController.text) ?? 0;
      final rawLaunchDate = _launchDateController.text;
      final publisherId = _selectedPublisher?.id;

      if (publisherId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione uma editora')),
        );
        return;
      }

      try {
        final parsedDate = DateFormat("dd/MM/yyyy").parse(rawLaunchDate);
        final formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);

        await _bookService.createBook(
          name: name,
          author: author,
          launchDate: formattedDate,
          totalQuantity: totalQuantity,
          publisherId: publisherId,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Livro criado com sucesso!')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar livro: $e')),
        );
      }
    }
  }

  Future<List<PublisherModel>> _fetchPublishers(String filter) async {
    return await _publisherService.fetchPublishers(filter, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Criação de livro',
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
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, insira o nome'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Autor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _launchDateController,
                decoration: const InputDecoration(
                  labelText: 'Data de lançamento',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, insira a data de lançamento'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _totalQuantityController,
                decoration: const InputDecoration(
                  labelText: 'Estoque',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownSearch<PublisherModel>(
                asyncItems: (String filter) => _fetchPublishers(filter),
                itemAsString: (PublisherModel publisher) => publisher.name,
                onChanged: (PublisherModel? publisher) {
                  setState(() {
                    _selectedPublisher = publisher;
                  });
                },
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Editora",
                    border: OutlineInputBorder(),
                  ),
                ),
                validator: (value) =>
                    value == null ? "Selecione uma editora" : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 124, 87),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _submitForm,
                  child: const Text('Salvar'),
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
    _authorController.dispose();
    _launchDateController.dispose();
    _totalQuantityController.dispose();
    super.dispose();
  }
}
