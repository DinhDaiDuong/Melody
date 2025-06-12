import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:melody/melody/core/models/song/song.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:melody/melody/core/helper/firebase_helper.dart';
import 'package:melody/melody/core/models/song/musical_features.dart';

class SongRequest {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'Songs';

  static Stream<List<Song>> getAllSongs() {
    try {
      print('Starting to fetch songs from Firestore...');
      return _firestore.collection(_collectionName).snapshots().map((snapshot) {
        print(
            'Firestore snapshot received with ${snapshot.docs.length} documents');

        if (snapshot.docs.isEmpty) {
          print('No documents found in collection $_collectionName');
          return [];
        }

        final songs = snapshot.docs.map((doc) {
          try {
            final data = doc.data();
            print('Processing document ID: ${doc.id}');
            print('Document data: $data');

            final song = Song(
              songId: data['songId'] ?? doc.id,
              songName: data['songName'] ?? '',
              artistId: data['artistId'] ?? '',
              artistName: data['artistName'] ?? '',
              songImagePath: data['songImagePath'] ?? '',
              audioPath: data['audioPath'] ?? '',
              spotifyId: data['spotifyId'] ?? '',
              genre: data['genre'] ?? '',
              features: MusicalFeatures(
                acousticness: (data['acousticness'] ?? 0.0).toDouble(),
                danceability: (data['danceability'] ?? 0.0).toDouble(),
                energy: (data['energy'] ?? 0.0).toDouble(),
                instrumentalness: (data['instrumentalness'] ?? 0.0).toDouble(),
                liveness: (data['liveness'] ?? 0.0).toDouble(),
                loudness: (data['loudness'] ?? 0.0).toDouble(),
                speechiness: (data['speechiness'] ?? 0.0).toDouble(),
                tempo: (data['tempo'] ?? 0.0).toDouble(),
                valence: (data['valence'] ?? 0.0).toDouble(),
                key: (data['key'] ?? 0).toInt(),
                mode: (data['mode'] ?? 0).toInt(),
                durationMs: (data['duration_ms'] ?? 0).toInt(),
                timeSignature: (data['time_signature'] ?? 0).toInt(),
              ),
              times: (data['times'] as List<dynamic>?)?.map((timestamp) {
                    if (timestamp is Timestamp) {
                      return timestamp.toDate();
                    }
                    return DateTime.now();
                  }).toList() ??
                  [],
              commentsIds: List<String>.from(data['commentsIds'] ?? []),
            );
            print('Successfully created song: ${song.songName}');
            return song;
          } catch (e) {
            print('Error processing document ${doc.id}: $e');
            rethrow;
          }
        }).toList();

        print('Successfully processed ${songs.length} songs');
        return songs;
      });
    } catch (e, stackTrace) {
      print('Error in getAllSongs: $e');
      print('Stack trace: $stackTrace');
      return Stream.value([]);
    }
  }

  static Future<void> addSong(Song song) async {
    try {
      print('Adding song to Firestore: ${song.songName}');
      await _firestore.collection(_collectionName).doc(song.songId).set({
        'songId': song.songId,
        'songName': song.songName,
        'artistId': song.artistId,
        'artistName': song.artistName,
        'songImagePath': song.songImagePath,
        'audioPath': song.audioPath,
        'spotifyId': song.spotifyId,
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
        'times': song.times.map((time) => Timestamp.fromDate(time)).toList(),
        'commentsIds': song.commentsIds,
      });
      print('Successfully added song to Firestore');
    } catch (e) {
      print('Error adding song: $e');
      throw Exception('Error adding song: $e');
    }
  }

  static Future<void> updateMusicalFeatures(
      String songId, Map<String, dynamic> features) async {
    try {
      await FirebaseHelper.songCollection.doc(songId).update(features);
    } catch (e) {
      print('Error updating musical features: $e');
      throw Exception('Error updating musical features: $e');
    }
  }

  static Stream<List<Song>> getAllByArtistId(String artistId) =>
      FirebaseFirestore.instance
          .collection('Songs')
          .where('artistId', isEqualTo: artistId)
          .snapshots()
          .map((event) =>
              event.docs.map((e) => Song.fromJson(e.data())).toList());
  static Stream<List<Song>> getAll() => FirebaseFirestore.instance
      .collection('Songs')
      .snapshots()
      .map((event) => event.docs.map((e) => Song.fromJson(e.data())).toList());
  static Future<Song> getById(String id) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('Songs').doc(id).get();
    Song song = Song.fromJson(doc.data()!);
    return Future.value(song);
  }

  Future<Song> getSongById(String songId) async {
    DocumentSnapshot songDoc =
        await FirebaseFirestore.instance.collection('Songs').doc(songId).get();
    return Song.fromJson(songDoc.data() as Map<String, dynamic>);
  }

  static List<Song> AllSongs = [];

  static List<Timestamp> _sendAtToJson(List<DateTime> times) =>
      times.map((time) => Timestamp.fromDate(time)).toList();
  static Future<void> updateCount(String songId) async {
    var songDoc =
        await FirebaseFirestore.instance.collection('Songs').doc(songId).get();
    Song song = Song.fromJson(songDoc.data()!);
    List<DateTime> times = List.from(song.times);
    times.add(DateTime.now());
    FirebaseFirestore.instance
        .collection('Songs')
        .doc(songId)
        .update({"times": _sendAtToJson(times)});
  }

  static Future<void> downloadSong(String audioPath, String songName) async {
    // Request storage permissions
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      Fluttertoast.showToast(msg: "Storage permission not granted");
      throw Exception('Storage permission not granted');
    }

    // Get the directory to save the file
    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      throw Exception('Unable to get external storage directory');
    }
    String savePath = '${externalDir.path}/$songName.mp3';

    try {
      // Create a reference to the file you want to download
      Reference ref = FirebaseStorage.instance.refFromURL(audioPath);

      // Start the download
      File downloadToFile = File(savePath);
      Fluttertoast.showToast(msg: "Download started");

      await ref.writeToFile(downloadToFile);

      Fluttertoast.showToast(msg: 'File downloaded at $savePath');
      print('File downloaded to $savePath');
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  static Future<String> getLyricsOfSong(String artist, String title) async {
    final dio = Dio();
    try {
      var res = await dio.get("https://api.lyrics.ovh/v1/$artist/$title");
      return res.data["lyrics"];
    } catch (e) {
      return 'No lyrics found';
    }
  }
}
