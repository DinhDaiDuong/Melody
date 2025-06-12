// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_features.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SongFeaturesImpl _$$SongFeaturesImplFromJson(Map<String, dynamic> json) =>
    _$SongFeaturesImpl(
      songId: json['songId'] as String,
      genre: json['genre'] as String? ?? "",
      acousticness: (json['acousticness'] as num?)?.toDouble() ?? 0.0,
      danceability: (json['danceability'] as num?)?.toDouble() ?? 0.0,
      energy: (json['energy'] as num?)?.toDouble() ?? 0.0,
      instrumentalness: (json['instrumentalness'] as num?)?.toDouble() ?? 0.0,
      liveness: (json['liveness'] as num?)?.toDouble() ?? 0.0,
      loudness: (json['loudness'] as num?)?.toDouble() ?? 0.0,
      speechiness: (json['speechiness'] as num?)?.toDouble() ?? 0.0,
      tempo: (json['tempo'] as num?)?.toDouble() ?? 0.0,
      valence: (json['valence'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$SongFeaturesImplToJson(_$SongFeaturesImpl instance) =>
    <String, dynamic>{
      'songId': instance.songId,
      'genre': instance.genre,
      'acousticness': instance.acousticness,
      'danceability': instance.danceability,
      'energy': instance.energy,
      'instrumentalness': instance.instrumentalness,
      'liveness': instance.liveness,
      'loudness': instance.loudness,
      'speechiness': instance.speechiness,
      'tempo': instance.tempo,
      'valence': instance.valence,
    };
