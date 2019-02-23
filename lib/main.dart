import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'pages/Feed.dart';
import 'pages/Alerts.dart';
import 'pages/login.dart';
import 'pages/Directory.dart';
import 'pages/Social.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // showPerformanceOverlay: true,
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
  final FirebaseMessaging _messaging = FirebaseMessaging();

  update(String token) {
    DatabaseReference databaseReference = new FirebaseDatabase().reference();
    databaseReference.child('fcm-token/$token').set({"token": token});
  }

  PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = new PageController();
    _messaging.getToken().then((token) {
      print(token);
      update(token);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void navigationTapped(int page) {
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: onPageChanged,
          scrollDirection: Axis.horizontal,
          children: <Widget>[new Container(), new Container(), new Container(), new SocialBody(), new Container()],
          // children: <Widget>[new Feed(), new DirectoryHomePage(), new Login(), new SocialBody(), new AlertsHomePage()],
        ),
        bottomNavigationBar: new BottomNavigationBar(
          currentIndex: _page,
          onTap: navigationTapped,
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.black,),
              title: Text('Home', style: TextStyle(color: Colors.black),),
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.import_contacts, color: Colors.black,),
              title: Text('Directory', style: TextStyle(color: Colors.black),)
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.account_circle, color: Colors.black,),
              title: Text('SLCM', style: TextStyle(color: Colors.black),),
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.public, color: Colors.black,),
              title: Text('Social', style: TextStyle(color: Colors.black),),
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.notifications, color: Colors.black,),
              title: Text('Alerts', style: TextStyle(color: Colors.black),),
            )
          ],
        ),
      ),
    );
  }
}
