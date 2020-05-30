import 'package:flutter/material.dart';
import 'package:movies/model/movie.dart';
import 'package:movies/pages/detailMovie.dart';
class Item extends StatefulWidget {
  final List<Movie> mov;
  Item(this.mov);
  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {

  List<Movie> movies;
   @override
  void initState() {
    movies = widget.mov;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                                (movies[index].backdrop_path==null) ? Image.asset("imagenes/img-not.jpg")  :
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
            );
  }
}