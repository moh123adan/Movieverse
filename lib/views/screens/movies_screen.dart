import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';

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
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMovies();
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
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on MoviesScreen, no action needed
        Get.offAllNamed('/'); // Home screen
        break;
      case 1:
        Get.offAllNamed('/discover'); // Navigate to DiscoverScreen
        break;
      case 2:
        Get.offAllNamed('/favorites'); // Navigate to FavoriteScreen
        break;
      case 3:
        Get.offAllNamed('/profile'); // Navigate to ProfileScreen
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
                  // _buildHeader(),
                  // const SizedBox(height: 24),
                  // _buildContent(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ... (keep all other widget building methods the same)

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[900]!,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal[300],
        unselectedItemColor: Colors.grey[600],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
