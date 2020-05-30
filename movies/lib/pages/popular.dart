import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movies/database/db.dart';
import 'dart:convert';

import 'package:movies/model/movie.dart';
import 'package:movies/pages/item.dart';
import 'package:sqflite/sqflite.dart';

class Popular extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PopularState();
  }
}

class PopularState extends State<Popular> {
  Map<String, dynamic> dataMovie;
  List<Movie> movies = [];
  var isloading = true;

  Item item;

  Future<String> getPopularMovies() async {
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
                "https://api.themoviedb.org/3/movie/popular?api_key=418f34125f6649eb790ee7a0777c0cbc&language=es-MX"),
            headers: {"Accept": "application/json"});

        this.setState(() {
          dataMovie = json.decode(response.body);
          DBProvider.db.deleteAllPopular();
          for (var m in dataMovie['results']) {
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
            DBProvider.db.newPopularMovie(movie);
            movies.add(movie);
          }

          print(movies.length);
          isloading = false;
        });
      }
    } on SocketException catch (_) {
      print('not connected');
      //Select a la tabla popular_movie
      final Database db = await DBProvider.db.database;
      final List<Map<String, dynamic>> maps = await db.query('popular_movie');
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

  @override
  void initState() {
    getPopularMovies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
        home: Scaffold(
      appBar: new AppBar(
        title: new Text(
          "Popular Movies",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color(0xff091059),
      ),
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : item = new Item(
              movies), /*Container(
              child: ListView.builder(
                  itemCount: movies == null ? 0 : movies.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
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
                                Image.network(
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
                        ));
                  }),
            ),*/
    ));
  }
}
