import 'package:flutter/material.dart';

class ItinerariesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Itineraries')),
      body: Center(
        child: Text('Manage your travel itineraries here.'),
      ),
    );
  }
}
