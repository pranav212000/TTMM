import 'package:flutter/material.dart';
import 'package:ttmm/shared/hex_color.dart';
import 'package:ttmm/shared/navigation_item.dart';

class BottomNavBar extends StatelessWidget {
  int currentIndex = 1;
  Function onTapped;
  List<NavigationItem> items;
  BottomNavBar({this.currentIndex, this.onTapped, this.items});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          var itemIndex = items.indexOf(item);
          return GestureDetector(
            child: _buildItem(item, currentIndex == itemIndex),
            onTap: () {
              currentIndex = itemIndex;
              onTapped(itemIndex);
            },
          );
        }).toList(),
      ),
    );
  }
}

int index = 0;

Widget _buildItem(NavigationItem item, bool isSelected) {
  return AnimatedContainer(
    duration: Duration(milliseconds: 250),
    width: isSelected ? 125 : 50,
    height: double.maxFinite,
    padding: isSelected ? EdgeInsets.symmetric(horizontal: 10) : null,
    decoration: isSelected
        ? BoxDecoration(
            color: item.selectedBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(50)))
        : null,
    child: Center(
      child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: [
            IconTheme(
                data: IconThemeData(
                    size: 24,
                    color: isSelected
                        ? item.selectedColor
                        : item.defaultIconColor),
                child: item.icon),
            isSelected
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: isSelected
                          ? DefaultTextStyle(
                              style: TextStyle(color: item.selectedColor),
                              child: item.title)
                          : Container(),
                    ),
                  )
                : Container()
          ]),
    ),
  );
}
