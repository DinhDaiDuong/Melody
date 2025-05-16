import 'package:flutter/material.dart';
import '../../core/models/song/similar_song.dart';

class SimilarSongsList extends StatelessWidget {
  final List<SimilarSong> similarSongs;
  final Function(SimilarSong) onSongTap;

  const SimilarSongsList({
    Key? key,
    required this.similarSongs,
    required this.onSongTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: similarSongs.length,
      itemBuilder: (context, index) {
        final song = similarSongs[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              song.songImagePath,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey[300],
                  child: const Icon(Icons.music_note),
                );
              },
            ),
          ),
          title: Text(
            song.songName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(song.artistName),
          trailing: Text(
            '${(song.similarityScore * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => onSongTap(song),
        );
      },
    );
  }
}
