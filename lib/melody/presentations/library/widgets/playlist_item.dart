import 'package:flutter/material.dart';
import 'package:melody/melody/core/helper/image_helper.dart';
import 'package:melody/melody/core/models/playlist/playlist.dart';

class PlaylistItem extends StatelessWidget {
  final Playlist playlist;
  const PlaylistItem({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    print(playlist.image);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        ImageHelper.loadFromNetwork(
          playlist.image,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            playlist.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        )
      ],
    );
  }
}
