import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseHelper {
  static final CollectionReference songCollection =
      FirebaseFirestore.instance.collection('Songs');
  static final CollectionReference artistCollection =
      FirebaseFirestore.instance.collection('Artists');
  static final CollectionReference albumCollection =
      FirebaseFirestore.instance.collection('Albums');
  static final CollectionReference playlistCollection =
      FirebaseFirestore.instance.collection('Playlists');
  static final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('Users');
  static final CollectionReference commentCollection =
      FirebaseFirestore.instance.collection('Comment');
  static final CollectionReference eventCollection =
      FirebaseFirestore.instance.collection('Events');
  static final CollectionReference instrumentCollection =
      FirebaseFirestore.instance.collection('Instruments');
  static var composerCollection =
      FirebaseFirestore.instance.collection("Composers");
  static String userId = FirebaseAuth.instance.currentUser!.uid;
}
