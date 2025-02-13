import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:locadora_flutter/src/models/book_model.dart';
import 'package:locadora_flutter/src/models/publisher_model.dart';
import 'package:locadora_flutter/src/models/renter_model.dart';
import 'package:locadora_flutter/src/services/book_service.dart';
import 'package:locadora_flutter/src/services/publisher_service.dart';
import 'package:locadora_flutter/src/services/rent_service.dart';
import 'package:locadora_flutter/src/services/renter_service.dart';

class RentUpdate extends StatefulWidget {
  final int id;
  const RentUpdate({super.key, required this.id});

  @override
  State<RentUpdate> createState() => _RentUpdateState();
}

class _RentUpdateState extends State<RentUpdate> {
  final _formKey = GlobalKey<FormState>();

  final MaskedTextController _deadLineController =
      MaskedTextController(mask: '00/00/0000');

  final BookService _bookService = BookService();
  final RenterService _renterService = RenterService();
  final RentService _rentService = RentService();

  RenterModel? _selectedRenter;
  BookModel? _selectedBook;
  bool _isLoading = true;

  Future<void> _fetchRent() async {
    try {
      final rent = await _rentService.getById(id: widget.id);
      if (rent != null) {
        setState(() {
          _deadLineController.text = DateFormat("dd/MM/yyyy").format(DateFormat("yyyy-MM-dd").parse(rent.deadLine));
          _selectedRenter = rent.renter;
          _selectedBook = rent.book;
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar livro: $e')),
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

        await _rentService.updateRent(
          id: widget.id,
          renterId: renterId,
          bookId: bookId,
          deadLine: formattedDate,
        );

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aluguel atualizado com sucesso!')),
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
  void initState() {
    super.initState();
    _fetchRent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Aluguel'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _deadLineController,
                      decoration: const InputDecoration(
                        labelText: 'Devolução',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Por favor, insira uma data.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownSearch<RenterModel>(
                      asyncItems: (String filter) => _fetchRenters(filter),
                      itemAsString: (RenterModel renter) =>
                          renter.name,
                      selectedItem: _selectedRenter,
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
                      selectedItem: _selectedBook,
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
    _deadLineController.dispose();
    super.dispose();
  }
}
