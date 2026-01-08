import 'package:flutter/material.dart';
import 'package:fishindo_app/data/models/mainbox_model.dart';

class MainBoxViewPage extends StatelessWidget {
  final MainBoxModel mainBox;
  const MainBoxViewPage({super.key, required this.mainBox});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(mainBox.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('ID: ${mainBox.id}\nName: ${mainBox.name}'),
      ),
    );
  }
}
