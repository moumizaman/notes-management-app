import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

class FirestoreService {

  final CollectionReference notes =
  FirebaseFirestore.instance.collection('notes');


  // Create Note
  Future<void> addNote(Note note) async {

    await notes.add(
      note.toMap(),
    );

  }



  // Read Notes
  Stream<List<Note>> getNotes() {

    return notes.snapshots().map((snapshot) {

      return snapshot.docs.map((doc) {

        return Note.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );

      }).toList();

    });

  }



  // Update Note
  Future<void> updateNote(Note note) async {

    if (note.id != null) {

      await notes.doc(note.id).update(
        note.toMap(),
      );

    }

  }



  // Delete Note
  Future<void> deleteNote(String id) async {

    await notes.doc(id).delete();

  }

}