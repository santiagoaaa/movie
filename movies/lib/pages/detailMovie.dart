import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movies/database/db.dart';
import 'package:movies/model/cast.dart';
import 'package:movies/model/video.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailMovie extends StatefulWidget {
  final int id;
  final String title;
  final String overview;
  DetailMovie(this.id, this.title, this.overview);

  @override
  State createState() => DetailMovieState();
}

class DetailMovieState extends State<DetailMovie> {
  Map<String, dynamic> data;
  List<Video> movieVideo = [];
  List<Cast> movieCast = [];
  Map<String, dynamic> statusFavorite;
  int idmov;
  String title;
  String overview;
  String status;
  var isloading = true;
  var isVideo = true;
  var isConected = true;
  YoutubePlayerController _controller;

  Future<String> getDetailMovie() async {
    this.setState(() {
      isloading = true;
    });

    movieVideo = [];
    movieCast = [];

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        isConected =true;
        //informacion de video
        var response = await http.get(
            Uri.encodeFull(
                "https://api.themoviedb.org/3/movie/$idmov/videos?api_key=418f34125f6649eb790ee7a0777c0cbc"),
            headers: {"Accept": "application/json"});

        //Informacion de cast
        var response2 = await http.get(
            Uri.encodeFull(
                "https://api.themoviedb.org/3/movie/$idmov/credits?api_key=418f34125f6649eb790ee7a0777c0cbc"),
            headers: {"Accept": "application/json"});

        this.setState(() {
          data = json.decode(response.body);
          for (var m in data['results']) {
            Video video = Video(
                m["id"], m["key"], m["name"], m["site"], m["size"], m["type"]);

            movieVideo.add(video);
          }

          print(data);

          data = json.decode(response2.body);
         // DBProvider.db.deleteAllCast();
          for (var m in data['cast']) {
            Cast cast = Cast(cast_id: m["cast_id"], character: m["character"], credit_id: m["credit_id"], id:m["id"],name: m["name"],profile_path: m["profile_path"]);
            
            //DBProvider.db.newCast(cast);
            movieCast.add(cast);
            //isloading = false;
          }
          print (movieCast[0].name);
          if (movieVideo.length > 0)
            _controller = YoutubePlayerController(
                initialVideoId: YoutubePlayer.convertUrlToId(movieVideo[0].key),
                flags: YoutubePlayerFlags(autoPlay: false));
          else {
            isVideo = false;
          }

          isloading = false;
          isConected =true;
        });
      }
    } on SocketException catch (_) {
      print('not connected');
      isVideo = false;
      isConected =false;
      //Select a la tabla favorite_movie
     
      this.setState(() {
        isConected =false;
        isloading = false;
      });

//Termina Select
    }
  }

  Future<String> addFavorites(int id) async {
    String cadJson = '{"media_id": $id}';
    var response = await http.post(
        Uri.encodeFull(
            "https://api.themoviedb.org/3/list/142660/add_item?api_key=418f34125f6649eb790ee7a0777c0cbc&session_id=4d652b4ce63509e6d74fbac914e497056453d349"),
        headers: {"Content-Type": "application/json"},
        body: cadJson);

    this.setState(() {
      statusFavorite = json.decode(response.body);
      status = statusFavorite['status_message'];
    });
    return status;
  }
  //https://api.themoviedb.org/3/movie/419704/credits?api_key=418f34125f6649eb790ee7a0777c0cbc

  //https://api.themoviedb.org/3/movie/419704/videos?api_key=418f34125f6649eb790ee7a0777c0cbc

//url add favorites
  //https://api.themoviedb.org/3/list/142660/add_item?api_key=418f34125f6649eb790ee7a0777c0cbc&session_id=4d652b4ce63509e6d74fbac914e497056453d349 y media_id campo de post recibe movie id

//url get favorites
  //https://api.themoviedb.org/3/list/142660?api_key=418f34125f6649eb790ee7a0777c0cbc&language=es-MX

  @override
  void initState() {
    idmov = widget.id;
    title = widget.title;
    overview = widget.overview;
    print("id $idmov movie $title overview $overview");
    getDetailMovie();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              "Detail Movie",
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              IconButton(
                  icon: const Icon(Icons.favorite_border),
                  tooltip: "Add to favorites",
                  onPressed: () async {
                    print("add favorites the movie $title with id $idmov");
                    await addFavorites(idmov);
                    print(status);
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Alert"),
                            content: Text(status),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Ok"))
                            ],
                            elevation: 24.0,
                          );
                        });
                  })
            ],
            backgroundColor: Color(0xff091059),
          ),
          /*floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Add your onPressed code here!
              print("add favorites the movie $title with id $idmov");
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.red,
            
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,*/
          body: isloading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // child: Card(
                      children: <Widget>[
                        isVideo
                            ? YoutubePlayer(controller: _controller)
                            : Image.asset("imagenes/video-not.png"),
                        Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "$title",
                              style: new TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.justify,
                            )),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: (overview != "")
                              ? Text(
                                  "$overview",
                                  style: new TextStyle(fontSize: 15.0),
                                  textAlign: TextAlign.justify,
                                )
                              : Text(
                                  "Overview not available",
                                  style: new TextStyle(fontSize: 15.0),
                                  textAlign: TextAlign.justify,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "Cast",
                            style: new TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        Container(
                          height: 150,
                          child:(!isConected) ? Text("No Internet Connection")
                               :  ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: movieCast == null ? 0 : movieCast.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 40,
                                        backgroundImage: (movieCast[index]
                                                    .profile_path !=
                                                null)
                                            ? NetworkImage(
                                                "https://image.tmdb.org/t/p/w500${movieCast[index].profile_path}")
                                            : Image.asset(
                                                "imagenes/img-not.jpg")),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      movieCast[index].name,
                                      style: new TextStyle(fontSize: 15.0),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },

                  //)
                )),
    );
  }
}
