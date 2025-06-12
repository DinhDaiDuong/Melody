// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SongImpl _$$SongImplFromJson(Map<String, dynamic> json) => _$SongImpl(
      songId: json['songId'] as String,
      songName: json['songName'] as String,
      artistId: json['artistId'] as String,
      artistName: json['artistName'] as String,
      songImagePath: json['songImagePath'] as String,
      audioPath: json['audioPath'] as String,
      spotifyId: json['spotifyId'] as String? ?? '',
      genre: json['genre'] as String,
      features:
          MusicalFeatures.fromJson(json['features'] as Map<String, dynamic>),
      times: (json['times'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          const [],
      commentsIds: (json['commentsIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$SongImplToJson(_$SongImpl instance) =>
    <String, dynamic>{
      'songId': instance.songId,
      'songName': instance.songName,
      'artistId': instance.artistId,
      'artistName': instance.artistName,
      'songImagePath': instance.songImagePath,
      'audioPath': instance.audioPath,
      'spotifyId': instance.spotifyId,
      'genre': instance.genre,
      'features': instance.features,
      'times': instance.times.map((e) => e.toIso8601String()).toList(),
      'commentsIds': instance.commentsIds,
    };
