import 'package:freezed_annotation/freezed_annotation.dart';

part 'musical_features.freezed.dart';
part 'musical_features.g.dart';

@freezed
class MusicalFeatures with _$MusicalFeatures {
  const factory MusicalFeatures({
    @Default(0.0) double danceability,
    @Default(0.0) double energy,
    @Default(0) int key,
    @Default(0.0) double loudness,
    @Default(0) int mode,
    @Default(0.0) double speechiness,
    @Default(0.0) double acousticness,
    @Default(0.0) double instrumentalness,
    @Default(0.0) double liveness,
    @Default(0.0) double valence,
    @Default(0.0) double tempo,
    @Default(0) int durationMs,
    @Default(0) int timeSignature,
  }) = _MusicalFeatures;

  factory MusicalFeatures.fromJson(Map<String, dynamic> json) =>
      _$MusicalFeaturesFromJson(json);
}
