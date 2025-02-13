import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locadora_flutter/main.dart';
import 'package:locadora_flutter/src/bloc.navigation_bloc/navigation_bloc.dart';
import 'package:locadora_flutter/src/sidebar/menu_item.dart';
import 'package:locadora_flutter/src/views/publishers/publisher_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sidebar extends StatefulWidget {
  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with SingleTickerProviderStateMixin {
  String name = '';
  String email = '';
  late final AnimationController _animationController;
  late final StreamController<bool> isSidebarOpenedStreamController;
  late final Stream<bool> isSidebarOpenedStream;
  final Duration _animationDuration = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    isSidebarOpenedStreamController = StreamController<bool>.broadcast();
    isSidebarOpenedStream = isSidebarOpenedStreamController.stream;
    _loadNameAndEmail();
  }

  @override
  void dispose() {
    _animationController.dispose();
    isSidebarOpenedStreamController.close();
    super.dispose();
  }

  void onIconPressed() {
    final isAnimationCompleted =
        _animationController.status == AnimationStatus.completed;

    if (isAnimationCompleted) {
      isSidebarOpenedStreamController.add(false);
      _animationController.reverse();
    } else {
      isSidebarOpenedStreamController.add(true);
      _animationController.forward();
    }
  }

  Future<void> _loadNameAndEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'Usuário';
      email = prefs.getString('email') ?? 'user@gmail.com';
    });
  }


  Future<void> logoutFunction(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken');
      await prefs.remove('role');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<bool>(
      initialData: false,
      stream: isSidebarOpenedStream,
      builder: (context, isSidebarOpenedAsync) {
        final bool isSidebarOpened = isSidebarOpenedAsync.data ?? false;

        return AnimatedPositioned(
          duration: _animationDuration,
          top: 0,
          bottom: 0,
          left: isSidebarOpened ? 0 : -screenWidth,
          right: isSidebarOpened ? 0 : screenWidth - 45,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  color: const Color.fromARGB(255, 0, 83, 94),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 100),
                      ListTile(
                        title: Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          email,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Divider(
                        height: 64,
                        thickness: 0.5,
                        color: Colors.white.withOpacity(0.3),
                        indent: 32,
                        endIndent: 32,
                      ),
                      MenuItem(
                        icon: Icons.bar_chart,
                        title: 'Dashboard',
                        onTap: () {
                          onIconPressed();
                        context
                          .read<NavigationBloc>()
                          .add(NavigationEvents.DashboardClickedEvent);
                        },
                      ),
                      MenuItem(
                        icon: Icons.person,
                        title: 'Controle de usuários',
                        onTap: () {
                          onIconPressed();
                          BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.UserClickedEvent);
                        },
                      ),
                      MenuItem(
                        icon: Icons.library_books,
                        title: 'Controle de locatários',
                        onTap: () {
                          onIconPressed();
                          BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.RenterClickedEvent);
                        },
                      ),
                      MenuItem(
                        icon: Icons.edit,
                        title: 'Controle de editoras',
                        onTap: () {
                          onIconPressed();
                          BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.PublisherClickedEvent);
                        },
                      ),
                      MenuItem(
                        icon: Icons.book,
                        title: 'Controle de livros',
                        onTap: () {
                          onIconPressed();
                          BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.BookClickedEvent);
                        },
                      ),
                      MenuItem(
                        icon: Icons.bookmark,
                        title: 'Controle de aluguéis',
                        onTap: () {
                          onIconPressed();
                          BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.RentClickedEvent);
                        },
                      ),
                      Divider(
                        height: 304,
                        thickness: 0.5,
                        color: Colors.white.withOpacity(0),
                        indent: 32,
                        endIndent: 32,
                      ),
                      MenuItem(
                        icon: Icons.exit_to_app,
                        title: 'Logout',
                        onTap: () {
                          logoutFunction(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, -0.95),
                child: GestureDetector(
                  onTap: onIconPressed,
                  child: ClipPath(
                    clipper: CustomMenuClipper(),
                    child: Container(
                      width: 35,
                      height: 110,
                      color: const Color.fromARGB(255, 0, 83, 94),
                      alignment: Alignment.centerLeft,
                      child: AnimatedIcon(
                        icon: AnimatedIcons.menu_close,
                        progress: _animationController.view,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CustomMenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;

    final width = size.width;
    final height = size.height;

    Path path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(0, 8, 10, 16);
    path.quadraticBezierTo(width - 1, height / 2 - 20, width, height / 2);
    path.quadraticBezierTo(width + 1, height / 2 + 20, 10, height - 16);
    path.quadraticBezierTo(0, height - 8, 0, height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
