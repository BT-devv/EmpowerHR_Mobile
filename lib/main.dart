import 'package:empowerhr_moblie/presentation/page/get_start.dart';
import 'package:empowerhr_moblie/presentation/page/notification_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  const envFile = String.fromEnvironment('ENV', defaultValue: '.env.dev');
  print('Running on environment: $envFile');
  await dotenv.load(fileName: envFile);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotificationListen(
          child: GetStartPage()), // Bọc bằng NotificationListener
    );
  }
}
