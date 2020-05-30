import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movies/model/movie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movies/pages/item.dart';

class Search extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchState();
}

class SearchState extends State<Search> {
  var _isSearching = true;
  Map<String, dynamic> dataMovie;
  List<Movie> movies = [];
  var isloading = true;
  var isConnected = true;
  Item item;
  TextEditingController txtSearch = TextEditingController();

  void startSearching() {
    setState(() {
      _isSearching = true;
    });
  }

  void onSearchCancel() {
    setState(() {
      _isSearching = false;
    });
  }
//https://api.themoviedb.org/3/search/movie?api_key=418f34125f6649eb790ee7a0777c0cbc&query=\(self.searchMovie)&page=1&include_adult=false

  Future<String> searching() async {
    this.setState(() {
      isloading = true;
    });

    movies = [];

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        var movieFounded = txtSearch.text;
        print("Buscando $movieFounded");
        var response = await http.get(
            Uri.encodeFull(
                "https://api.themoviedb.org/3/search/movie?api_key=418f34125f6649eb790ee7a0777c0cbc&language=es-MX&query=$movieFounded&page=1&include_adult=false"),
            headers: {"Accept": "application/json"});
        this.setState(() {
          dataMovie = json.decode(response.body);
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

            movies.add(movie);
          }

          print(movies.length);
          isloading = false;
          isConnected = true;
        });
      }
    } on SocketException catch (_) {
      print('not connected********************');
      isConnected = false;
      isloading = true;
      this.setState((){
        isloading = true;
        isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
        home: Scaffold(
      appBar: _isSearching
          ? getAppBarSearching(onSearchCancel, txtSearch)
          : getAppBarNotSearching("Search Movies", startSearching),
      body: isloading
          ? Center(
              child: isConnected ? CircularProgressIndicator() : Text("No Internet Connection",style: new TextStyle(fontSize: 15.0),
                                  textAlign: TextAlign.justify,)
            ) : item = new Item(movies) 
           
    ));
  }

  Widget getAppBarNotSearching(String title, Function startSearchFunction) {
    return AppBar(
      backgroundColor: Color(0xff091059),
      title: Text(title),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              startSearchFunction();
            }),
      ],
    );
  }

  Widget getAppBarSearching(
      Function cancelSearch,
      /*Function searching,*/
      TextEditingController searchController) {
    return AppBar(
      backgroundColor: Color(0xff091059),
      automaticallyImplyLeading: false,
      leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            cancelSearch();
          }),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 10),
        child: TextField(
          controller: searchController,
          onEditingComplete: () async {
            await searching();
            cancelSearch();
          },
          style: new TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          autofocus: true,
          decoration: InputDecoration(
            focusColor: Colors.white,
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
