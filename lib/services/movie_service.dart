import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';

class MovieService {
  final String baseUrl = 'https://api.themoviedb.org/3';
  final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
  final String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://via.placeholder.com/500x750?text=No+Image';
    }
    return '$imageBaseUrl$path';
  }

  Future<List<Movie>> _getMedia(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint?api_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((item) => Movie.fromJson(item))
            .toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load media: $e');
    }
  }

  Future<List<Movie>> getPopularMovies() async {
    return _getMedia('/movie/popular');
  }

  Future<List<Movie>> getTrendingMovies() async {
    return _getMedia('/trending/movie/day');
  }

  Future<List<Movie>> getPopularTVShows() async {
    return _getMedia('/tv/popular');
  }

  Future<List<Movie>> getTrendingTVShows() async {
    return _getMedia('/trending/tv/day');
  }

  Future<List<Movie>> searchMedia(String query, String type) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/search/$type?api_key=$apiKey&query=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((item) => Movie.fromJson(item))
            .toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search $type: $e');
    }
  }

  Future<List<Movie>> getSimilarMovies(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/$movieId/similar?api_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load similar movies: $e');
    }
  }

  Future<List<Movie>> getMediaByCategory(String category) async {
    switch (category) {
      case 'Movies':
        return getPopularMovies();
      case 'Tv Series':
        return getPopularTVShows();
      case 'Trending Movies':
        return getTrendingMovies();
      case 'Trending TV':
        return getTrendingTVShows();
      default:
        throw Exception('Invalid category');
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/$movieId?api_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Movie.fromJson(data);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load movie details: $e');
    }
  }

  Future<String?> getMovieTrailer(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/$movieId/videos?api_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final videos = data['results'] as List;
        final trailer = videos.firstWhere(
          (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
          orElse: () => null,
        );
        return trailer != null ? trailer['key'] as String : null;
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load movie trailer: $e');
    }
  }
}
