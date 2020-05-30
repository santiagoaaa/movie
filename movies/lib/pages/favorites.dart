import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:movies/database/db.dart';
import 'dart:convert';

import 'package:movies/model/movie.dart';
import 'package:movies/pages/detailMovie.dart';
import 'package:sqflite/sqflite.dart';

class Favorites extends StatefulWidget {
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  Map<String, dynamic> dataMovie;
  List<Movie> movies = [];

  Map<String, dynamic> statusFavorite;
  var isloading = true;

  Future<String> getFavoritesMovies() async {
    this.setState(() {
      isloading = true;
    });

    movies = [];

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        var response = await http.get(
            Uri.encodeFull(
                "https://api.themoviedb.org/3/list/142660?api_key=418f34125f6649eb790ee7a0777c0cbc&language=es-MX"),
            headers: {"Accept": "application/json"});
        this.setState(() {
          dataMovie = json.decode(response.body);
          DBProvider.db.deleteAllFavorite();
          for (var m in dataMovie['items']) {
            Movie movie = Movie(
                popularity: m["popularity"],
                vote_count: m["vote_count"],
                poster_path: m["poster_path"],
                id: m["id"],
                backdrop_path: m["backdrop_path"],
                original_language: m["original_language"],
                original_title: m["original_title"],
                title: m["title"],
                overview: m["overview"]);
            DBProvider.db.newFavoriteMovie(movie);
            movies.add(movie);
          }

          print(movies.length);
          isloading = false;
        });
      }
    } on SocketException catch (_) {
      print('not connected');
      //Select a la tabla favorite_movie
      final Database db = await DBProvider.db.database;
      final List<Map<String, dynamic>> maps = await db.query('favorite_movie');
      this.setState(() {
        movies = List.generate(maps.length, (i) {
          return Movie(
              id: maps[i]['id'],
              overview: maps[i]['overview'],
              title: maps[i]['title']);
        });
        print("query length ${movies[1].backdrop_path}");
        isloading = false;
      });

//Termina Select
    }
  }

  Future<String> delFavorites(int id) async {
    String cadJson = '{"media_id": $id}';
    var response = await http.post(
        Uri.encodeFull(
            "https://api.themoviedb.org/3/list/142660/remove_item?api_key=418f34125f6649eb790ee7a0777c0cbc&session_id=4d652b4ce63509e6d74fbac914e497056453d349"),
        headers: {"Content-Type": "application/json"},
        body: cadJson);
    print(response.body);

    this.setState(() {
      statusFavorite = json.decode(response.body);
    });
  }

  @override
  void initState() {
    getFavoritesMovies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: new AppBar(
        title: new Text("Your Favorites Movies"),
        backgroundColor: Color(0xff091059),
      ),
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: ListView.builder(
                  itemCount: movies == null ? 0 : movies.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DetailMovie(
                                    movies[index].id,
                                    movies[index].title,
                                    movies[index].overview),
                              ),
                            );
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: <Widget>[
                                  (movies[index].backdrop_path == null)
                                      ? Image.asset("imagenes/img-not.jpg")
                                      : Image.network(
                                          "https://image.tmdb.org/t/p/w500${movies[index].backdrop_path}"),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      movies[index].title,
                                      style: new TextStyle(fontSize: 30.0),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: 'Delete Favorite',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () => {
                            print(movies[index].id),
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Warning"),
                                    content: Text(
                                        "Are you sure to delete ${movies[index].title} from your favorites?"),
                                    actions: <Widget>[
                                      FlatButton(
                                        //Desion para ver si tiene internet o no
                                          onPressed: () async {
                                            print("deleted");

                                            await delFavorites(
                                                movies[index].id);
                                            print(statusFavorite[
                                                'status_message']);
                                            setState(() {
                                              getFavoritesMovies();
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text("Yes")),
                                      FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("No")),
                                    ],
                                    elevation: 24.0,
                                  );
                                })
                          },
                        )
                      ],
                    );
                  }),
            ),
    ));
  }
}
