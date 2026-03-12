import 'package:file_share_app/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the app.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false,
      title: 'FileShare',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const FileShareHome(),
    );
  }
}