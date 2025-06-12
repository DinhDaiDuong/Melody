// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Song _$SongFromJson(Map<String, dynamic> json) {
  return _Song.fromJson(json);
}

/// @nodoc
mixin _$Song {
  String get songId => throw _privateConstructorUsedError;
  String get songName => throw _privateConstructorUsedError;
  String get artistId => throw _privateConstructorUsedError;
  String get artistName => throw _privateConstructorUsedError;
  String get songImagePath => throw _privateConstructorUsedError;
  String get audioPath => throw _privateConstructorUsedError;
  String get spotifyId => throw _privateConstructorUsedError;
  String get genre => throw _privateConstructorUsedError;
  MusicalFeatures get features => throw _privateConstructorUsedError;
  List<DateTime> get times => throw _privateConstructorUsedError;
  List<String> get commentsIds => throw _privateConstructorUsedError;

  /// Serializes this Song to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SongCopyWith<Song> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SongCopyWith<$Res> {
  factory $SongCopyWith(Song value, $Res Function(Song) then) =
      _$SongCopyWithImpl<$Res, Song>;
  @useResult
  $Res call(
      {String songId,
      String songName,
      String artistId,
      String artistName,
      String songImagePath,
      String audioPath,
      String spotifyId,
      String genre,
      MusicalFeatures features,
      List<DateTime> times,
      List<String> commentsIds});

  $MusicalFeaturesCopyWith<$Res> get features;
}

/// @nodoc
class _$SongCopyWithImpl<$Res, $Val extends Song>
    implements $SongCopyWith<$Res> {
  _$SongCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? songId = null,
    Object? songName = null,
    Object? artistId = null,
    Object? artistName = null,
    Object? songImagePath = null,
    Object? audioPath = null,
    Object? spotifyId = null,
    Object? genre = null,
    Object? features = null,
    Object? times = null,
    Object? commentsIds = null,
  }) {
    return _then(_value.copyWith(
      songId: null == songId
          ? _value.songId
          : songId // ignore: cast_nullable_to_non_nullable
              as String,
      songName: null == songName
          ? _value.songName
          : songName // ignore: cast_nullable_to_non_nullable
              as String,
      artistId: null == artistId
          ? _value.artistId
          : artistId // ignore: cast_nullable_to_non_nullable
              as String,
      artistName: null == artistName
          ? _value.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      songImagePath: null == songImagePath
          ? _value.songImagePath
          : songImagePath // ignore: cast_nullable_to_non_nullable
              as String,
      audioPath: null == audioPath
          ? _value.audioPath
          : audioPath // ignore: cast_nullable_to_non_nullable
              as String,
      spotifyId: null == spotifyId
          ? _value.spotifyId
          : spotifyId // ignore: cast_nullable_to_non_nullable
              as String,
      genre: null == genre
          ? _value.genre
          : genre // ignore: cast_nullable_to_non_nullable
              as String,
      features: null == features
          ? _value.features
          : features // ignore: cast_nullable_to_non_nullable
              as MusicalFeatures,
      times: null == times
          ? _value.times
          : times // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
      commentsIds: null == commentsIds
          ? _value.commentsIds
          : commentsIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MusicalFeaturesCopyWith<$Res> get features {
    return $MusicalFeaturesCopyWith<$Res>(_value.features, (value) {
      return _then(_value.copyWith(features: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SongImplCopyWith<$Res> implements $SongCopyWith<$Res> {
  factory _$$SongImplCopyWith(
          _$SongImpl value, $Res Function(_$SongImpl) then) =
      __$$SongImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String songId,
      String songName,
      String artistId,
      String artistName,
      String songImagePath,
      String audioPath,
      String spotifyId,
      String genre,
      MusicalFeatures features,
      List<DateTime> times,
      List<String> commentsIds});

  @override
  $MusicalFeaturesCopyWith<$Res> get features;
}

/// @nodoc
class __$$SongImplCopyWithImpl<$Res>
    extends _$SongCopyWithImpl<$Res, _$SongImpl>
    implements _$$SongImplCopyWith<$Res> {
  __$$SongImplCopyWithImpl(_$SongImpl _value, $Res Function(_$SongImpl) _then)
      : super(_value, _then);

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? songId = null,
    Object? songName = null,
    Object? artistId = null,
    Object? artistName = null,
    Object? songImagePath = null,
    Object? audioPath = null,
    Object? spotifyId = null,
    Object? genre = null,
    Object? features = null,
    Object? times = null,
    Object? commentsIds = null,
  }) {
    return _then(_$SongImpl(
      songId: null == songId
          ? _value.songId
          : songId // ignore: cast_nullable_to_non_nullable
              as String,
      songName: null == songName
          ? _value.songName
          : songName // ignore: cast_nullable_to_non_nullable
              as String,
      artistId: null == artistId
          ? _value.artistId
          : artistId // ignore: cast_nullable_to_non_nullable
              as String,
      artistName: null == artistName
          ? _value.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      songImagePath: null == songImagePath
          ? _value.songImagePath
          : songImagePath // ignore: cast_nullable_to_non_nullable
              as String,
      audioPath: null == audioPath
          ? _value.audioPath
          : audioPath // ignore: cast_nullable_to_non_nullable
              as String,
      spotifyId: null == spotifyId
          ? _value.spotifyId
          : spotifyId // ignore: cast_nullable_to_non_nullable
              as String,
      genre: null == genre
          ? _value.genre
          : genre // ignore: cast_nullable_to_non_nullable
              as String,
      features: null == features
          ? _value.features
          : features // ignore: cast_nullable_to_non_nullable
              as MusicalFeatures,
      times: null == times
          ? _value._times
          : times // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
      commentsIds: null == commentsIds
          ? _value._commentsIds
          : commentsIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SongImpl implements _Song {
  const _$SongImpl(
      {required this.songId,
      required this.songName,
      required this.artistId,
      required this.artistName,
      required this.songImagePath,
      required this.audioPath,
      this.spotifyId = '',
      required this.genre,
      required this.features,
      final List<DateTime> times = const [],
      final List<String> commentsIds = const []})
      : _times = times,
        _commentsIds = commentsIds;

  factory _$SongImpl.fromJson(Map<String, dynamic> json) =>
      _$$SongImplFromJson(json);

  @override
  final String songId;
  @override
  final String songName;
  @override
  final String artistId;
  @override
  final String artistName;
  @override
  final String songImagePath;
  @override
  final String audioPath;
  @override
  @JsonKey()
  final String spotifyId;
  @override
  final String genre;
  @override
  final MusicalFeatures features;
  final List<DateTime> _times;
  @override
  @JsonKey()
  List<DateTime> get times {
    if (_times is EqualUnmodifiableListView) return _times;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_times);
  }

  final List<String> _commentsIds;
  @override
  @JsonKey()
  List<String> get commentsIds {
    if (_commentsIds is EqualUnmodifiableListView) return _commentsIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_commentsIds);
  }

  @override
  String toString() {
    return 'Song(songId: $songId, songName: $songName, artistId: $artistId, artistName: $artistName, songImagePath: $songImagePath, audioPath: $audioPath, spotifyId: $spotifyId, genre: $genre, features: $features, times: $times, commentsIds: $commentsIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SongImpl &&
            (identical(other.songId, songId) || other.songId == songId) &&
            (identical(other.songName, songName) ||
                other.songName == songName) &&
            (identical(other.artistId, artistId) ||
                other.artistId == artistId) &&
            (identical(other.artistName, artistName) ||
                other.artistName == artistName) &&
            (identical(other.songImagePath, songImagePath) ||
                other.songImagePath == songImagePath) &&
            (identical(other.audioPath, audioPath) ||
                other.audioPath == audioPath) &&
            (identical(other.spotifyId, spotifyId) ||
                other.spotifyId == spotifyId) &&
            (identical(other.genre, genre) || other.genre == genre) &&
            (identical(other.features, features) ||
                other.features == features) &&
            const DeepCollectionEquality().equals(other._times, _times) &&
            const DeepCollectionEquality()
                .equals(other._commentsIds, _commentsIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      songId,
      songName,
      artistId,
      artistName,
      songImagePath,
      audioPath,
      spotifyId,
      genre,
      features,
      const DeepCollectionEquality().hash(_times),
      const DeepCollectionEquality().hash(_commentsIds));

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SongImplCopyWith<_$SongImpl> get copyWith =>
      __$$SongImplCopyWithImpl<_$SongImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SongImplToJson(
      this,
    );
  }
}

abstract class _Song implements Song {
  const factory _Song(
      {required final String songId,
      required final String songName,
      required final String artistId,
      required final String artistName,
      required final String songImagePath,
      required final String audioPath,
      final String spotifyId,
      required final String genre,
      required final MusicalFeatures features,
      final List<DateTime> times,
      final List<String> commentsIds}) = _$SongImpl;

  factory _Song.fromJson(Map<String, dynamic> json) = _$SongImpl.fromJson;

  @override
  String get songId;
  @override
  String get songName;
  @override
  String get artistId;
  @override
  String get artistName;
  @override
  String get songImagePath;
  @override
  String get audioPath;
  @override
  String get spotifyId;
  @override
  String get genre;
  @override
  MusicalFeatures get features;
  @override
  List<DateTime> get times;
  @override
  List<String> get commentsIds;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SongImplCopyWith<_$SongImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
