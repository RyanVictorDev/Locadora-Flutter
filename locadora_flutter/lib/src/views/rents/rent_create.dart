import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:locadora_flutter/src/models/book_model.dart';
import 'package:locadora_flutter/src/models/renter_model.dart';
import 'package:locadora_flutter/src/services/book_service.dart';
import 'package:locadora_flutter/src/services/rent_service.dart';
import 'package:locadora_flutter/src/services/renter_service.dart';

class RentCreate extends StatefulWidget {
  const RentCreate({super.key});

  @override
  State<RentCreate> createState() => _RentCreateState();
}

class _RentCreateState extends State<RentCreate> {
  final _formKey = GlobalKey<FormState>();
  final MaskedTextController _deadLineController = MaskedTextController(mask: '00/00/0000');

  bool _isLoading = false;

  final BookService _bookService = BookService();
  final RenterService _renterService = RenterService();
  final RentService _rentService = RentService();

  RenterModel? _selectedRenter;
  BookModel? _selectedBook;

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    _showLoadingDialog();

    if (_formKey.currentState!.validate()) {
      final rawLaunchDate = _deadLineController.text;
      final renterId = _selectedRenter?.id;
      final bookId = _selectedBook?.id;

      if (renterId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione um locatário')),
        );
        return;
      }

      if (bookId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione um livro')),
        );
        return;
      }

      try {
        final parsedDate = DateFormat("dd/MM/yyyy").parse(rawLaunchDate);
        final formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);

        await _rentService.createRent(
          renterId: renterId,
          bookId: bookId,
          deadLine: formattedDate,
        );

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aluguel criado com sucesso!')),
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

  Future<List<RenterModel>> _fetchRenters(String filter) async {
    return await _renterService.fetchAllRenters(filter);
  }

  Future<List<BookModel>> _fetchBooks(String filter) async {
    return await _bookService.fetchAllBooks(filter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Criação de aluguel',
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _deadLineController,
                decoration: const InputDecoration(
                  labelText: 'Data de devolução',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, insira a data de lançamento'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownSearch<RenterModel>(
                asyncItems: (String filter) => _fetchRenters(filter),
                itemAsString: (RenterModel renter) => renter.name,
                onChanged: (RenterModel? renter) {
                  setState(() {
                    _selectedRenter = renter;
                  });
                },
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Locatário",
                    border: OutlineInputBorder(),
                  ),
                ),
                validator: (value) =>
                    value == null ? "Selecione um locatário" : null,
              ),
              const SizedBox(height: 16),
              DropdownSearch<BookModel>(
                asyncItems: (String filter) => _fetchBooks(filter),
                itemAsString: (BookModel book) => book.name,
                onChanged: (BookModel? book) {
                  setState(() {
                    _selectedBook = book;
                  });
                },
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Livro",
                    border: OutlineInputBorder(),
                  ),
                ),
                validator: (value) =>
                    value == null ? "Selecione um livro" : null,
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
    _deadLineController.dispose();
    super.dispose();
  }
}
