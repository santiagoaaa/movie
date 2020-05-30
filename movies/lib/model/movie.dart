import 'dart:convert';

class Movie {
  final double popularity;
  final int vote_count;
  final String poster_path;
  final int id;
  final String backdrop_path;
  final String original_language;
  final String original_title;
  final String title;
  final String overview;

  Movie(
      {this.popularity,
      this.vote_count,
      this.poster_path,
      this.id,
      this.backdrop_path,
      this.original_language,
      this.original_title,
      this.title,
      this.overview});


  Map<String, dynamic> toMap() {
    return {
      'poster_path': poster_path,
      'id': id,
      'backdrop_path': backdrop_path,
      'title': title,
      'overview': overview
    };
  }
}
