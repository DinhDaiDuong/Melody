import 'package:flutter/material.dart';
import 'package:melody/melody/core/models/song/song.dart';
import 'package:melody/melody/core/services/recommendation_service.dart';
import 'package:melody/melody/presentations/screens/playing/playing.dart';
import 'package:melody/melody/presentations/screens/playing/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:io' show Platform;

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
    try {
      final spotifyAppUri = Uri.parse('spotify:track:$spotifyId');
      final webUrl = Uri.parse('https://open.spotify.com/track/$spotifyId');

      if (await canLaunchUrl(spotifyAppUri)) {
        final launched = await launchUrl(
          spotifyAppUri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );

        if (!launched) {
          if (await canLaunchUrl(webUrl)) {
            await launchUrl(
              webUrl,
              mode: LaunchMode.externalApplication,
              webViewConfiguration: const WebViewConfiguration(
                enableJavaScript: true,
                enableDomStorage: true,
              ),
            );
          }
        }
      } else {
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(
            webUrl,
            mode: LaunchMode.externalApplication,
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: true,
              enableDomStorage: true,
            ),
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Không thể mở Spotify. Vui lòng kiểm tra lại ứng dụng Spotify đã được cài đặt.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error launching Spotify: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi mở Spotify: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _cleanImageUrl(String url) {
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Recommended Songs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
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
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadRecommendations,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_recommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.music_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No recommendations found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _recommendations.length,
      itemBuilder: (context, index) {
        final song = _recommendations[index];
        final cleanImageUrl = _cleanImageUrl(song.songImagePath);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: InkWell(
              onTap: () => _onSongTap(song),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Song image
                    Hero(
                      tag: 'song_image_${song.songName}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          cleanImageUrl.isNotEmpty
                              ? cleanImageUrl
                              : 'https://i.imgur.com/6VBx3io.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image: $error');
                            print('Image URL: $cleanImageUrl');
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_circle_outline),
                          onPressed: () => _onSongTap(song),
                          iconSize: 28,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        if (song.spotifyId.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.music_note),
                            onPressed: () => _openInSpotify(song.spotifyId),
                            iconSize: 28,
                            color: const Color(0xFF1DB954), // Spotify green
                          ),
                      ],
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
