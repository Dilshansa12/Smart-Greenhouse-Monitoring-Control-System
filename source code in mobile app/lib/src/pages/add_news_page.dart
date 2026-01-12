import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddNewsPage extends StatefulWidget {
  const AddNewsPage({super.key});

  @override
  State<AddNewsPage> createState() => _AddNewsPageState();
}

class _AddNewsPageState extends State<AddNewsPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  final db = FirebaseDatabase.instance.ref("news");

  Future<void> addNews() async {
    if (titleController.text.isEmpty || descController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    await db.push().set({
      "title": titleController.text,
      "description": descController.text,
      "date": DateTime.now().toString().split(" ").first,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("News Added!")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add News")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: addNews, child: const Text("Add News")),
          ],
        ),
      ),
    );
  }
}
