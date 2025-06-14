import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:melody/melody/presentations/screens/music_recognition/musicRecognitionResult.dart';

class MusicRecognition extends StatefulWidget {
  const MusicRecognition({super.key});
  static const String routeName = 'music_recognition_screen';
  @override
  State<MusicRecognition> createState() => _MusicRecognitionState();
}

class _MusicRecognitionState extends State<MusicRecognition> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      String? path = result.files.single.path;
      if (path != null) {
        if (!mounted) return;
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MusicRecognitionResultScreen(path: path)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Nhận diện bài hát',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon nhận diện
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.music_note,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),

            // Tiêu đề
            Text(
              'Nhận diện bài hát',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Mô tả
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Tải lên file âm thanh để nhận diện bài hát. Hỗ trợ các định dạng: MP3, WAV, M4A',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
            const SizedBox(height: 48),

            // Nút tải lên
            ElevatedButton.icon(
              onPressed: pickAndUploadFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Chọn file âm thanh'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lưu ý
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Kích thước file tối đa: 10MB',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
