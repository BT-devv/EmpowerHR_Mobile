import 'package:flutter/material.dart';

class ManageAccountStatusPage extends StatelessWidget {
  const ManageAccountStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Account Status"),
      ),
      body: const Center(
        child: Text("This is Manage Account Status Page"),
      ),
    );
  }
}