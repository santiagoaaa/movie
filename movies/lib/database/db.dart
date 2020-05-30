import 'dart:async';
import 'dart:io';

import 'package:movies/model/cast.dart';
import 'package:movies/model/movie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "movies.db");
    return await openDatabase(path,
        version: 1, onOpen: (db) {}, onCreate: _createTables);
  }

  void _createTables(Database db, int version) async {
    await db.execute("CREATE TABLE popular_movie ("
        "id INTEGER,"
        "backdrop_path Text,"
        "poster_path Text,"
        "title Text,"
        "overview VARCHAR(200),"
        "CONSTRAINT id_unique UNIQUE (id))");

    await db.execute("CREATE TABLE favorite_movie ("
        "id INTEGER,"
        "backdrop_path Text,"
        "poster_path Text,"
        "title Text,"
        "overview Text,"
        "CONSTRAINT id_unique UNIQUE (id))");

  }

  newPopularMovie(Movie newMovie) async {
    final db = await database;

    var res = await db.rawInsert(
        "INSERT INTO popular_movie (id, backdrop_path, poster_path, title, overview)"
        " VALUES (?,?,?,?,?)",
        [
          newMovie.id,
          newMovie.backdrop_path,
          newMovie.poster_path,
          newMovie.title,
          newMovie.overview
        ]);

    return res;
  }

  newFavoriteMovie(Movie newMovie) async {
    final db = await database;

    var res = await db.rawInsert(
        "INSERT INTO favorite_movie (id, backdrop_path, poster_path, title, overview)"
        " VALUES (?,?,?,?,?)",
        [
          newMovie.id,
          newMovie.backdrop_path,
          newMovie.poster_path,
          newMovie.title,
          newMovie.overview
        ]);

    return res;
  }

  

  deleteAllPopular() async {
    final db = await database;
    db.rawDelete("delete from popular_movie", []);
  }

  deleteAllFavorite() async {
    final db = await database;
    db.rawDelete("delete from favorite_movie");
  }


}
