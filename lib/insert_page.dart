import 'package:flutter/material.dart';
import 'model.dart';

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _errMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _insertData() async {
    if (_titleController.text.isEmpty) {
      setState(() {
        _errMessage = 'タイトルを入力してください';
      });
      return;
    }
    final memo = Memo(
      id: '',
      title: _titleController.text,
      content: _contentController.text.isEmpty ? null : _contentController.text,
    );
    await memo.insert();
    _titleController.clear();
    _contentController.clear();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('登録しました'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('メモ登録')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'タイトル',
                border: const OutlineInputBorder(),
                errorText: _errMessage,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '内容',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _insertData, child: const Text('登録')),
          ],
        ),
      ),
    );
  }
}
