import 'package:flutter/material.dart';
import 'model.dart';
import 'insert_page.dart';
import 'detail_page.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  static const _filterLabels = ['すべて', '完了', '未完了'];
  var _memos = <Memo>[];
  var _filter = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    late final List<Memo> memos;
    if (_filter == 1) {
      memos = await Memo.fetchDone();
    } else if (_filter == 2) {
      memos = await Memo.fetchNotDone();
    } else {
      memos = await Memo.fetchAll();
    }
    setState(() {
      _memos = memos;
    });
  }

  Future<void> _deleteDoc(String id) async {
    await Memo.delete(id);
  }

  void _onFilterChanged(int index) {
    setState(() {
      _filter = index;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メモ一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InsertPage()),
              ).then((_) => _loadData());
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _filterLabels.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(_filterLabels[i]),
                      selected: _filter == i,
                      onSelected: (_) => _onFilterChanged(i),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: _memos.isEmpty
          ? const Center(child: Text('メモがありません'))
          : ListView(
              children: _memos.map((memo) {
                return Dismissible(
                  key: Key(memo.id),
                  onDismissed: (direction) {
                    _deleteDoc(memo.id);
                    setState(() {
                      _memos.remove(memo);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${memo.title}を削除しました")),
                    );
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    leading: Icon(
                      memo.isDone
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank,
                    ),
                    title: Text(memo.title),
                    subtitle: memo.content != null ? Text(memo.content!) : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(id: memo.id),
                      ),
                    ).then((_) => _loadData()),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
