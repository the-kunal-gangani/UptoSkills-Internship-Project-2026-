import 'package:flutter/material.dart';

class EdueraStudentScreen extends StatelessWidget {
  const EdueraStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Screen'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text('Demo Student Screen', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
