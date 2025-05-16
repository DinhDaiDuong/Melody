import 'package:freezed_annotation/freezed_annotation.dart';
part 'similar_song.freezed.dart';
part 'similar_song.g.dart';

@freezed
class SimilarSong with _$SimilarSong {
  const factory SimilarSong({
    required String songId,
    required String songName,
    required String artistName,
    required String songImagePath,
    required double similarityScore,
    required List<String> genres,
    required String audioPath,
    @Default([]) List<String> tags,
  }) = _SimilarSong;

  factory SimilarSong.fromJson(Map<String, dynamic> json) =>
      _$SimilarSongFromJson(json);
}
