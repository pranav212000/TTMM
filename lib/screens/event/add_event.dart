import 'package:flutter/material.dart';
import 'package:ttmm/shared/constants.dart';

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
                decoration:
                    textInputDecoration.copyWith(labelText: 'Event Name'),
              ),

            ),
            Card(child: Text('data'),)
          ],
        ),
      ),
    );
  }
}
