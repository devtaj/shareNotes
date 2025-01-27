import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({super.key});

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();

  // Function to submit a question
  void submitQuestion() {
    String question = _questionController.text.trim();
    String tags = _tagsController.text.trim();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a question!")),
      );
    } else {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Map<String, dynamic> faq = {
            "questions": question,
            "tags": tags,
            "userId": user.uid,
            "userEmail": user.email,
            "createdAt": Timestamp.now(),
          };
          FirebaseFirestore.instance.collection('faq').add(faq).then((docRef) {
            print("Question submitted with ID: ${docRef.id}");
            _questionController
                .clear(); // Clear the question input after submission
            _tagsController.clear(); // Clear the tags input after submission
          }).catchError((error) {
            print("Error adding question: $error");
          });
        } else {
          print("No user is logged in.");
        }
      } on FirebaseAuthException catch (e) {
        print("FirebaseAuthException: $e");
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  // Function to submit a reply to a specific question
  void submitReply(String questionId) async {
    String reply = _replyController.text.trim();

    if (reply.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a reply!")),
      );
    } else {
      try {
        FirebaseFirestore.instance.collection('faq').doc(questionId).update({
          'replies': FieldValue.arrayUnion([
            {
              "userId": FirebaseAuth.instance.currentUser?.uid,
              "userEmail": FirebaseAuth.instance.currentUser?.email,
              "reply": reply,
              "createdAt": Timestamp.now(),
            }
          ])
        }).then((_) {
          print("Reply submitted successfully.");
          _replyController.clear(); // Clear the reply input after submission
          Navigator.of(context).pop(); // Close the dialog
        }).catchError((error) {
          print("Error adding reply: $error");
        });
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  // Show the reply dialog
  void _showDialog(String questionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reply'),
          content: TextField(
            controller: _replyController,
            decoration:
                const InputDecoration(hintText: 'Type your reply here...'),
            maxLines: 3,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    submitReply(questionId); // Submit the reply
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Ask a Question', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 1, 6, 12),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What's on your mind?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 1, 6, 12),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _questionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Your Question",
                hintText: "Type your question here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 1, 6, 12), width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: "Tags (Optional)",
                hintText: "Add relevant tags, separated by commas",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 1, 6, 12), width: 2.0),
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: submitQuestion,
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text("Submit Question",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: const Color.fromARGB(255, 1, 6, 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('faq')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No questions available.'));
                }
                final faqData = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: faqData.length,
                  itemBuilder: (context, index) {
                    final faq = faqData[index];
                    final question = faq['questions'];
                    final questionId = faq.id;
                    final userEmail = faq['userEmail'] ??
                        'Unknown user'; // Get user email for the question

                    // Extract the first letter of the user's email for the avatar
                    String firstLetter =
                        userEmail.isNotEmpty ? userEmail[0].toUpperCase() : '?';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color.fromARGB(255, 1, 6, 12),
                                  child: Text(
                                      firstLetter,style: TextStyle(fontWeight: FontWeight.w800,color: Colors.white),), // Display first letter in the avatar
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  question,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // StreamBuilder to fetch replies
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('faq')
                                  .doc(questionId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }
                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return const Text('No replies yet.');
                                }

                                final data = snapshot.data!.data()
                                    as Map<String, dynamic>?;
                                final replies = data?['replies'] as List?;

                                if (replies == null || replies.isEmpty) {
                                  return const SizedBox.shrink(); // Blank space
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: replies.length,
                                  itemBuilder: (context, index) {
                                    final reply = replies[index];

                                    // Safely get the 'createdAt' field and check for null
                                    Timestamp? timestamp = reply['createdAt'];
                                    DateTime? dateTime = timestamp
                                        ?.toDate(); // Only convert if not null

                                    // Extract the first letter of the user's email for the reply
                                    String replyUserEmail =
                                        reply['userEmail'] ?? 'Unknown user';
                                    String replyFirstLetter =
                                        replyUserEmail.isNotEmpty
                                            ? replyUserEmail[0].toUpperCase()
                                            : '?';

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: const Color.fromARGB(255, 94, 160, 241),
                                                  child: Text(
                                                    
                                                      replyFirstLetter, style: TextStyle(fontWeight: FontWeight.w800,color: Colors.white),), // Display first letter for replies
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  replyUserEmail,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 50.0),
                                              child: Text(
                                                reply['reply'] ??
                                                    'No reply text available.',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              dateTime != null
                                                  ? 'Posted on: ${dateTime.toLocal()}'
                                                  : 'Posted on: Unknown',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                _showDialog(
                                    questionId); // Pass the questionId to the dialog
                              },
                              child: const Text("Reply"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
