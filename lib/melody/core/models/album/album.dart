import 'package:freezed_annotation/freezed_annotation.dart';
part 'album.g.dart';
part 'album.freezed.dart';

@Freezed()
class Album with _$Album {
  const factory Album({
    @Default("") String name,
     @Default("") String id,
     @Default("") String artist_id,
     @Default("") String description,
     @Default("") String image,
     @Default([]) List<String> songIds,
  }) = _Album;
  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
}
