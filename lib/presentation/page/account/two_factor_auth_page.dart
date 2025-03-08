import 'package:flutter/material.dart';

class TwoFactorAuthPage extends StatelessWidget {
  const TwoFactorAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Two-Factor Authentication"),
      ),
      body: const Center(
        child: Text("This is Two-Factor Authentication Page"),
      ),
    );
  }
}