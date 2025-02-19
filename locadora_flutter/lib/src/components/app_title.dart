import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  final String title;
  const AppTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Text(
            title,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        );
  }
}