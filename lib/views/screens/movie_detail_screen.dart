import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import '../../providers/favorite_provider.dart';
import './favorite_screen.dart';
import './movies_screen.dart';
import './discover_screen.dart';
import './profile_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieService _movieService = MovieService();
  List<Movie> relatedMovies = [];
  bool isLoading = true;
  String? errorMessage;
  bool isExpanded = false;
  String? trailerUrl;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRelatedMovies();
    _loadTrailer();
  }

  Future<void> _loadRelatedMovies() async {
    try {
      final movies = await _movieService.getSimilarMovies(widget.movie.id);
      if (mounted) {
        setState(() {
          relatedMovies = movies;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadTrailer() async {
    try {
      final trailerKey = await _movieService.getMovieTrailer(widget.movie.id);
      if (trailerKey != null && mounted) {
        setState(() {
          trailerUrl = 'https://www.youtube.com/watch?v=$trailerKey';
        });
      }
    } catch (e) {
      debugPrint('Failed to load trailer: $e');
    }
  }

  Future<void> _launchTrailer() async {
    if (trailerUrl != null) {
      try {
        final canLaunchResult = await canLaunchUrlString(trailerUrl!);
        if (canLaunchResult) {
          await launchUrlString(trailerUrl!,
              mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not launch trailer')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error launching trailer')),
          );
        }
      }
    }
  }

  void _handleNavigation(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Get.offAll(() => const MoviesScreen());
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
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _buildHeader(),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Consumer<FavoriteProvider>(
                          builder: (context, provider, _) {
                            final isFavorite =
                                provider.isFavorite(widget.movie.id);
                            return IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.white,
                              ),
                              onPressed: () {
                                provider.toggleFavorite(widget.movie);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMovieInfo(),
                  const SizedBox(height: 24),
                  _buildTrailerButton(),
                  const SizedBox(height: 24),
                  _buildSynopsis(),
                  const SizedBox(height: 24),
                  _buildRelatedMovies(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
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
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              _movieService.getImageUrl(widget.movie.backdropPath)),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.movie.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '4K',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '${widget.movie.runtime} minutes',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              widget.movie.voteAverage.toStringAsFixed(1),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Release date',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.movie.releaseDate,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Genre',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildGenreChip('Action'),
                      const SizedBox(width: 8),
                      _buildGenreChip('Sci-Fi'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenreChip(String genre) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        genre,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTrailerButton() {
    if (trailerUrl == null) {
      return const SizedBox.shrink();
    }
    return ElevatedButton.icon(
      onPressed: _launchTrailer,
      icon: const Icon(Icons.play_arrow),
      label: const Text('Watch Trailer'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildSynopsis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Synopsis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.movie.overview,
          maxLines: isExpanded ? null : 3,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Text(
            isExpanded ? 'Show less' : 'Read more...',
            style: const TextStyle(color: Colors.orange),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedMovies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Related Movies',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.orange))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: relatedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = relatedMovies[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MovieDetailScreen(movie: movie),
                          ),
                        );
                      },
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _movieService.getImageUrl(movie.posterPath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
