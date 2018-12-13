import 'package:flutter/material.dart';
import 'pages/post_webview.dart';
import 'pages/login.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MTTN App',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
    }
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [new Feed(), new Login()];

  void onTabTapped(int index) {
    setState(() {
     _currentIndex = index;
     });
   }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: _tabs[_currentIndex],
        bottomNavigationBar: new BottomNavigationBar(
          fixedColor: Color.fromRGBO(0, 0, 0, 0.75),
          currentIndex: _currentIndex,
          onTap: onTabTapped,
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              title: Text('SLCM'),
            ),
          ],
        ),
      );
    }
}
