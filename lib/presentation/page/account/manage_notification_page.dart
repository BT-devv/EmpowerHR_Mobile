import 'package:flutter/material.dart';

class ManageNotificationPage extends StatelessWidget {
  const ManageNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Notification"),
      ),
      body: const Center(
        child: Text("This is Manage Notification Page"),
      ),
    );
  }
}