import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melody/melody/core/models/song/musical_features.dart';

part 'song.freezed.dart';
part 'song.g.dart';

@freezed
class Song with _$Song {
  const factory Song({
    required String songId,
    required String songName,
    required String artistId,
    required String artistName,
    required String songImagePath,
    required String audioPath,
    @Default('') String spotifyId,
    required String genre,
    required MusicalFeatures features,
    @Default([]) List<DateTime> times,
    @Default([]) List<String> commentsIds,
  }) = _Song;

  factory Song.fromJson(Map<String, dynamic> json) {
    // Handle NaN values in spotifyId
    String spotifyId = '';
    if (json['spotifyId'] != null &&
        json['spotifyId'] != 'NaN' &&
        json['spotifyId'] != 'nan') {
      spotifyId = json['spotifyId'].toString();
    }

    // Get features from the features object
    final featuresData = json['features'] as Map<String, dynamic>? ?? {};
    print('Features data in fromJson:');
    print(featuresData);

    return Song(
      songId: json['songId'] as String? ?? '',
      songName: json['songName'] as String? ?? '',
      artistId: json['artistId'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
      songImagePath: json['songImagePath'] as String? ?? '',
      audioPath: json['audioPath'] as String? ?? '',
      spotifyId: spotifyId,
      genre: json['genre'] as String? ?? '',
      features: MusicalFeatures(
        acousticness: (featuresData['acousticness'] as num?)?.toDouble() ?? 0.0,
        danceability: (featuresData['danceability'] as num?)?.toDouble() ?? 0.0,
        energy: (featuresData['energy'] as num?)?.toDouble() ?? 0.0,
        instrumentalness:
            (featuresData['instrumentalness'] as num?)?.toDouble() ?? 0.0,
        liveness: (featuresData['liveness'] as num?)?.toDouble() ?? 0.0,
        loudness: (featuresData['loudness'] as num?)?.toDouble() ?? 0.0,
        speechiness: (featuresData['speechiness'] as num?)?.toDouble() ?? 0.0,
        tempo: (featuresData['tempo'] as num?)?.toDouble() ?? 0.0,
        valence: (featuresData['valence'] as num?)?.toDouble() ?? 0.0,
        key: (featuresData['key'] as num?)?.toInt() ?? 0,
        mode: (featuresData['mode'] as num?)?.toInt() ?? 0,
        durationMs: (featuresData['duration_ms'] as num?)?.toInt() ?? 0,
        timeSignature: (featuresData['time_signature'] as num?)?.toInt() ?? 0,
      ),
      times: (json['times'] as List<dynamic>?)?.map((timestamp) {
            if (timestamp is Timestamp) {
              return timestamp.toDate();
            }
            return DateTime.now();
          }).toList() ??
          [],
      commentsIds: (json['commentsIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  factory Song.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    print('Raw Firebase data:');
    print(data);
    print('Features from Firebase:');
    print(data['features']);
    return Song.fromJson(data);
  }
}
