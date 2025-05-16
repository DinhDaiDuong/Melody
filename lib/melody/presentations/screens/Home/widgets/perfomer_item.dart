import 'package:flutter/material.dart';

import '../../../../core/helper/image_helper.dart';
import '../../../../core/models/artist/artist.dart';

class PerfomerItem extends StatelessWidget {
  final Artist perfomer;
  const PerfomerItem.PerformerItem({super.key, required this.perfomer});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        // mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          ImageHelper.loadFromNetwork(perfomer.avatar,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              radius: BorderRadius.circular(50)),
          SizedBox(
            height: 20,
          ),
          Text(
            perfomer.artistName,
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
