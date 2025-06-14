import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:melody/melody/core/helper/assets_helper.dart';
import 'package:melody/melody/core/helper/firebase_helper.dart';
import 'package:melody/melody/core/models/firebase/song_request.dart';
import 'package:melody/melody/core/models/playlist/playlist.dart';
import 'package:melody/melody/core/models/song/song.dart';
import 'package:melody/melody/core/models/user/user.dart';

class PlaylistRequest {
  static Stream<List<Playlist>> getAll(String userId) =>
      FirebaseFirestore.instance
          .collection('Playlists')
          .where("userId", isEqualTo: userId)
          .snapshots()
          .map((event) =>
              event.docs.map((e) => Playlist.fromJson(e.data())).toList());

  static Future<Playlist> getById(String id) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('Playlists').doc(id).get();
    Playlist playlist = Playlist.fromJson(doc.data()!);
    return Future.value(playlist);
  }

  static Future<void> addSongToPlaylist(
      String playlistId, String songId) async {
    Playlist playlist = await getById(playlistId);
    List<String> songs = List.from(playlist.songIds);
    songs.add(songId);

    await FirebaseHelper.playlistCollection
        .doc(playlistId)
        .update({"songIds": songs});
  }

  static Future<List<Song>> getSongOfPlaylist(String playlistId) async {
    Playlist playlist = await getById(playlistId);
    List<Song> allSongs = await SongRequest.getAllSongs().first;
    return allSongs.where((e) => playlist.songIds.contains(e.songId)).toList();
  }

  static Future<void> removeSongFromPlaylist(
      String playlistId, String songId) async {
    Playlist playlist = await getById(playlistId);
    List<String> songs = List.from(playlist.songIds);
    songs.remove(songId);
    await FirebaseHelper.playlistCollection
        .doc(playlistId)
        .update({"songIds": songs});
  }

  static Future<List<String>> initPlaylist(String userId) async {
    String id = FirebaseHelper.playlistCollection.doc().id;
    Playlist playlist = Playlist(
        id: id,
        name: "Favorite Songs",
        image: AssetHelper.favoriteSongImg,
        type: "favorite",
        userId: userId);
    await FirebaseHelper.playlistCollection.doc(id).set(playlist.toJson());
    Playlist playlistDoc = await getById(id);
    List<String> list = [];
    list.add(playlistDoc.id);
    return list;
  }

  static Future<List<Song>> getFavoriteSongs() async {
    try {
      Playlist? playlist = await getFavoritePlaylist();
      if (playlist == null) return [];

      List<Song> allSongs = await SongRequest.getAllSongs().first;
      return allSongs
          .where((e) => playlist.songIds.contains(e.songId))
          .toList();
    } catch (e) {
      print('Error getting favorite songs: $e');
      return [];
    }
  }

  static Future<Playlist?> getFavoritePlaylist() async {
    try {
      DocumentSnapshot userDoc = await FirebaseHelper.userCollection
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      UserModel user =
          UserModel.fromJson(userDoc.data() as Map<String, dynamic>);

      for (String playlistId in user.playlistIds) {
        if (playlistId.isEmpty) continue; // Skip empty playlist IDs
        Playlist playlist = await getById(playlistId);
        if (playlist.type == 'favorite') {
          return playlist;
        }
      }
      return null;
    } catch (e) {
      print('Error getting favorite playlist: $e');
      return null;
    }
  }

  static Future<void> addSongToFavorite(String songId) async {
    Playlist? playlist = await getFavoritePlaylist();
    List<String> songs = List.from(playlist!.songIds);
    songs.add(songId);

    await FirebaseHelper.playlistCollection
        .doc(playlist.id)
        .update({"songIds": songs});
  }

  static Future<void> removeSongFromFavorite(String songId) async {
    Playlist? playlist = await getFavoritePlaylist();
    List<String> songs = List.from(playlist!.songIds);
    songs.remove(songId);
    await FirebaseHelper.playlistCollection
        .doc(playlist.id)
        .update({"songIds": songs});
  }

  static Future<void> deletePlaylist(String playlistId) async {
    await FirebaseHelper.playlistCollection.doc(playlistId).delete();
  }
}
