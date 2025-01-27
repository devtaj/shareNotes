import 'package:flutter/material.dart';

class Replyscreen extends StatefulWidget {
  const Replyscreen({super.key});

  @override
  State<Replyscreen> createState() => _ReplyscreenState();
}

class _ReplyscreenState extends State<Replyscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reply Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _showDialog();
          },
          child:const Text('Show Dialog'),
        ),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:const Text('Dialog Title'),
          content: const Text('This is a simple dialog message'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
