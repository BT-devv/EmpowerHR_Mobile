import 'package:flutter/material.dart';

class EmployeeRightsPage extends StatelessWidget {
  const EmployeeRightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee's Rights"),
      ),
      body: const Center(
        child: Text("This is Employee's Rights Page"),
      ),
    );
  }
}