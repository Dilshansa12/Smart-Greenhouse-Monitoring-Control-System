import 'package:flutter/material.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // placeholder logs
    return Scaffold(
      appBar: AppBar(title: const Text("Logs")),
      body: ListView.builder(
        itemCount: 15,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.note),
            title: Text("Log #${index + 1}"),
            subtitle: Text("Details of log entry ${index + 1}"),
          );
        },
      ),
    );
  }
}
