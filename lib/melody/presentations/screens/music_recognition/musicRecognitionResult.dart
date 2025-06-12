import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:melody/melody/core/models/musicRecognitionResponse/music_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:melody/melody/presentations/screens/artist/widgets/song_item.dart';
import 'package:melody/melody/presentations/screens/playing/playing.dart';
import 'package:melody/melody/presentations/screens/playing/playlist_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/models/firebase/song_request.dart';
import '../../../core/models/song/song.dart';
import '../../../core/services/recommendation_service.dart';

class MusicRecognitionResultScreen extends StatefulWidget {
  MusicRecognitionResultScreen({super.key, required this.path});
  String path;
  @override
  State<MusicRecognitionResultScreen> createState() =>
      _MusicRecognitionResultScreenState();
}

class _MusicRecognitionResultScreenState
    extends State<MusicRecognitionResultScreen> {
  MusicRecognitionResponse? musicRecognitionResponse;
  String error = '';
  Song? songResult;
  late PlaylistProvider playlistProvider;
  List<Song> similarSongs = [];

  @override
  void initState() {
    super.initState();
    String apiToken = '99896206c98b4cc71e59e022f39c98c2';
    String path = widget.path;
    uploadAudioAndCallAuddAPI(path, apiToken);
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
  }

  Future<void> uploadAudioAndCallAuddAPI(
      String filePath, String apiToken) async {
    // URL provided by the API documentation
    const String apiUrl = 'https://api.audd.io/';

    // Prepare the API request
    var uri = Uri.parse(apiUrl);
    var request = http.MultipartRequest('POST', uri)
      ..fields['return'] = 'apple_music,spotify'
      ..fields['api_token'] = apiToken;

    // Add the file to the request
    var file = await http.MultipartFile.fromPath('file', filePath);
    request.files.add(file);

    // Send the request
    try {
      var response = await request.send();

      // Listen for the response
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
        setState(() {
          musicRecognitionResponse =
              MusicRecognitionResponse.fromJson(jsonDecode(value));
        });
        // After getting recognition result, fetch similar songs
        if (musicRecognitionResponse?.result?.artist != null) {
          _fetchSimilarSongs();
        }
      });
    } catch (e) {
      // Handle any exceptions here
      print('Failed to upload file: $e');
      setState(() {
        error = 'Failed to upload file: $e';
      });
    }
  }

  Future<void> _fetchSimilarSongs() async {
    try {
      print('Fetching similar songs...');
      // Get all songs from database
      List<Song> songs = [];
      try {
        songs = await SongRequest.getAllSongs().first;
        print('Successfully fetched ${songs.length} songs from database');
      } catch (e) {
        print('Error fetching songs from database: $e');
        setState(() {
          error =
              'Failed to fetch songs from database. Please check your internet connection and try again.';
        });
        return;
      }

      if (songs.isEmpty) {
        print('No songs found in database');
        setState(() {
          error = 'No songs found in database';
        });
        return;
      }

      // First find the exact song in database
      Song? currentSong;
      try {
        currentSong = songs.firstWhere(
          (song) =>
              song.songName.toLowerCase() ==
              musicRecognitionResponse!.result!.title!.toLowerCase(),
        );
        print(
            'Found exact match: ${currentSong.songName} by ${currentSong.artistName}');
      } catch (e) {
        print('No exact match found');
        // If no exact match, use the first song by the same artist
        try {
          currentSong = songs.firstWhere(
            (song) =>
                song.artistName.toLowerCase() ==
                musicRecognitionResponse!.result!.artist!.toLowerCase(),
          );
          print('Using first song by same artist: ${currentSong.songName}');
        } catch (e) {
          print('No songs found by this artist');
          setState(() {
            error = 'No similar songs found for this artist';
          });
          return;
        }
      }

      // Check if the song has musical features
      if (currentSong.features.acousticness == 0.0 &&
          currentSong.features.danceability == 0.0 &&
          currentSong.features.energy == 0.0 &&
          currentSong.features.instrumentalness == 0.0 &&
          currentSong.features.liveness == 0.0 &&
          currentSong.features.loudness == 0.0 &&
          currentSong.features.speechiness == 0.0 &&
          currentSong.features.tempo == 0.0 &&
          currentSong.features.valence == 0.0) {
        print('Song has no musical features, falling back to artist matching');
        setState(() {
          similarSongs = songs
              .where((song) =>
                  song.artistName.toLowerCase() ==
                  musicRecognitionResponse!.result!.artist!.toLowerCase())
              .toList();
        });
        print('Found ${similarSongs.length} songs by the same artist');
        return;
      }

      // Get recommendations using ML system
      try {
        final recommendations =
            await RecommendationService.getRecommendations(currentSong);
        setState(() {
          similarSongs = recommendations;
        });
        print('Found ${similarSongs.length} recommendations from ML system');
      } catch (e) {
        print('Error getting ML recommendations: $e');
        // Fallback to simple artist matching
        setState(() {
          similarSongs = songs
              .where((song) =>
                  song.artistName.toLowerCase() ==
                  musicRecognitionResponse!.result!.artist!.toLowerCase())
              .toList();
        });
        print(
            'Falling back to artist matching, found ${similarSongs.length} songs');
      }
    } catch (e) {
      print('Error fetching similar songs: $e');
      setState(() {
        error = 'Error fetching similar songs: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Recognition Result'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: musicRecognitionResponse == null
                  ? error.isNotEmpty
                      ? Text(error)
                      : CircularProgressIndicator()
                  : StreamBuilder<List<Song>>(
                      stream: SongRequest.getAllSongs(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: Failed fetching songs"),
                          );
                        } else {
                          if (snapshot.data != null) {
                            try {
                              songResult = snapshot.data!.firstWhere((element) {
                                if (musicRecognitionResponse!.result!.title !=
                                    null) {
                                  return element.songName.contains(
                                          musicRecognitionResponse!
                                              .result!.title!) ||
                                      musicRecognitionResponse!.result!.title!
                                          .contains(element.songName);
                                }
                                return false;
                              });
                            } catch (e) {
                              print('Song not found');
                            }
                          }
                          return songResult != null
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: SongItem(
                                    song: songResult!,
                                    onTap: () {
                                      _onSongTap();
                                    },
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        'Title: ${musicRecognitionResponse!.result?.title ?? ""}'),
                                    Text(
                                        'Artist: ${musicRecognitionResponse!.result?.artist}'),
                                    Text(
                                        'Album: ${musicRecognitionResponse!.result?.album}'),
                                    Text(
                                        'Release Date: ${musicRecognitionResponse?.result!.releaseDate}'),
                                    Text(
                                        'Label: ${musicRecognitionResponse!.result?.label}'),
                                    Text(
                                        'Spotify URL: ${musicRecognitionResponse?.result!.spotify != null ? musicRecognitionResponse?.result!.spotify!.externalUrls!.spotify : ""}'),
                                    Text(
                                        'Apple Music URL: ${musicRecognitionResponse?.result!.appleMusic != null ? musicRecognitionResponse?.result!.appleMusic!.isrc : ""}'),
                                  ],
                                );
                        }
                      },
                    ),
            ),
            if (similarSongs.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Similar Songs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: similarSongs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SongItem(
                      song: similarSongs[index],
                      onTap: () {
                        _onSimilarSongTap(similarSongs[index]);
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onSongTap() {
    if (songResult != null) {
      // Create a copy of the songList
      List<Song> copiedSongList = [songResult!];

      // Set the copiedSongList to the playlistProvider
      playlistProvider.playlist.clear();
      playlistProvider.setPlaylist(copiedSongList);

      // Set the currentSongIndex and navigate to the playing screen
      playlistProvider.currentSongIndex = 0;
      Navigator.of(context).pushNamed(Playing.routeName);
    }
  }

  void _onSimilarSongTap(Song song) {
    List<Song> copiedSongList = [song];
    playlistProvider.playlist.clear();
    playlistProvider.setPlaylist(copiedSongList);
    playlistProvider.currentSongIndex = 0;
    Navigator.of(context).pushNamed(Playing.routeName);
  }
}
