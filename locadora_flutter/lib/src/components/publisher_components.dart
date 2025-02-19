import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/services/publisher_service.dart';

class DeleteDialog extends StatelessWidget {
  final int id;
  final VoidCallback onDeleteSuccess;

  const DeleteDialog({
    Key? key,
    required this.id,
    required this.onDeleteSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirmar Exclusão"),
      content: const Text("Tem certeza de que deseja excluir esta editora?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: () async {
            try {
              await PublisherService()
                  .deletePublisher(id: id, context: context);
              Navigator.of(context).pop(); 
              onDeleteSuccess(); 
            } catch (e) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
          child: const Text("Excluir", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
