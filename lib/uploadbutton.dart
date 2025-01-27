import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadButton extends StatefulWidget {
  const UploadButton({Key? key}) : super(key: key);

  @override
  _UploadButtonState createState() => _UploadButtonState();
}

class _UploadButtonState extends State<UploadButton> {
  PlatformFile? _selectedFile; // Variable to store the selected file

  

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.blue,
      child: Icon(Icons.add),
      onPressed: () {
        _showUploadDialog(context);
      },
      
      // icon: const Icon(Icons.upload_file),
      // label: const Text('Upload Notes or Books'),
      // style: ElevatedButton.styleFrom(
      //   minimumSize: const Size(double.infinity, 50),
      // ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Options'),
          content: const Text('Choose an option to proceed:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showCreateNoteDialog(context);
              },
              child: const Text('Create Note'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // await _pickPdfFile(context);
              },
              child: const Text('Upload Note'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickPdfFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Only allow PDF files
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.single; // Save the selected file
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File selected: ${_selectedFile!.name}')),
        );

        // You can now use `_selectedFile` to access file details
        // Example: Upload the file or show its details in the UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }

  void _showCreateNoteDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
  // void saveData(){
  //   String title=titleController.text.trim();
  //   String subtitle = descriptionController.text.trim();

  //   if(title !="" || subtitle != ""){
  //     try{
  //         Map<String, dynamic> textNote={
  //             "title":title,
  //             "subtitle":subtitle,
  //         };
  //           FirebaseFirestore.instance.collection('textnote').add(textNote);
  //     }catch(e){
  //         print(e);
  //     }
  //   }
  // }
  void saveData() {
  String title = titleController.text.trim();
  String subtitle = descriptionController.text.trim();

  if (title.isNotEmpty || subtitle.isNotEmpty) {
    try {
      final user = FirebaseAuth.instance.currentUser; // Get the current user
      if (user != null) {
        // Prepare data to save
        Map<String, dynamic> textNote = {
          "title": title,
          "subtitle": subtitle,
          "username":user.email,
          "uid": user.uid, // To identify which user uploaded it
          "createdAt": Timestamp.now(), // Optional: for sorting
        };
        // Add to Firestore
        FirebaseFirestore.instance.collection('textnote').add(textNote);
      }
    } catch (e) {
      print("Error saving data: $e");
    }
  }
}

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a Note'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                saveData();
                final title = titleController.text.trim();
                final description = descriptionController.text.trim();

                if (title.isEmpty || description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields.')),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Note "$title" created successfully!')),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
