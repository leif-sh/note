import 'package:flutter/material.dart';
import 'package:flutter_application_1/domain/note.dart';
import 'package:flutter_application_1/db/dbHelper.dart';

void main() {
  runApp(const NotebookApp());
}

class NotebookApp extends StatelessWidget {
  const NotebookApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notebook App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NotebookHomePage(),
    );
  }
}


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

class NoteEditPage extends StatefulWidget {
  final Note? note;

  const NoteEditPage({Key? key, this.note}) : super(key: key);

  @override
  _NoteEditPageState createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final note = Note(
        id: widget.note?.id,
        title: _titleController.text,
        content: _contentController.text,
        date: DateTime.now().toIso8601String(),
      );

      if (widget.note == null) {
        await dbHelper.create(note);
      } else {
        await dbHelper.update(note);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? '新建笔记' : '编辑笔记'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '标题'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入标题';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: '内容'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入内容';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}