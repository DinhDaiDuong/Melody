import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:melody/melody/core/helper/firebase_helper.dart';
import 'package:melody/melody/core/models/artist/artist.dart';
import 'package:melody/melody/core/models/firebase/artist_request.dart';
import 'package:melody/melody/core/models/song/song.dart';
import 'package:melody/melody/core/models/song/musical_features.dart';
import 'package:melody/melody/presentations/widgets/custom_button.dart';
import 'package:melody/melody/presentations/widgets/custom_textfield.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'package:melody/melody/core/services/recommendation_service.dart';

class UploadSongPage extends StatefulWidget {
  const UploadSongPage({super.key});

  @override
  State<UploadSongPage> createState() => _UploadSongPageState();
}

class _UploadSongPageState extends State<UploadSongPage> {
  final artistController = TextEditingController();
  final songNameController = TextEditingController();
  FirebaseAuth mAuth = FirebaseAuth.instance;
  File? choosedImage;
  File? choosedSong;
  String? artworkDownloadUrl;
  String? songDownloadUrl;
  final Map<String, dynamic> arguments = Get.arguments ?? {};
  late String authorName;
  late String authorId;

  Future selectImage() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: [
      'jpg',
      'png',
      'jpeg',
      'webp',
    ]);
    if (result == null) return;

    setState(() {
      choosedImage = File(result.files.single.path!);
    });
  }

  Future selectSong() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['mp3', 'wav', 'acc']);
    if (result == null) return;

    setState(() {
      choosedSong = File(result.files.single.path!);
    });
  }

  @override
  void initState() {
    super.initState();
    authorName = arguments['authorName'] ?? '';
    authorId = arguments['authorId'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          }, // add navigation to the previous page
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('U P L O A D'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 8,
              ),
              Text(
                "Artist",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              CustomTextfield(
                maxLines: 1,
                controller: artistController,
                readOnly: true,
                hintText: authorName,
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                "Song name",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              CustomTextfield(
                maxLines: 1,
                controller: songNameController,
                readOnly: false,
                hintText: "Name your song",
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                "Song file",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              CustomButton(
                  onClick: selectSong,
                  bgColor: Color(0xff9C9C9C),
                  text: "Choose file",
                  textColor: Colors.white),
              SizedBox(
                height: 10,
              ),
              Text(
                "Choosing file: ${choosedSong == null ? "" : choosedSong!.path}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                "Song artwork",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                "Tap to change song artwork",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 13,
              ),
              GestureDetector(
                onTap: selectImage,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: choosedImage == null
                        ? Image.asset(
                            "assets/images/defaultartwork.jpg",
                            height: 209,
                            width: 209,
                          )
                        : Image.file(
                            File(choosedImage!.path),
                            width: 209,
                            height: 209,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 31,
              ),
              FutureBuilder<Artist>(
                future: ArtistRequest.getById(mAuth.currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CustomButton(
                      onClick: () {},
                      bgColor: Color(0xff262626),
                      text: "Upload song",
                      textColor: Colors.white,
                    );
                  } else if (snapshot.hasError) {
                    return CustomButton(
                      onClick: () {},
                      bgColor: Color(0xff262626),
                      text: "Error", // Placeholder text if there's an error
                      textColor: Colors.white,
                    );
                  } else {
                    return CustomButton(
                      onClick: () async {
                        try {
                          if (songNameController.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg: "Please enter a name for your song!");
                            return;
                          }
                          if (choosedSong == null) {
                            Fluttertoast.showToast(
                                msg:
                                    "Please choose a song you want to upload!");
                            return;
                          }

                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 20),
                                      Text(
                                          'Đang xử lý bài hát...\nVui lòng đợi trong giây lát'),
                                    ],
                                  ),
                                );
                              });
                          String songId =
                              FirebaseHelper.songCollection.doc().id;

                          final songFile = path.basename(choosedSong!.path);
                          final songExtension =
                              path.extension(choosedSong!.path);
                          final uploadedSongFileName =
                              songFile.endsWith(songExtension)
                                  ? songFile
                                  : '$songFile$songExtension';
                          final songRef = FirebaseStorage.instance
                              .ref()
                              .child("song_files/$uploadedSongFileName");

                          final user = mAuth.currentUser;
                          if (user != null) {
                            try {
                              UploadTask songUploadTask = songRef.putFile(
                                choosedSong!,
                                SettableMetadata(
                                  contentType:
                                      'audio/mpeg', // Changed to 'audio/mpeg' for mp3 files
                                ),
                              );
                              // await Future.wait([songUploadTask]);
                              // songDownloadUrl = await songRef.getDownloadURL();
                              await songUploadTask;
                              songDownloadUrl = await songRef.getDownloadURL();
                              if (choosedImage != null) {
                                final artworkFile =
                                    path.basename(choosedImage!.path);
                                final artworkRef = FirebaseStorage.instance
                                    .ref()
                                    .child("song_artworks/$artworkFile");
                                UploadTask artworkUploadTask =
                                    artworkRef.putFile(
                                        choosedImage!,
                                        SettableMetadata(
                                          contentType: 'image/jpeg',
                                        ));
                                await Future.wait([artworkUploadTask]);
                                artworkDownloadUrl =
                                    await artworkRef.getDownloadURL();
                              }
                              // Get musical features from CSV
                              final features = await RecommendationService
                                  .getFeaturesFromCSV(
                                songNameController.text.trim(),
                                authorName
                                    .trim(), // Use authorName instead of artistController
                              );

                              // If not found in CSV, try Spotify
                              final musicalFeatures = features ??
                                  await RecommendationService
                                      .getFeaturesFromCSV(
                                    songNameController.text.trim(),
                                    authorName.trim(),
                                  ) ??
                                  MusicalFeatures(
                                    acousticness: 0.5,
                                    danceability: 0.7,
                                    energy: 0.8,
                                    instrumentalness: 0.2,
                                    liveness: 0.3,
                                    loudness: -6.0,
                                    speechiness: 0.1,
                                    tempo: 120.0,
                                    valence: 0.6,
                                    key: 0,
                                    mode: 0,
                                    durationMs: 180000,
                                    timeSignature: 4,
                                  );

                              // Convert MusicalFeatures to Map
                              final featuresMap = {
                                'acousticness': musicalFeatures.acousticness,
                                'danceability': musicalFeatures.danceability,
                                'energy': musicalFeatures.energy,
                                'instrumentalness':
                                    musicalFeatures.instrumentalness,
                                'liveness': musicalFeatures.liveness,
                                'loudness': musicalFeatures.loudness,
                                'speechiness': musicalFeatures.speechiness,
                                'tempo': musicalFeatures.tempo,
                                'valence': musicalFeatures.valence,
                                'key': musicalFeatures.key,
                                'mode': musicalFeatures.mode,
                                'durationMs': musicalFeatures.durationMs,
                                'timeSignature': musicalFeatures.timeSignature,
                              };

                              final song = Song(
                                songId: songId,
                                songName: songNameController.text.trim(),
                                artistId: authorId,
                                artistName: authorName.trim(),
                                songImagePath: artworkDownloadUrl != null
                                    ? artworkDownloadUrl.toString()
                                    : "https://firebasestorage.googleapis.com/v0/b/melody-bf3aa.appspot.com/o/song_artworks%2Fdefaultartwork.jpg?alt=media&token=4146ab52-7d77-428f-bb5f-2741e662d20c",
                                audioPath: songDownloadUrl.toString(),
                                genre: "pop",
                                features: musicalFeatures,
                                times: [],
                                commentsIds: [],
                              );

                              // Convert to JSON before saving to Firestore
                              final songData = song.toJson();
                              // Replace the features object with the Map
                              songData['features'] = featuresMap;

                              await FirebaseHelper.songCollection
                                  .doc(songId)
                                  .set(songData)
                                  .whenComplete(() {
                                // Close loading dialog
                                Navigator.of(context).pop();
                                // Close upload page
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Upload bài hát thành công!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              });
                            } catch (e) {
                              // Close loading dialog if it's showing
                              if (Navigator.canPop(context)) {
                                Navigator.of(context).pop();
                              }
                              print('Error uploading song: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Lỗi khi upload bài hát: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            print("User's not signed in");
                          }
                        } catch (e) {
                          print(e);
                        }
                      },
                      bgColor: Color(0xff262626),
                      text: "Upload song",
                      textColor: Colors.white,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
