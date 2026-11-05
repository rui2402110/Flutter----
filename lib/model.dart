import 'package:cloud_firestore/cloud_firestore.dart';

class Memo {
  // フィールド
  final String id;
  final String title;
  final String? content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDone;

  String get createdAtText => '$createdAt';
  String get updatedAtText => '$updatedAt';
  String get isDoneText => isDone ? "完了" : "未完了";

  // コンストラクタ
  //  定数でないDatetime.now()はDatetimeのデフォルト値にできないため初期化リストを使う
  Memo({
    required this.id,
    required this.title,
    this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isDone = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Mapから、Memoに変換するファクトリーコンストラクタ
  //  ファクトリーコンストラクタ：引数をもとに別のコンストラクタを呼び出すときに使う手法
  factory Memo.fromMap(Map<String, dynamic> map, {required String id}) => Memo(
    id: id,
    title: map['title'],
    content: map['content'],
    createdAt: (map['createdAt'] as Timestamp).toDate(),
    updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    isDone: map['isDone'] ?? false,
  );

  // MemoからMapに変換するメソッド
  Map<String, dynamic> toMap() => {
    'title': title,
    'content': content,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'isDone': isDone,
  };

  // すべてのメモを取得する
  static Future<List<Memo>> fetchAll() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('memoCollection')
        .get();
    return snapshot.docs
        .map((doc) => Memo.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  static Future<List<Memo>> _fetchWhere(String field, dynamic isEqualTo) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('memoCollection')
        .where(field, isEqualTo: isEqualTo)
        .get();
    return snapshot.docs
        .map((doc) => Memo.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  // 完了済みのメモを取得する
  static Future<List<Memo>> fetchDone() => _fetchWhere('isDone', true);

  // 未完了のメモを取得する
  static Future<List<Memo>> fetchNotDone() => _fetchWhere('isDone', false);

  // IDからメモを1件取得する
  static Future<Memo?> fetchById(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('memoCollection')
        .doc(id)
        .get();
    if (!doc.exists) return null;
    return Memo.fromMap(doc.data()!, id: doc.id);
  }

  // メモを登録する
  Future<void> insert() async {
    await FirebaseFirestore.instance.collection('memoCollection').add(toMap());
  }

  // メモを更新する
  Future<void> update() async {
    await FirebaseFirestore.instance
        .collection('memoCollection')
        .doc(id)
        .update({
          'title': title,
          'content': content,
          'isDone': isDone,
          'updatedAt': DateTime.now(),
        });
  }

  // メモを削除する
  static Future<void> delete(String id) async {
    await FirebaseFirestore.instance
        .collection('memoCollection')
        .doc(id)
        .delete();
  }
}
