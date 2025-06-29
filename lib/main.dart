import 'package:flutter/material.dart';
import 'calculator.dart';
void main() {
  runApp(MeuApp());
}

class MeuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Mocami',
      home: Calculator(),
    );
  }
}
