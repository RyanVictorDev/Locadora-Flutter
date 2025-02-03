import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locadora_flutter/src/bloc.navigation_bloc/navigation_bloc.dart';
import 'package:locadora_flutter/src/sidebar/sidebar.dart' as customSidebar;
import 'package:locadora_flutter/src/views/books/book_flutter.dart';
import 'package:locadora_flutter/src/views/dashboard_flutter.dart';
import 'package:locadora_flutter/src/views/publishers/publisher_flutter.dart';
import 'package:locadora_flutter/src/views/renters/renter_flutter.dart';

class SidebarLayout extends StatelessWidget {
  const SidebarLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NavigationBloc>(
      create: (context) => NavigationBloc(),
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            BlocBuilder<NavigationBloc, NavigationStates>(
              builder: (context, navigationState) {
                if (navigationState is DashboardState) {
                  return DashboardFlutter(); 
                } else if (navigationState is PublisherState) {
                  return PublisherFlutter();
                } else if (navigationState is RenterState) {
                  return RenterFlutter();
                } else if (navigationState is BookState) {
                  return BookFlutter();
                }
                return const Center(child: Text('Unknown State'));
              },
            ),
            customSidebar
              .Sidebar(),
          ],
        ),
      ),
    );
  }
}
