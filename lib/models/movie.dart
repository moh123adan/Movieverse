class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final String overview;
  final double voteAverage;
  final int runtime;
  final String mediaType;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.overview,
    required this.voteAverage,
    required this.runtime,
    required this.mediaType,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      runtime: json['runtime'] ?? 0,
      mediaType: json['media_type'] ?? 'movie',
    );
  }
}

