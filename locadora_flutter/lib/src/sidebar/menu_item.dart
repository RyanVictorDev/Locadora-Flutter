import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 30),
          SizedBox(width: 20,),
          Text(title,
            style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white
            ),
          )
        ],
      ),
    );
  }
}