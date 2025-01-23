import 'dart:async';
import 'package:flutter/material.dart';
import 'package:locadora_flutter/src/sidebar/menu_item.dart';

class Sidebar extends StatefulWidget {
  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with SingleTickerProviderStateMixin {
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
                  color: Color.fromARGB(255, 0, 83, 94),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 100,),
                      ListTile(
                        title: Text('TESTANDO',
                          style: TextStyle(
                            color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold
                          ),
                        ),
                        subtitle: Text('TESTANDO@gmail.com',
                          style: TextStyle(
                            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                      Divider(
                        height: 64,
                        thickness: 0.5,
                        color: Colors.white.withValues(alpha: 0.3),
                        indent: 32,
                        endIndent: 32,
                      ),
                      MenuItem(
                        icon: Icons.bar_chart, 
                        title: 'Dashboard'
                      ),
                      MenuItem(
                        icon: Icons.person, 
                        title: 'Controle de usuários'
                      ),
                      MenuItem(
                        icon: Icons.library_books, 
                        title: 'Controle de locatários'
                      ),
                      MenuItem(
                        icon: Icons.edit, 
                        title: 'Controle de editoras'
                      ),
                      MenuItem(
                        icon: Icons.book, 
                        title: 'Controle de livros'
                      ),
                      MenuItem(
                        icon: Icons.bookmark, 
                        title: 'Controle de aluguéis'
                      ),
                      Divider(
                        height: 304,
                        thickness: 0.5,
                        color: Colors.white.withValues(alpha: 0),
                        indent: 32,
                        endIndent: 32,
                      ),
                      MenuItem(
                        icon: Icons.exit_to_app, 
                        title: 'Logout'
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, -0.9),
                child: GestureDetector(
                  onTap: onIconPressed,
                  child: ClipPath(
                    clipper: CustomMenuClipper(),
                    child: Container(
                      width: 35,
                      height: 110,
                      color: Color.fromARGB(255, 0, 83, 94),
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
    path.quadraticBezierTo(width-1, height/2 - 20, width, height/2);
    path.quadraticBezierTo(width + 1, height/2 + 20, 10, height-16);
    path.quadraticBezierTo(0, height - 8, 0, height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}