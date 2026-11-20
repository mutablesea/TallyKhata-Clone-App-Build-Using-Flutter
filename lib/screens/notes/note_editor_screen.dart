import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/tk_app_bar.dart';

/// Screen 20: note editor (checkbox + text, keyboard open, ✓ FAB saves).
class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _save() {
    final t = _text.text.trim();
    if (t.isNotEmpty) AppScope.read(context).addNote(t);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final has = _text.text.trim().isNotEmpty;
    return Scaffold(
      appBar: tkAppBar(context,
          title: 'ব্যবসার নোট',
          showBusiness: true,
          actions: const [HelpPill()]),
      body: Container(
        color: AppColors.greyBg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 80,
        child: Row(
          children: [
            const Icon(Icons.check_box_outline_blank, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _text,
                autofocus: true,
                cursorColor: AppColors.red,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(border: InputBorder.none),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        shape: const CircleBorder(),
        backgroundColor: has ? AppColors.red : Colors.grey,
        foregroundColor: Colors.white,
        child: const Icon(Icons.check),
      ),
    );
  }
}
