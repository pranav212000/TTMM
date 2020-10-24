import 'package:flutter/material.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:ttmm/shared/hex_color.dart';

class AddEvent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Event'),
      ),
      body: Form(
        child: Column(
          children: [
            Card(
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: 'Event Name',
                    hintText: 'Event Name',
                    hintStyle: HINT_STYLE),
              ),
            ),
            Card(
              child: Text('data'),
            )
          ],
        ),
      ),
    );
  }
}
