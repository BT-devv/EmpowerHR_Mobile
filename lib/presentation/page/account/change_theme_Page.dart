import 'package:flutter/material.dart';

class ChangeThemePage extends StatelessWidget {
  const ChangeThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Theme"),
      ),
      body: const Center(
        child: Text("This is Change Theme Page"),
      ),
    );
  }
}