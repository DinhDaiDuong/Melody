import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song/similar_song.dart';
import '../models/musicRecognitionResponse/music_recognition.dart';

class SongRecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm để lấy các bài hát tương tự dựa trên kết quả nhận dạng
  Future<List<SimilarSong>> getSimilarSongs(
      MusicRecognitionResponse recognitionResult) async {
    try {
      // Lấy thông tin từ kết quả nhận dạng
      final artist = recognitionResult.result?.artist;
      final title = recognitionResult.result?.title;
      final genres = recognitionResult.result?.appleMusic?.genreNames ?? [];

      // Tạo query để tìm bài hát tương tự
      Query query = _firestore.collection('songs');

      // Thêm điều kiện tìm kiếm dựa trên nghệ sĩ
      if (artist != null && artist.isNotEmpty) {
        query = query.where('artistName', isEqualTo: artist);
      }

      // Thêm điều kiện tìm kiếm dựa trên thể loại
      if (genres.isNotEmpty) {
        query = query.where('genres', arrayContainsAny: genres);
      }

      // Thực hiện query
      final querySnapshot = await query.limit(10).get();

      // Chuyển đổi kết quả thành danh sách SimilarSong
      List<SimilarSong> similarSongs = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SimilarSong(
          songId: doc.id,
          songName: data['songName'] ?? '',
          artistName: data['artistName'] ?? '',
          songImagePath: data['songImagePath'] ?? '',
          similarityScore: _calculateSimilarityScore(data, recognitionResult),
          genres: List<String>.from(data['genres'] ?? []),
          audioPath: data['audioPath'] ?? '',
          tags: List<String>.from(data['tags'] ?? []),
        );
      }).toList();

      // Sắp xếp theo độ tương đồng
      similarSongs
          .sort((a, b) => b.similarityScore.compareTo(a.similarityScore));

      return similarSongs;
    } catch (e) {
      print('Error getting similar songs: $e');
      return [];
    }
  }

  // Hàm tính điểm tương đồng giữa bài hát
  double _calculateSimilarityScore(Map<String, dynamic> songData,
      MusicRecognitionResponse recognitionResult) {
    double score = 0.0;

    // So sánh nghệ sĩ
    if (recognitionResult.result?.artist == songData['artistName']) {
      score += 0.4;
    }

    // So sánh thể loại
    final recognitionGenres =
        recognitionResult.result?.appleMusic?.genreNames ?? [];
    final songGenres = List<String>.from(songData['genres'] ?? []);

    for (var genre in recognitionGenres) {
      if (songGenres.contains(genre)) {
        score += 0.2;
      }
    }

    // So sánh tags
    final recognitionTags = recognitionResult.result?.spotify?.album?.name
            ?.toLowerCase()
            .split(' ') ??
        [];
    final songTags = List<String>.from(songData['tags'] ?? []);

    for (var tag in recognitionTags) {
      if (songTags.contains(tag)) {
        score += 0.1;
      }
    }

    return score;
  }

  // Hàm để lưu thông tin bài hát vào Firestore
  Future<void> saveSongData(SimilarSong song) async {
    try {
      await _firestore.collection('songs').doc(song.songId).set({
        'songName': song.songName,
        'artistName': song.artistName,
        'songImagePath': song.songImagePath,
        'genres': song.genres,
        'audioPath': song.audioPath,
        'tags': song.tags,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving song data: $e');
    }
  }
}
