import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './Pages/music_home_page.dart';
import 'package:provider/provider.dart';
import './state/player_state.dart';

void main() {
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //showPerformanceOverlay: true,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        accentColor: Color(0xff348ac7),
        primaryColor: Color(0xff348ac7),
      ),
      title: 'Mount Music Player',
      home: ChangeNotifierProvider(
        builder: (context) => AudioData(),
        child: MusicHomePage()
      )
    );
  }
  
}



