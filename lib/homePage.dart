import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


import 'package:port/askQuestionScreen.dart';
import 'package:port/drawerPage.dart';
// import 'package:port/loginScreen.dart';
import 'package:port/uploadbutton.dart';
import 'package:printing/printing.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Sharing Platform'),
        centerTitle: true,
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: IconButton(
        //       onPressed: () {
        //         logout();
        //         Navigator.popUntil(context, (route) => route.isFirst);
        //         Navigator.pushReplacement(context,
        //             MaterialPageRoute(builder: (context) {
        //           return LoginScreen();
        //         }));
        //       },
        //       icon: const Icon(Icons.logout),
        //     ),
        //   ),
        // ],
      ),
      drawer: DrawerHeaderScreen(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SearchBar(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Uploaded Notes:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 1, 6, 12),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                            return const AskQuestionScreen();
                      }));
                    },
                    label: Text(
                      "Ask a Question",
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('textnote')
                  .orderBy('createdAt',
                      descending: true) // Sort by createdAt descending
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data != null) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        // Extract data from Firestore document
                        Map<String, dynamic> textnoteData =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;

                        // Get the uploaded user's name and createdAt
                        final uploadedUserName =
                            textnoteData['username'] ?? 'Unknown';
                        final createdAt = textnoteData['createdAt']
                            ?.toDate(); // Assuming 'createdAt' is a Timestamp field

                        // Format the createdAt timestamp into a readable format (optional)
                        final formattedDate = createdAt != null
                            ? "${createdAt.day}/${createdAt.month}/${createdAt.year}"
                            : "Unknown date";

                        return NoteCard(
                          uploadedUserName: uploadedUserName,
                          title: textnoteData["title"] ?? 'No Title',
                          subtitle: textnoteData["subtitle"] ?? 'No Subtitle',
                          createdAt: formattedDate,
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(child: Text("No Data Found"));
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: const UploadButton(),
    );
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
  }
}

class NoteCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String uploadedUserName;
  final String createdAt;

  const NoteCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.uploadedUserName,
    required this.createdAt,
  }) : super(key: key);

  @override
  _NoteCardState createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool _isExpanded = false;

  // Function to generate and download the PDF
  void _downloadPdf() async {
    final pdf = pw.Document();

    // Adding a page to the PDF
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              widget.title,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              widget.subtitle,
              style: pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 10),
            pw.Text("Uploaded by: ${widget.uploadedUserName}"),
            pw.Text("Uploaded on: ${widget.createdAt}"),
          ],
        ); // This will add the content
      },
    ));

    // Save the PDF to a file or send it to printing
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    // Subtitle logic with See More / See Less
    String subtitleText = widget.subtitle;
    const maxLength = 100; // You can adjust this value
    bool showSeeMore = subtitleText.length > maxLength;

    return Card(
      child: ListTile(
        trailing: IconButton(
          onPressed: _downloadPdf, // Call the download PDF function
          icon: const Icon(Icons.download),
        ),
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 1, 6, 12),
          child: Text(
            widget.uploadedUserName.isNotEmpty
                ? widget.uploadedUserName[0]
                    .toUpperCase() // First letter of the username
                : '?', // Fallback character
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitleText.length > maxLength && !_isExpanded
                  ? subtitleText.substring(0, maxLength) + '...'
                  : subtitleText,
            ),
            if (showSeeMore)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded ? 'See Less' : 'See More',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            SizedBox(height: 5),
            Text(
              "Uploaded on: ${widget.createdAt}", // Added timestamp
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search notes or books...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
