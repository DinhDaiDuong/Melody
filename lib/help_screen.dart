import 'package:melody/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: '21522327@gm.uit.edu.vn',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Can you help me resolve some problems in my app?',
        'body': 'Hi,\nI am having trouble with the app. Can you help me?'
      }),
    );
    await launchUrl(emailLaunchUri);
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return Container(
      color: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          body: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 16,
                    right: 16),
                child: Image.asset('assets/images/helpImage.png'),
              ),
              Container(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'How can we help you?',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isLightMode ? Colors.black : Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'It looks like you are experiencing problems\nwith our sign up process. We are here to\nhelp so please get in touch with us',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: isLightMode ? Colors.black : Colors.white),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                      width: 140,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isLightMode ? Colors.blue : Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4.0)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.6),
                              offset: const Offset(4, 4),
                              blurRadius: 8.0),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _sendEmail();
                          },
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                'Chat with Us',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isLightMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}