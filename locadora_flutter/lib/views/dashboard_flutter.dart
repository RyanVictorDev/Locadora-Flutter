import 'package:flutter/material.dart';

class DashboardFlutter extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.menu, color: Colors.white,),
        backgroundColor: const Color.fromARGB(255, 0, 83, 94),
        title: Text('Dashboard', style: TextStyle(color: Colors.white),),
      ),
    );
  }
}