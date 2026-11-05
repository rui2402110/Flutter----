import 'package:flutter/material.dart';
import 'model.dart';

class DetailPage extends StatefulWidget {
  final String id;
  const DetailPage({super.key, required this.id});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isDone = false;
  String? _errMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final memo = await Memo.fetchById(widget.id);
    if (memo != null) {
      _titleController.text = memo.title;
      _contentController.text = memo.content ?? '';
      setState(() {
        _isDone = memo.isDone;
      });
    }
  }

  Future<void> _updateData() async {
    if (_titleController.text.isEmpty) {
      setState(() {
        _errMessage = 'タイトルを入力してください';
      });
      return;
    }
    final memo = Memo(
      id: widget.id,
      title: _titleController.text,
      content: _contentController.text.isEmpty ? null : _contentController.text,
      isDone: _isDone,
    );
    await memo.update();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('更新しました'),
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
      appBar: AppBar(title: const Text('メモ詳細')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'タイトル',
                border: OutlineInputBorder(),
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
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('完了'),
              controlAffinity: ListTileControlAffinity.leading,
              value: _isDone,
              onChanged: (bool? value) {
                setState(() {
                  _isDone = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _updateData, child: const Text('更新')),
          ],
        ),
      ),
    );
  }
}
