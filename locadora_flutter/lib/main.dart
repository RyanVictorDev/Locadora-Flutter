import 'package:flutter/material.dart';
import 'package:locadora_flutter/views/dashboard_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locadora Ryan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: DashboardFlutter(),
    );
  }
}
