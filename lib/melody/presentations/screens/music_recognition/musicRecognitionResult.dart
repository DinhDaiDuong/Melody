import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melody/melody/core/models/musicRecognitionResponse/music_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:melody/melody/presentations/screens/artist/widgets/song_item.dart';
import 'package:melody/melody/presentations/screens/playing/playing.dart';
import 'package:melody/melody/presentations/screens/playing/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';

import '../../../core/models/firebase/song_request.dart';
import '../../../core/models/song/song.dart';

class MusicRecognitionResultScreen extends StatefulWidget {
  MusicRecognitionResultScreen({super.key, required this.path});
  String path;
  @override
  State<MusicRecognitionResultScreen> createState() =>
      _MusicRecognitionResultScreenState();
}

class _MusicRecognitionResultScreenState
    extends State<MusicRecognitionResultScreen> {
  MusicRecognitionResponse? musicRecognitionResponse;
  String error = '';
  Song? songResult;
  late PlaylistProvider playlistProvider;
  bool isLoading = true;
  List<Map<String, dynamic>> localSongs = [];

  @override
  void initState() {
    super.initState();
    String path = widget.path;
    uploadAudioAndCallAuddAPI(path);
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
  }

  Future<void> uploadAudioAndCallAuddAPI(String filePath) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      // Kiểm tra file tồn tại
      final file = File(filePath);
      if (!await file.exists()) {
        setState(() {
          error = 'Không tìm thấy file âm thanh';
          isLoading = false;
        });
        return;
      }

      // Kiểm tra kích thước file
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB
        setState(() {
          error = 'File âm thanh quá lớn (tối đa 10MB)';
          isLoading = false;
        });
        return;
      }

      const String apiUrl = 'https://api.audd.io/';
      var uri = Uri.parse(apiUrl);
      var request = http.MultipartRequest('POST', uri)
        ..fields['return'] = 'spotify'
        ..fields['api_token'] = 'ef15e604f9e931c1d962c9a1741cde44';

      var multipartFile = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(multipartFile);

      print('Đang gửi request đến Audd.io...');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        print('Response từ Audd.io: ${response.body}');
        try {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status'] == 'success') {
            setState(() {
              musicRecognitionResponse =
                  MusicRecognitionResponse.fromJson(jsonResponse);
              isLoading = false;
            });
          } else {
            String errorMessage = 'Không thể nhận diện bài hát';
            if (jsonResponse['error'] != null) {
              if (jsonResponse['error']['error_code'] == 900) {
                errorMessage =
                    'Lỗi xác thực API. Vui lòng liên hệ admin để cập nhật API token.';
              } else {
                errorMessage =
                    jsonResponse['error']['error_message'] ?? errorMessage;
              }
            }
            setState(() {
              error = errorMessage;
              isLoading = false;
            });
          }
        } catch (e) {
          print('Lỗi parse JSON: $e');
          setState(() {
            error = 'Lỗi xử lý dữ liệu từ server';
            isLoading = false;
          });
        }
      } else {
        print('Lỗi API: ${response.statusCode} - ${response.body}');
        setState(() {
          error = 'Lỗi kết nối đến server (${response.statusCode})';
          isLoading = false;
        });
      }
    } on SocketException {
      if (!mounted) return;
      setState(() {
        error = 'Không có kết nối mạng';
        isLoading = false;
      });
    } catch (e) {
      print('Lỗi không xác định: $e');
      if (!mounted) return;
      setState(() {
        error = 'Lỗi không xác định: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Kết quả nhận diện',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Đang nhận diện bài hát...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => uploadAudioAndCallAuddAPI(widget.path),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử lại'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (musicRecognitionResponse != null) ...[
                        StreamBuilder<List<Song>>(
                          stream: SongRequest.getAllSongs(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  "Lỗi: Không thể tải danh sách bài hát",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              );
                            } else {
                              if (snapshot.data != null) {
                                try {
                                  songResult =
                                      snapshot.data!.firstWhere((element) {
                                    if (musicRecognitionResponse!
                                            .result!.title !=
                                        null) {
                                      return element.songName.contains(
                                              musicRecognitionResponse!
                                                  .result!.title!) ||
                                          musicRecognitionResponse!
                                              .result!.title!
                                              .contains(element.songName);
                                    }
                                    return false;
                                  });
                                } catch (e) {
                                  print('Song not found');
                                }
                              }
                              return songResult != null
                                  ? Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: SongItem(
                                        song: songResult!,
                                        onTap: _onSongTap,
                                      ),
                                    )
                                  : Card(
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Thông tin bài hát',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                            const SizedBox(height: 16),
                                            _buildInfoRow(
                                                'Tên bài hát',
                                                musicRecognitionResponse!
                                                        .result?.title ??
                                                    "Không xác định"),
                                            _buildInfoRow(
                                                'Nghệ sĩ',
                                                musicRecognitionResponse!
                                                        .result?.artist ??
                                                    "Không xác định"),
                                            _buildInfoRow(
                                                'Album',
                                                musicRecognitionResponse!
                                                        .result?.album ??
                                                    "Không xác định"),
                                            _buildInfoRow(
                                                'Ngày phát hành',
                                                musicRecognitionResponse!
                                                        .result?.releaseDate ??
                                                    "Không xác định"),
                                            _buildInfoRow(
                                                'Nhãn đĩa',
                                                musicRecognitionResponse!
                                                        .result?.label ??
                                                    "Không xác định"),
                                          ],
                                        ),
                                      ),
                                    );
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _onSongTap() {
    if (songResult != null) {
      List<Song> copiedSongList = [songResult!];
      playlistProvider.playlist.clear();
      playlistProvider.setPlaylist(copiedSongList);
      playlistProvider.currentSongIndex = 0;
      Navigator.of(context).pushNamed(Playing.routeName);
    }
  }
}
