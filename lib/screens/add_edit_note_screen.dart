import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/firestore_service.dart';

class AddEditNoteScreen extends StatefulWidget {

  final Note? note;

  const AddEditNoteScreen({
    super.key,
    this.note,
  });


  @override
  State<AddEditNoteScreen> createState() =>
      _AddEditNoteScreenState();

}



class _AddEditNoteScreenState extends State<AddEditNoteScreen> {


  final FirestoreService firestoreService =
  FirestoreService();


  final TextEditingController titleController =
  TextEditingController();


  final TextEditingController descriptionController =
  TextEditingController();



  @override
  void initState() {

    super.initState();


    if (widget.note != null) {

      titleController.text =
          widget.note!.title;


      descriptionController.text =
          widget.note!.description;

    }

  }



  Future<void> saveNote() async {


    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );

      return;

    }



    if (widget.note == null) {


      // Create Note

      await firestoreService.addNote(

        Note(

          title: titleController.text.trim(),

          description:
          descriptionController.text.trim(),

          createdAt: DateTime.now(),

        ),

      );


    } else {


      // Update Note

      await firestoreService.updateNote(

        Note(

          id: widget.note!.id,

          title: titleController.text.trim(),

          description:
          descriptionController.text.trim(),

          createdAt:
          widget.note!.createdAt,

        ),

      );


    }



    if (mounted) {

      Navigator.pop(context);

    }


  }



  @override
  void dispose() {

    titleController.dispose();

    descriptionController.dispose();

    super.dispose();

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(

          widget.note == null
              ? "Add Note"
              : "Edit Note",

        ),

      ),



      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [


            TextField(

              controller: titleController,

              decoration: const InputDecoration(

                labelText: "Title",

                border: OutlineInputBorder(),

              ),

            ),



            const SizedBox(height: 15),



            TextField(

              controller: descriptionController,

              maxLines: 5,

              decoration: const InputDecoration(

                labelText: "Description",

                border: OutlineInputBorder(),

              ),

            ),



            const SizedBox(height: 20),



            SizedBox(

              width: double.infinity,


              child: ElevatedButton(

                onPressed: saveNote,


                child: Text(

                  widget.note == null
                      ? "Save Note"
                      : "Update Note",

                ),

              ),

            ),


          ],

        ),

      ),

    );

  }

}