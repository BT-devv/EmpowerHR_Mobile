import 'package:flutter/material.dart';

class TermsAndConditionPage extends StatelessWidget {
  const TermsAndConditionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Condition"),
      ),
      body: const Center(
        child: Text("This is Terms & Condition Page"),
      ),
    );
  }
}