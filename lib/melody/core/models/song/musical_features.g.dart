// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'musical_features.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MusicalFeaturesImpl _$$MusicalFeaturesImplFromJson(
        Map<String, dynamic> json) =>
    _$MusicalFeaturesImpl(
      danceability: (json['danceability'] as num?)?.toDouble() ?? 0.0,
      energy: (json['energy'] as num?)?.toDouble() ?? 0.0,
      key: (json['key'] as num?)?.toInt() ?? 0,
      loudness: (json['loudness'] as num?)?.toDouble() ?? 0.0,
      mode: (json['mode'] as num?)?.toInt() ?? 0,
      speechiness: (json['speechiness'] as num?)?.toDouble() ?? 0.0,
      acousticness: (json['acousticness'] as num?)?.toDouble() ?? 0.0,
      instrumentalness: (json['instrumentalness'] as num?)?.toDouble() ?? 0.0,
      liveness: (json['liveness'] as num?)?.toDouble() ?? 0.0,
      valence: (json['valence'] as num?)?.toDouble() ?? 0.0,
      tempo: (json['tempo'] as num?)?.toDouble() ?? 0.0,
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      timeSignature: (json['timeSignature'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MusicalFeaturesImplToJson(
        _$MusicalFeaturesImpl instance) =>
    <String, dynamic>{
      'danceability': instance.danceability,
      'energy': instance.energy,
      'key': instance.key,
      'loudness': instance.loudness,
      'mode': instance.mode,
      'speechiness': instance.speechiness,
      'acousticness': instance.acousticness,
      'instrumentalness': instance.instrumentalness,
      'liveness': instance.liveness,
      'valence': instance.valence,
      'tempo': instance.tempo,
      'durationMs': instance.durationMs,
      'timeSignature': instance.timeSignature,
    };
