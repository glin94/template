import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:darulfikr/model/article.dart';

class ArticleDataBase {
  static final ArticleDataBase _instance = ArticleDataBase._internal();
  factory ArticleDataBase() => _instance;
  static Database _db;
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDB();
    return _db;
  }

  ArticleDataBase._internal();
  Future<Database> initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "main.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(""
        '''CREATE TABLE Articles(id STRING PRIMARY KEY,
        title TEXT, img TEXT,
        content TEXT,url TEXT,
        authors TEXT, about TEXT,
        tagsId TEXT, relatedPosts TEXT,
        tags TEXT, categories TEXT,
        video TEXT, book TEXT, audio TEXT,
        date TEXT, isFavored BIT)'''
        "");

    print("DataBase created!");
  }

  Future closeDB() async {
    var dbClient = await db;
    dbClient.close();
  }

  Future<List<Article>> getNotEmptyFavoriteColumn(String column) async {
    var dbClient = await db;
    List<Map> res = await dbClient.query('Articles',
        where: "$column <> '' AND isFavored = 1");
    return res.map((m) => Article.fromDB(m)).toList();
  }

  Future<List<Article>> getFavoriteArticles() async {
    var dbClient = await db;
    List<Map> res = await dbClient.query("Articles",
        where: "book='' AND video = '' AND isFavored = 1");
    return res.map((m) => Article.fromDB(m)).toList();
  }

  Future<List<Article>> getSearch(String value) async {
    var dbClient = await db;
    List<Map> res =
        await dbClient.query("Articles", where: "title like '%$value%'");
    return res.map((m) => Article.fromDB(m)).toList();
  }

  Future<List<Article>> getLastCountArticles(int count) async {
    var dbClient = await db;
    List<Map> res = await dbClient.rawQuery(
        "SELECT * FROM  Articles WHERE video = '' ORDER BY date DESC");
    return res.map((m) => Article.fromDB(m)).toList().sublist(0, count);
  }

  Future<List<Article>> getArticles(String key, dynamic value) async {
    var dbClient = await db;
    List<Map> res = await dbClient.query(
      "Articles",
      where: "$key = $value",
    );
    return res.map((m) => Article.fromDB(m)).toList();
  }

  Future<List<Article>> getArticlesWithIds(List<String> ids) async {
    var dbClient = await db;
    var idsString = ids.map((it) => '"$it"').join(',');
    // print("$ids\n$idsString");
    var res = await dbClient
        .rawQuery('SELECT * FROM Articles WHERE id IN ($idsString)');
    return res.map((m) => Article.fromDB(m)).toList();
  }

  Future<Article> getArticle(String id) async {
    var dbClient = await db;
    var res =
        await dbClient.query("Articles", where: "id = ?", whereArgs: [id]);
    if (res.length == 0) return null;
    return Article.fromDB(res[0]);
  }

  updateArticle(Article article) async {
    var dbClient = await db;

    await dbClient.rawInsert(
        "INSERT OR REPLACE INTO Articles(id, title, url, img,relatedPosts, content, authors, about, tags,tagsId, categories, video, book, audio, date, isFavored) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        [
          article.id,
          article.title,
          article.url,
          article.img,
          article.relatedPosts,
          article.content,
          article.authors.toString(),
          article.about.toString(),
          article.tags.toString(),
          article.tagsId.toString(),
          article.categories.toString(),
          article.video ?? '',
          article.book ?? '',
          article.audio ?? '',
          article.date ?? '',
          article.isFavored ? 1 : 0
        ]);
    // print(" updated " + article.id);
  }
}
