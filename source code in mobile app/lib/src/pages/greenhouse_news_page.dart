import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class GreenhouseNewsPage extends StatefulWidget {
  const GreenhouseNewsPage({super.key});

  @override
  State<GreenhouseNewsPage> createState() => _GreenhouseNewsPageState();
}

class _GreenhouseNewsPageState extends State<GreenhouseNewsPage> {
  final db = FirebaseDatabase.instance.ref("news");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Greenhouse News")),
      body: StreamBuilder(
        stream: db.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text("No news available"));
          }

          final raw = snapshot.data!.snapshot.value;

          // Convert to safe map
          final data = Map<dynamic, dynamic>.from(raw as Map);

          final newsList = data.entries.map((e) {
            final item = Map<dynamic, dynamic>.from(e.value ?? {});

            return {
              "id": e.key,
              "title": item["title"] ?? "No Title",
              "description": item["description"] ?? "No Description",
              "date": item["date"] ?? "",
            };
          }).toList();

          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(
                    news["title"],
                    style: const TextStyle(
                      fontSize: 18, // Adjust title font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    news["description"],
                    style: const TextStyle(
                      fontSize: 12,
                      // Adjust subtitle font size
                    ),
                  ),
                  trailing: Text(
                    news["date"],
                    style: const TextStyle(
                      fontSize: 10, // Adjust trailing font size
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
