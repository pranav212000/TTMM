import 'package:flutter/material.dart';

class NavigationItem {
  final Icon icon;
  final Text title;
  final Color selectedBackgroundColor;
  final Color defaultIconColor;
  final Color selectedColor;

  NavigationItem(
      {@required this.icon,
      @required this.title,
      @required this.defaultIconColor,
      @required this.selectedColor,
      @required this.selectedBackgroundColor});
}
