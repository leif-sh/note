import 'package:flutter/material.dart';
import 'package:flutter_application_1/domain/note.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/widgets/note_edit.dart';

class NotebookHomePage extends StatefulWidget {
  const NotebookHomePage({Key? key}) : super(key: key);

  @override
  _NotebookHomePageState createState() => _NotebookHomePageState();
}

class _NotebookHomePageState extends State<NotebookHomePage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() async {
    final data = await dbHelper.readAllNotes();
    setState(() {
      notes = data;
    });
  }

  void _addNote() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditPage()),
    );
    _refreshNotes();
  }

  void _editNote(Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditPage(note: note)),
    );
    _refreshNotes();
  }

  void _deleteNote(int id) async {
    await dbHelper.delete(id);
    _refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记事本'),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Dismissible(
            key: Key(note.id.toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _deleteNote(note.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('笔记 "${note.title}" 已删除')),
              );
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              title: Text(note.title),
              subtitle: Text(note.date),
              onTap: () => _editNote(note),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteNote(note.id!),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}