import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/screens/profile/profile.dart';
import 'package:ttmm/shared/bottom_navigation_bar.dart';
import 'package:ttmm/screens/home/home.dart';
import 'package:ttmm/screens/my_orders/my_orders.dart';

import 'package:ttmm/shared/constants.dart';
import 'package:ttmm/shared/hex_color.dart';
import 'package:ttmm/shared/navigation_item.dart';

class NavigatorPage extends StatefulWidget {
  @override
  _NavigatorPageState createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  int _currentIndex = 2;
  PageController _pageController;
  final List<Widget> _children = [Home(), MyOrders(), Profile()];
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
              icon: Icon(Icons.home),
              title: Text('Home'),
              color: Colors.deepPurpleAccent),
          NavigationItem(
              icon: Icon(Icons.restaurant_menu),
              title: Text('My Orders'),
              color: HexColor('39393A')),
          NavigationItem(
              icon: Icon(Icons.person),
              title: Text('Me'),
              color: HexColor('FF6978')),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
