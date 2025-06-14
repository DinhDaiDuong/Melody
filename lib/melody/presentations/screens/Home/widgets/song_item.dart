import 'package:flutter/material.dart';
import 'package:melody/melody/core/helper/image_helper.dart';
import 'package:melody/melody/core/models/song/song.dart';

class SongItem extends StatelessWidget {
  final Song song;
  const SongItem({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ImageHelper.loadFromNetwork(song.songImagePath,
                    fit: BoxFit.cover)),
          ),
          SizedBox(
            height: 6,
          ),
          SizedBox(
            width: 100,
            child: Text(
              song.songName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              song.artistName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}
