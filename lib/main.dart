import 'package:flutter/material.dart';
import 'pages/post_webview.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
      return new MaterialApp(
        title: 'MTTN App',
        home: new Scaffold(
          backgroundColor: Color.fromRGBO(230, 230, 250, 1.0),
          body: Feed(),
          appBar: AppBar(
            title: Text('Feed', textAlign: TextAlign.center,),
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.75),
          ),         
        ),
        debugShowCheckedModeBanner: false,
      );
    }
}
