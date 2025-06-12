import 'package:flutter/material.dart';
import 'package:melody/melody/core/models/song/song.dart';
import 'package:melody/melody/core/services/recommendation_service.dart';
import 'package:melody/melody/presentations/screens/playing/playing.dart';
import 'package:melody/melody/presentations/screens/playing/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendationsScreen extends StatefulWidget {
  final Song currentSong;

  const RecommendationsScreen({
    Key? key,
    required this.currentSong,
  }) : super(key: key);

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  List<Song> _recommendations = [];
  bool _isLoading = true;
  String error = '';
  late PlaylistProvider playlistProvider;

  @override
  void initState() {
    super.initState();
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      error = '';
    });

    try {
      print('Loading recommendations for song: ${widget.currentSong.songName}');
      final recommendations =
          await RecommendationService.getRecommendations(widget.currentSong);
      print('Received ${recommendations.length} recommendations');

      if (!mounted) return;

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error loading recommendations: $e');
      print('Stack trace: $stackTrace');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        error = e.toString();
      });
    }
  }

  Future<void> _openInSpotify(String spotifyId) async {
    final url = 'spotify:track:$spotifyId';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Fallback to web URL
      final webUrl = 'https://open.spotify.com/track/$spotifyId';
      if (await canLaunchUrl(Uri.parse(webUrl))) {
        await launchUrl(Uri.parse(webUrl));
      }
    }
  }

  String _cleanImageUrl(String url) {
    // Remove any trailing commas or other invalid characters
    return url.split(',')[0].trim();
  }

  void _onSongTap(Song song) {
    List<Song> copiedSongList = [song];
    playlistProvider.playlist.clear();
    playlistProvider.setPlaylist(copiedSongList);
    playlistProvider.currentSongIndex = 0;
    Navigator.of(context).pushNamed(Playing.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended Songs'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecommendations,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecommendations,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_recommendations.isEmpty) {
      return const Center(
        child: Text('No recommendations found'),
      );
    }

    return ListView.builder(
      itemCount: _recommendations.length,
      itemBuilder: (context, index) {
        final song = _recommendations[index];
        final cleanImageUrl = _cleanImageUrl(song.songImagePath);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Card(
            elevation: 2,
            child: InkWell(
              onTap: () => _onSongTap(song),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // Song image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        cleanImageUrl.isNotEmpty
                            ? cleanImageUrl
                            : 'https://i.imgur.com/6VBx3io.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          print('Image URL: $cleanImageUrl');
                          return Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey[300],
                            child: const Icon(Icons.music_note),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Song info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Song name
                          Text(
                            song.songName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Artist name
                          Text(
                            song.artistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Play button
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => _onSongTap(song),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    if (song.spotifyId.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => _openInSpotify(song.spotifyId),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
