import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/home.dart';

void main() {
  runApp(const NotebookApp());
}

class NotebookApp extends StatelessWidget {
  const NotebookApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notebook App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NotebookHomePage(),
    );
  }
}