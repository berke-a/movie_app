class MovieInfo {
  final String title;
  final String year;
  final String plot;
  final String poster;
  final String imdbRating;

  MovieInfo({
    this.title,
    this.year,
    this.plot,
    this.poster,
    this.imdbRating,
  });

  factory MovieInfo.fromJSON(Map<String, dynamic> json) {
    return MovieInfo(
      title: json['name'],
      year: json['release_date'],
      plot: json['overview'],
      poster: json['poster_path'],
      imdbRating: json['vote_average'],
    );
  }
}
