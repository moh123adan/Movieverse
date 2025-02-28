import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import './discover_screen.dart';
import './favorite_screen.dart';
import './profile_screen.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final MovieService _movieService = MovieService();
  List<Movie> popularMovies = [];
  List<Movie> trendingMovies = [];
  bool isLoading = true;
  String? error;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMovies();
    Get.lazyPut(() => AuthController());
  }

  Future<void> _loadMovies() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final popular = await _movieService.getPopularMovies();
      final trending = await _movieService.getTrendingMovies();

      if (mounted) {
        setState(() {
          popularMovies = popular;
          trendingMovies = trending;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Already on Home screen
        break;
      case 1:
        Get.offAll(() => const DiscoverScreen());
        break;
      case 2:
        Get.offAll(() => const FavoriteScreen());
        break;
      case 3:
        Get.offAll(() => ProfileScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadMovies,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildContent(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'Stream ',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Everywhere',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    } else if (error != null) {
      return _buildErrorWidget();
    } else {
      return Column(
        children: [
          _buildSection('Popular', popularMovies),
          const SizedBox(height: 24),
          _buildSection('Trending', trendingMovies),
        ],
      );
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
          ElevatedButton(
            onPressed: _loadMovies,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Movie> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) => _buildMovieCard(movies[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'See all',
            style: TextStyle(color: Colors.orange),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _movieService.getImageUrl(movie.posterPath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildErrorImage(),
                loadingBuilder: (context, child, loadingProgress) =>
                    _buildLoadingImage(child, loadingProgress),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          _buildRating(movie.voteAverage),
        ],
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLoadingImage(Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
        color: Colors.orange,
      ),
    );
  }

  Widget _buildRating(double rating) {
    return Row(
      children: [
        const Icon(
          Icons.star,
          color: Colors.amber,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
