import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/sidebar/sidebar.dart';
import 'package:locadora_flutter/src/views/dashboard_flutter.dart';

class SidebarLayout extends StatelessWidget {
  const SidebarLayout({super.key});
  static var page = DashboardFlutter();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
      children: <Widget>[
        page,
        Sidebar()
      ],
      )
    );
  }
} 