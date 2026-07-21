import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String? id;
  String title;
  String description;
  DateTime? createdAt;

  Note({
    this.id,
    required this.title,
    required this.description,
    this.createdAt,
  });


  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "createdAt": createdAt ?? DateTime.now(),
    };
  }


  factory Note.fromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    return Note(
      id: id,
      title: data["title"] ?? "",
      description: data["description"] ?? "",
      createdAt: data["createdAt"] != null
          ? (data["createdAt"] as Timestamp).toDate()
          : null,
    );
  }
}