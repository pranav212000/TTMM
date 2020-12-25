import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ttmm/screens/profile/profile.dart';
import 'package:ttmm/shared/bottom_navigation_bar.dart';
import 'package:ttmm/screens/home/home.dart';
import 'package:ttmm/screens/my_orders/my_orders.dart';
import 'package:ttmm/shared/hex_color.dart';
import 'package:ttmm/shared/navigation_item.dart';

class NavigatorPage extends StatefulWidget {
  @override
  _NavigatorPageState createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  int _currentIndex = 0;
  List<Widget> _children = [Home(), MyOrders(), Profile()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   onTap: onTabTapped, // new
      //   currentIndex: _currentIndex, // new
      //   items: [
      //     new BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       title: Text('Home'),
      //     ),
      //     new BottomNavigationBarItem(
      //       icon: Icon(Icons.mail),
      //       title: Text('Messages'),
      //     ),
      //   ],
      // ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTapped: onTabTapped,
        items: [
          NavigationItem(
              icon: Icon(
                Icons.home,
              ),
              title: Text('Home', style: GoogleFonts.raleway()),
              selectedColor: Colors.white,
              defaultIconColor: Colors.deepPurpleAccent,
              selectedBackgroundColor: Colors.deepPurpleAccent),
          NavigationItem(
            icon: Icon(
              Icons.restaurant_menu,
            ),
            title: Text('My Orders', style: GoogleFonts.raleway()),
            selectedColor: Colors.black,
            defaultIconColor: HexColor('#37ff8b'),
            selectedBackgroundColor: HexColor('#37ff8b'),
            // color: HexColor('#00fddc')),
          ),
          NavigationItem(
              icon: Icon(Icons.person),
              title: Text('Me', style: GoogleFonts.raleway()),
              selectedColor: Colors.white,
              defaultIconColor: HexColor('FF6978'),
              selectedBackgroundColor: HexColor('FF6978')),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      switch (index) {
        case 1:
          _children[index] = new MyOrders();
          break;
        case 2:
          _children[index] = new Profile();
          break;

        default:
      }
      _currentIndex = index;
    });
  }
}
