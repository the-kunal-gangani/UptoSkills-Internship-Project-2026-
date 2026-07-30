import 'package:flutter/material.dart';

class EdueraParentScreen extends StatelessWidget {
  const EdueraParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Screen'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text('Demo Parent Screen', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
