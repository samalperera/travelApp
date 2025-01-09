import 'package:flutter/material.dart';

class OfflineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Offline Data')),
      body: Center(
        child: Text('Access offline data here.'),
      ),
    );
  }
}
