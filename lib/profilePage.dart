import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotesScreen extends StatefulWidget {
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String? userName;

  @override
  void initState() {
    super.initState();
    fetchUserId();
  }

  void fetchUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.uid; // Use UID for filtering
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      body: userName == null
          ? const Center(child: CircularProgressIndicator()) // Show loader until USerName is fetched
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                // Firestore query to get notes for the specific user
                stream: FirebaseFirestore.instance
                    .collection('textnote')
                    .where('uid', isEqualTo: userName) // Filter by userId
                    .orderBy('createdAt', descending: true) // Order by creation date
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Something went wrong: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No Notes Available'));
                  }

                  var notes = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      var noteData =
                          notes[index].data() as Map<String, dynamic>;
                      var title = noteData['title'] ?? 'No Title';
                      var content = noteData['subtitle'] ?? 'No Content';
                      var createdAt = noteData['createdAt'] != null
                          ? (noteData['createdAt'] as Timestamp).toDate()
                          : null;
                      var formattedDate = createdAt != null
                          ? "${createdAt.day}/${createdAt.month}/${createdAt.year}"
                          : 'Unknown Date';

                      return ListTile(
                        title: Text(title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(content),
                           const SizedBox(height: 5),
                            Text(
                              'Created on: $formattedDate',
                              style:const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
