import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  final Function(String) onOptionSelected;

  Menu({required this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Opções')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Opção 1'),
            onTap: () => onOptionSelected('Opção 1'),
          ),
          ListTile(
            title: Text('Opção 2'),
            onTap: () => onOptionSelected('Opção 2'),
          ),
          ListTile(
            title: Text('Opção 3'),
            onTap: () => onOptionSelected('Opção 3'),
          ),
        ],
      ),
    );
  }

}