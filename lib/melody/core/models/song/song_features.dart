import 'package:freezed_annotation/freezed_annotation.dart';

part 'song_features.freezed.dart';
part 'song_features.g.dart';

@freezed
class SongFeatures with _$SongFeatures {
  const factory SongFeatures({
    required String songId,
    @Default("") String genre,
    @Default(0.0) double acousticness,
    @Default(0.0) double danceability,
    @Default(0.0) double energy,
    @Default(0.0) double instrumentalness,
    @Default(0.0) double liveness,
    @Default(0.0) double loudness,
    @Default(0.0) double speechiness,
    @Default(0.0) double tempo,
    @Default(0.0) double valence,
  }) = _SongFeatures;

  factory SongFeatures.fromJson(Map<String, dynamic> json) =>
      _$SongFeaturesFromJson(json);
}
