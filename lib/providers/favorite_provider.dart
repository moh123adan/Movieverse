import 'package:flutter/foundation.dart';
import '../models/movie.dart';

class FavoriteProvider extends ChangeNotifier {
  final Set<int> _favoriteIds = {};
  final List<Movie> _favorites = [];

  List<Movie> get favorites => _favorites;

  bool isFavorite(int movieId) => _favoriteIds.contains(movieId);

  void loadFavorites() {
    // This method is now empty since we're not persisting data
    // You can remove it if not needed elsewhere in your app
  }

  void toggleFavorite(Movie movie) {
    if (_favoriteIds.contains(movie.id)) {
      _favoriteIds.remove(movie.id);
      _favorites.removeWhere((m) => m.id == movie.id);
    } else {
      _favoriteIds.add(movie.id);
      _favorites.add(movie);
    }

    notifyListeners();
  }
}
