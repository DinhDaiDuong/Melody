import 'package:flutter/material.dart';
import 'package:melody/melody/presentations/screens/Home/home_screen.dart';
import 'package:melody/melody/presentations/screens/account/login_screen.dart';
import 'package:melody/melody/presentations/screens/account/sign_up_screen.dart';
import 'package:melody/melody/presentations/screens/album/modify_album.dart';
import 'package:melody/melody/presentations/screens/music_recognition/music_recognition_screen.dart';
import 'package:melody/melody/presentations/screens/playing/playing.dart';
import 'package:melody/melody/presentations/screens/splash/splash_screen.dart';
import 'package:melody/melody/presentations/screens/statistic/statistic_screen.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (context) => LoginScreen(),
  SplashScreen.routeName: (context) => SplashScreen(),
  HomeScreen.routeName: (context) => HomeScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  SignUpScreen.routeName: (context) => SignUpScreen(),
  ModifyAlbum.routeName: (context) => ModifyAlbum(),
  Playing.routeName: (context) => Playing(),
  StatisticScreen.routeName: (context) => StatisticScreen(),
  MusicRecognition.routeName: (context) => MusicRecognition(),
};

class Routes {
  static String allAlbum = '/allAlbum';
  static String allEvent = '/allEvent';
  static String createInstrument = '/createInstrument';
  static String discovery = '/discovery';
  static String uploadSong = '/uploadSong';
  static String artistPage = '/artistPage';
  static String editArtist = '/editArtist';
  static String playing = '/playing';
  static String queue = '/queue';
  static String editSong = '/editSong';
  static String uploadComposer = '/uploadComposer';
  static String composerPage = '/composerPage';
  static String editComposer = '/editComposer';
  static String statistic = '/statistic';
}
