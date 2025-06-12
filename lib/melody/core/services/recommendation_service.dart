import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:melody/melody/core/models/song/song.dart';
import 'package:melody/melody/core/models/firebase/song_request.dart';
import 'package:melody/melody/core/models/song/musical_features.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show rootBundle;

class RecommendationService {
  static const String _baseUrl = 'https://melody-recommendation.onrender.com';
  static const Duration _timeout = Duration(seconds: 10);
  static final Map<String, MusicalFeatures> _featuresCache = {};
  static bool _isCacheInitialized = false;

  static Future<void> _initializeCache() async {
    if (_isCacheInitialized) return;

    try {
      final String csvData = await rootBundle.loadString('assets/data.csv');
      final lines = csvData.split('\n');
      print('Initializing cache with ${lines.length} songs...');

      for (final line in lines) {
        if (line.trim().isEmpty) continue;

        try {
          final values = line.split(',');
          if (values.length < 20) continue;

          final songName = values[14].toLowerCase().trim();
          String artistName = values[3].toLowerCase().trim();

          // Clean up artist name
          if (artistName.startsWith('[') && artistName.endsWith(']')) {
            artistName = artistName.substring(1, artistName.length - 1);
          }
          if (artistName.startsWith('"') && artistName.endsWith('"')) {
            artistName = artistName.substring(1, artistName.length - 1);
          }
          if (artistName.startsWith("'") && artistName.endsWith("'")) {
            artistName = artistName.substring(1, artistName.length - 1);
          }

          final features = MusicalFeatures(
            acousticness: double.tryParse(values[2]) ?? 0.5,
            danceability: double.tryParse(values[4]) ?? 0.7,
            energy: double.tryParse(values[6]) ?? 0.8,
            instrumentalness: double.tryParse(values[9]) ?? 0.2,
            liveness: double.tryParse(values[11]) ?? 0.3,
            loudness: double.tryParse(values[12]) ?? -6.0,
            speechiness: double.tryParse(values[17]) ?? 0.1,
            tempo: double.tryParse(values[18]) ?? 120.0,
            valence: double.tryParse(values[0]) ?? 0.6,
            key: int.tryParse(values[10]) ?? 0,
            mode: int.tryParse(values[13]) ?? 0,
            durationMs: int.tryParse(values[5]) ?? 180000,
            timeSignature: 4,
          );

          final key = '$songName|$artistName';
          _featuresCache[key] = features;
        } catch (e) {
          print('Error processing line for cache: $e');
          continue;
        }
      }

      print('Cache initialized with ${_featuresCache.length} songs');
      _isCacheInitialized = true;
    } catch (e) {
      print('Error initializing cache: $e');
    }
  }

  static Future<List<Song>> getRecommendations(Song song) async {
    try {
      // Validate song data before sending
      if (song.songName.isEmpty || song.artistName.isEmpty) {
        throw Exception('Song name and artist name are required');
      }

      // Log original features
      print('Original features from Firebase:');
      print('acousticness: ${song.features.acousticness}');
      print('danceability: ${song.features.danceability}');
      print('energy: ${song.features.energy}');
      print('instrumentalness: ${song.features.instrumentalness}');
      print('liveness: ${song.features.liveness}');
      print('loudness: ${song.features.loudness}');
      print('speechiness: ${song.features.speechiness}');
      print('tempo: ${song.features.tempo}');
      print('valence: ${song.features.valence}');
      print('key: ${song.features.key}');
      print('mode: ${song.features.mode}');
      print('duration_ms: ${song.features.durationMs}');
      print('time_signature: ${song.features.timeSignature}');

      // Create request body with features at root level
      final requestBody = {
        'song_name': song.songName,
        'artist_name': song.artistName,
        'genre': song.genre,
        'acousticness': song.features.acousticness,
        'danceability': song.features.danceability,
        'energy': song.features.energy,
        'instrumentalness': song.features.instrumentalness,
        'liveness': song.features.liveness,
        'loudness': song.features.loudness,
        'speechiness': song.features.speechiness,
        'tempo': song.features.tempo,
        'valence': song.features.valence,
        'key': song.features.key,
        'mode': song.features.mode,
        'duration_ms': song.features.durationMs,
        'time_signature': song.features.timeSignature,
      };

      print('Request body: ${jsonEncode(requestBody)}');

      final client = http.Client();
      final response = await client
          .post(
            Uri.parse('$_baseUrl/recommend'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      client.close();

      if (response.statusCode == 200) {
        // Clean the response body to handle NaN values
        String cleanedResponse = response.body.replaceAll('NaN', 'null');
        print('Cleaned response: $cleanedResponse');

        final List<dynamic> data = jsonDecode(cleanedResponse);
        return data.map((item) {
          // Clean up the response data
          final cleanedItem = Map<String, dynamic>.from(item);

          // Handle image URL
          String imageUrl = _validateUrl(cleanedItem['songImagePath'] ?? '');

          // Handle artist name that might come as a list
          String artistName = cleanedItem['artistName'] ?? '';
          if (artistName.startsWith('[') && artistName.endsWith(']')) {
            artistName = artistName.substring(1, artistName.length - 1);
          }

          return Song(
            songId: cleanedItem['songId'] ?? '',
            songName: cleanedItem['songName'] ?? '',
            artistId: cleanedItem['artistId'] ?? '',
            artistName: artistName,
            songImagePath: imageUrl,
            audioPath: cleanedItem['audioPath'] ?? '',
            spotifyId: cleanedItem['spotifyId'] ?? '',
            genre: cleanedItem['genre'] ?? 'Unknown',
            features: MusicalFeatures(
              acousticness: (cleanedItem['acousticness'] ?? 0.0).toDouble(),
              danceability: (cleanedItem['danceability'] ?? 0.0).toDouble(),
              energy: (cleanedItem['energy'] ?? 0.0).toDouble(),
              instrumentalness:
                  (cleanedItem['instrumentalness'] ?? 0.0).toDouble(),
              liveness: (cleanedItem['liveness'] ?? 0.0).toDouble(),
              loudness: (cleanedItem['loudness'] ?? 0.0).toDouble(),
              speechiness: (cleanedItem['speechiness'] ?? 0.0).toDouble(),
              tempo: (cleanedItem['tempo'] ?? 0.0).toDouble(),
              valence: (cleanedItem['valence'] ?? 0.0).toDouble(),
              key: (cleanedItem['key'] ?? 0).toInt(),
              mode: (cleanedItem['mode'] ?? 0).toInt(),
              durationMs: (cleanedItem['duration_ms'] ?? 0).toInt(),
              timeSignature: (cleanedItem['time_signature'] ?? 4).toInt(),
            ),
          );
        }).toList();
      } else {
        print('Error response body: ${response.body}');
        final errorBody = jsonDecode(response.body);
        final errorMessage =
            errorBody['error'] ?? 'Failed to get recommendations';
        throw Exception('$errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error getting recommendations: $e');
      rethrow;
    }
  }

  static String _validateUrl(String url) {
    if (url.isEmpty ||
        url.toLowerCase() == 'nan' ||
        url.toLowerCase() == 'none') {
      return 'https://i.imgur.com/6VBx3io.png';
    }

    // Clean up URL if it's in a list format
    if (url.startsWith('[') && url.endsWith(']')) {
      url = url.substring(1, url.length - 1);
    }

    // Remove any extra quotes
    url = url.replaceAll('"', '').replaceAll("'", '');

    return url;
  }

  static double _normalizeFeature(double value, double min, double max) {
    if (value.isNaN || value.isInfinite) {
      return min;
    }
    return value.clamp(min, max);
  }

  static Future<MusicalFeatures?> getFeaturesFromCSV(
      String songName, String artistName) async {
    try {
      if (songName.isEmpty || artistName.isEmpty) {
        print('Song name or artist name is empty');
        return null;
      }

      // Initialize cache if not already done
      if (!_isCacheInitialized) {
        await _initializeCache();
      }

      // Normalize the search terms
      final normalizedSongName = songName.toLowerCase().trim();
      final normalizedArtistName = artistName.toLowerCase().trim();

      print(
          'Searching for song: "$normalizedSongName" by "$normalizedArtistName" in cache');

      // Try exact match first
      final key = '$normalizedSongName|$normalizedArtistName';
      if (_featuresCache.containsKey(key)) {
        print('Found exact match in cache');
        return _featuresCache[key];
      }

      // Try partial matches
      for (final entry in _featuresCache.entries) {
        final [cachedSong, cachedArtist] = entry.key.split('|');
        if (cachedSong.contains(normalizedSongName) &&
            cachedArtist.contains(normalizedArtistName)) {
          print('Found partial match in cache');
          return entry.value;
        }
      }

      print('No matching song found in cache');
      return null;
    } catch (e) {
      print('Error in getFeaturesFromCSV: $e');
      return null;
    }
  }
}
