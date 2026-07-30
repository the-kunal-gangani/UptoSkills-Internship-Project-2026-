import 'package:flutter/material.dart';

class EdueraTeacherScreen extends StatelessWidget {
  const EdueraTeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Screen'),
        backgroundColor: Colors.orange,
      ),
      body: const Center(
        child: Text('Demo Teacher Screen', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
