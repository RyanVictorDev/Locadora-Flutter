import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/models/book_model.dart';
import 'package:locadora_flutter/src/models/publisher_model.dart';
import 'package:locadora_flutter/src/models/renter_model.dart';
import 'package:locadora_flutter/src/services/book_service.dart';
import 'package:locadora_flutter/src/services/publisher_service.dart';
import 'package:locadora_flutter/src/services/renter_service.dart';

class BookDetails extends StatefulWidget {
  final int id;
  const BookDetails({super.key, required this.id});

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _launchDateController = TextEditingController();
  final TextEditingController _totalQuantityController = TextEditingController();
  final TextEditingController _totalInUseController =TextEditingController();
  final TextEditingController _publisher = TextEditingController();

  final BookService _bookService = BookService();
  bool _isLoading = true;
  BookModel? _book;

  @override
  void initState() {
    super.initState();
    _fetchBook();
  }

  Future<void> _fetchBook() async {
    try {
      final book = await _bookService.getById(id: widget.id);
      if (book != null) {
        setState(() {
          _book = book;
          _nameController.text = book.name;
          _authorController.text = book.author;
          _launchDateController.text = book.launchDate;
          _totalQuantityController.text = book.totalQuantity.toString();
          _totalInUseController.text = book.totalInUse.toString();
          _publisher.text = book.publisher.name;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar os detalhes do livro: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _book?.name ?? 'Detalhes do livro',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _book == null
              ? const Center(child: Text('Erro ao carregar os dados'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField('Nome', _nameController),
                      _buildTextField('Autor', _authorController),
                      _buildTextField('Data de lancamento', _launchDateController),
                      _buildTextField('Disponíveis', _totalQuantityController),
                      _buildTextField('Alugados', _totalInUseController),
                      _buildTextField('Editora', _publisher),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
