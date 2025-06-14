import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:melody/melody/core/models/artist/artist.dart';
import 'package:melody/melody/core/models/firebase/playlist_request.dart';
import 'package:melody/melody/core/models/user/user.dart';
import 'package:melody/melody/presentations/screens/Home/navigation_home.dart';

import '../../presentations/widgets/dialog.dart';

class AuthServices {
  static UserModel? CurrentUser;
  static signUpUser(
      {required String name,
      required String email,
      required String password,
      required BuildContext buildContext}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;
      List<String> initPlaylists = await PlaylistRequest.initPlaylist(uid);
      print(initPlaylists);
      UserModel user = UserModel(
          Id: uid,
          Name: name,
          Email: email,
          position: 'User',
          playlistIds: initPlaylists);
      Artist userArtistInfo = Artist(
          artistId: uid,
          artistName: name,
          bio: "",
          avatar:
              "https://firebasestorage.googleapis.com/v0/b/melody-bf3aa.appspot.com/o/images%2Fdefault-avatar.jpg?alt=media&token=11836316-b00f-481c-932c-1c741cc681ef");

      DocumentReference artist =
          FirebaseFirestore.instance.collection("Artists").doc(uid);
      await artist.set(userArtistInfo.toJson());
      DocumentReference doc =
          FirebaseFirestore.instance.collection("Users").doc(uid);

      await doc.set(user.toJson()).whenComplete(() async {
        await UpdateCurrentUser();
        Navigator.of(buildContext).pop();
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(buildContext).showSnackBar(
            SnackBar(content: Text('Password Provided is too weak')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(buildContext).showSnackBar(
            SnackBar(content: Text('Email Provided already Exists')));
      } else {
        ScaffoldMessenger.of(buildContext)
            .showSnackBar(SnackBar(content: Text(e.message.toString())));
      }
    }
  }

  static signinUser(String email, String password, BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      await UpdateCurrentUser();
      if (FirebaseAuth.instance.currentUser != null) {
        await UpdateCurrentUser();
        await showDialog(
                context: context,
                builder: (context) {
                  return DialogOverlay(
                    isSuccess: true,
                    task: 'login',
                  );
                })
            .whenComplete(() => Navigator.of(context).pushNamedAndRemoveUntil(
                NavigationHome.routeName, (route) => false));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user Found with this Email')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Password did not match')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message.toString())));
      }
    }
  }

  static bool CurrentUserIsManager() {
    try {
      bool result = false;
      if (AuthServices.CurrentUser!.position == 'Manager') result = true;
      return result;
    } catch (e) {
      return false;
    }
  }

  static Future UpdateCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      AuthServices.CurrentUser = UserModel(
        Id: value['Id'],
        Name: value['Name'],
        Email: value['Email'],
        position: value['position'],
      );
    });
  }

  static siginWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount? googleUser;

      googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        var credentialWithGoogle =
            await FirebaseAuth.instance.signInWithCredential(credential);

        await FirebaseAuth.instance.signInWithCredential(credential);

        if (FirebaseAuth.instance.currentUser != null) {
          await FirebaseAuth.instance.currentUser?.reload();
          String uid = credentialWithGoogle.user?.uid ?? "";
          List<String> initPlaylists = await PlaylistRequest.initPlaylist(uid);
          print(initPlaylists);
          UserModel user = UserModel(
              Id: uid,
              Name: FirebaseAuth.instance.currentUser!.displayName ?? "",
              Email: FirebaseAuth.instance.currentUser!.email ?? "",
              position: 'User',
              playlistIds: initPlaylists);
          Artist userArtistInfo = Artist(
              artistId: uid,
              artistName: FirebaseAuth.instance.currentUser!.displayName ?? "",
              bio: "",
              avatar: FirebaseAuth.instance.currentUser!.photoURL ??
                  "https://firebasestorage.googleapis.com/v0/b/melody-bf3aa.appspot.com/o/images%2Fdefault-avatar.jpg?alt=media&token=11836316-b00f-481c-932c-1c741cc681ef");

          DocumentReference artist =
              FirebaseFirestore.instance.collection("Artists").doc(uid);
          await artist.set(userArtistInfo.toJson());
          DocumentReference doc =
              FirebaseFirestore.instance.collection("Users").doc(uid);

          await doc.set(user.toJson()).whenComplete(() async {
            Navigator.of(context).pushNamedAndRemoveUntil(
                NavigationHome.routeName, (route) => false);
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user Found with this Email')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Password did not match')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message.toString())));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
