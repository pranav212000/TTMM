import 'package:flutter/material.dart';
import 'package:ttmm/shared/hex_color.dart';
import 'package:ttmm/temp/curve_painer.dart';

class GradientBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/back.png')),
          ),

        ),
      ),
    );
  }
}
