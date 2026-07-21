# Firebase CRUD Notes App

A Flutter application that allows users to create, view, update, and delete notes using Firebase Cloud Firestore.

## Features

- Create new notes
- View notes from Firestore
- Update existing notes
- Delete notes
- Real-time data update using Firestore
- Clean Flutter UI

## Technologies

- Flutter
- Dart
- Firebase
- Cloud Firestore

## How to Run

Clone the repository

```bash
git clone https://github.com/moumizaman/notes-management-app.git

## Project Structure

```
lib/
 ├── models/
 │    └── note_model.dart
 │
 ├── screens/
 │    ├── notes_screen.dart
 │    └── add_edit_note_screen.dart
 │
 ├── services/
 │    └── firestore_service.dart
 │
 ├── widgets/
 │    └── note_tile.dart
 │
 ├── firebase_options.dart
 └── main.dart
```

## Firebase Firestore Structure

```
notes
 |
 ├── document id
 |      |
 |      ├── title
 |      ├── description
 |      └── createdAt
```

## CRUD Operations

### Create Note
Users can create a new note by entering a title and description.

### View Notes
All saved notes are displayed from Firebase Cloud Firestore.

### Update Note
Users can edit and update existing notes.

### Delete Note
Users can remove notes from the Firestore database.

## Screens

### Notes List Screen
- Displays all notes stored in Firestore.
- Shows note title and description.
- Allows users to edit or delete notes.

### Add/Edit Note Screen
- Allows users to create new notes.
- Allows users to update existing notes.

## Firebase Integration

This application uses Firebase Cloud Firestore for storing and managing notes data.

## Assignment

This project was developed as part of a Flutter coursework assignment.

## Author

Moumi Zaman
