import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/firestore_service.dart';
import '../screens/add_edit_note_screen.dart';


class NoteTile extends StatelessWidget {

  final Note note;
  final FirestoreService firestoreService;


  const NoteTile({
    super.key,
    required this.note,
    required this.firestoreService,
  });



  @override
  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),


      child: ListTile(


        title: Text(
          note.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),



        subtitle: Text(
          note.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),



        // EDIT FUNCTION
        onTap: () {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (context) =>
                  AddEditNoteScreen(
                    note: note,
                  ),

            ),

          );

        },



        trailing: IconButton(

          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),


          onPressed: () async {

            if(note.id != null){

              await firestoreService.deleteNote(
                note.id!,
              );

            }

          },

        ),


      ),

    );

  }

}