import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../models/note_model.dart';

class NotesScreen extends StatefulWidget {
  final AppState appState;
  
  const NotesScreen({super.key, required this.appState});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late List<NoteModel> _notes;
  String _searchQuery = '';
  bool _showOnlyPinned = false;
  
  @override
  void initState() {
    super.initState();
    _notes = widget.appState.notes;
  }
  
  List<NoteModel> get _filteredNotes {
    return _notes.where((note) {
      // Filter by search query
      final matchesQuery = _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filter by pinned status
      final matchesPinned = !_showOnlyPinned || note.isPinned;
      
      return matchesQuery && matchesPinned;
    }).toList();
  }
  
  void _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          appState: widget.appState,
        ),
      ),
    );
    
    if (result == true) {
      setState(() {
        _notes = widget.appState.notes;
      });
    }
  }
  
  void _editNote(NoteModel note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          appState: widget.appState,
          note: note,
        ),
      ),
    );
    
    if (result == true) {
      setState(() {
        _notes = widget.appState.notes;
      });
    }
  }
  
  void _deleteNote(NoteModel note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await widget.appState.deleteNote(note.id);
      setState(() {
        _notes = widget.appState.notes;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted')),
      );
    }
  }
  
  void _togglePinStatus(NoteModel note) async {
    final updatedNote = note.copyWith(isPinned: !note.isPinned);
    await widget.appState.updateNote(updatedNote);
    setState(() {
      _notes = widget.appState.notes;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(_showOnlyPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () {
              setState(() {
                _showOnlyPinned = !_showOnlyPinned;
              });
            },
            tooltip: _showOnlyPinned ? 'Show all notes' : 'Show pinned only',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortOptions();
            },
            tooltip: 'Sort notes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Notes grid
          Expanded(
            child: _filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No notes matching "$_searchQuery"'
                              : _showOnlyPinned
                                  ? 'No pinned notes'
                                  : 'No notes yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchQuery.isEmpty && !_showOnlyPinned) ...[
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _addNote,
                            icon: const Icon(Icons.add),
                            label: const Text('Create a note'),
                          ),
                        ]
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = _filteredNotes[index];
                      return _buildNoteCard(note);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildNoteCard(NoteModel note) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Card(
      color: note.color,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _editNote(note),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () => _togglePinStatus(note),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.content,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(note.dateModified),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  InkWell(
                    onTap: () => _deleteNote(note),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Date modified (newest first)'),
            onTap: () {
              setState(() {
                _notes.sort((a, b) => b.dateModified.compareTo(a.dateModified));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Date modified (oldest first)'),
            onTap: () {
              setState(() {
                _notes.sort((a, b) => a.dateModified.compareTo(b.dateModified));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.title),
            title: const Text('Title (A to Z)'),
            onTap: () {
              setState(() {
                _notes.sort((a, b) => a.title.compareTo(b.title));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.title),
            title: const Text('Title (Z to A)'),
            onTap: () {
              setState(() {
                _notes.sort((a, b) => b.title.compareTo(a.title));
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class NoteEditorScreen extends StatefulWidget {
  final AppState appState;
  final NoteModel? note;
  
  const NoteEditorScreen({
    super.key,
    required this.appState,
    this.note,
  });

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late bool _isPinned;
  late Color _noteColor;
  
  final List<Color> _availableColors = [
    Colors.white,
    Colors.red.shade100,
    Colors.orange.shade100,
    Colors.yellow.shade100,
    Colors.green.shade100,
    Colors.blue.shade100,
    Colors.purple.shade100,
    Colors.pink.shade100,
  ];
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _isPinned = widget.note?.isPinned ?? false;
    _noteColor = widget.note?.color ?? Colors.white;
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    if (title.isEmpty && content.isEmpty) {
      // Don't save empty notes
      Navigator.pop(context, false);
      return;
    }
    
    // Use a default title if none provided
    final finalTitle = title.isEmpty ? 'Untitled Note' : title;
    
    if (widget.note == null) {
      // Create new note
      final newNote = NoteModel(
        title: finalTitle,
        content: content,
        isPinned: _isPinned,
        color: _noteColor,
      );
      await widget.appState.addNote(newNote);
    } else {
      // Update existing note
      final updatedNote = widget.note!.copyWith(
        title: finalTitle,
        content: content,
        isPinned: _isPinned,
        color: _noteColor,
      );
      await widget.appState.updateNote(updatedNote);
    }
    
    Navigator.pop(context, true);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () {
              setState(() {
                _isPinned = !_isPinned;
              });
            },
            tooltip: _isPinned ? 'Unpin note' : 'Pin note',
          ),
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            onPressed: _showColorPicker,
            tooltip: 'Change color',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
            tooltip: 'Save note',
          ),
        ],
      ),
      body: Container(
        color: _noteColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                ),
                maxLines: 1,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _contentController,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Note content',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Note Color',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _availableColors.map((color) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _noteColor = color;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _noteColor == color
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        width: _noteColor == color ? 2 : 1,
                      ),
                    ),
                    child: _noteColor == color
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}