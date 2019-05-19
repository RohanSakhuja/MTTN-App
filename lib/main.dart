import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'pages/Feed.dart';
import 'pages/Alerts.dart';
import 'pages/login.dart';
import 'pages/Directory.dart';
import 'pages/Social.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'pages/colors/color.dart';

Color colorSec = Color.fromRGBO(0, 44, 62, 1);
Color colorMain = Color.fromRGBO(120, 188, 196, 1);

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

  getPage(_pageController) {
    return _pageController.position;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView(
          physics: PageScrollPhysics(),
          controller: _pageController,
          onPageChanged: onPageChanged,
          scrollDirection: Axis.horizontal,
          // children: <Widget>[new Feed(), new Container(), new Container(), new Container(), new Container()],
          children: <Widget>[
            new Feed(),
            //new Container(),
            new DirectoryHomePage(),
            //new Container(),
            new Login(),
            //new Container(),
            new SocialBody(),
            //new AlertsHomePage()
            new Container(),
          ],
        ),  
        bottomNavigationBar: new BottomNavigationBar(
          fixedColor: colorSec,
          type: BottomNavigationBarType.shifting,
          onTap: navigationTapped,
          items: [
            BottomNavigationBarItem(
              title: Text(
                "Feed",
                style: TextStyle(color: colorSec),
              ),
              activeIcon: Icon(
                Icons.dashboard,
                color: colorMain,
              ),
              icon: Icon(
                Icons.dashboard,
                color: colorSec,
              ),
            ),
           BottomNavigationBarItem(
              title: Text(
                "Feed",
                style: TextStyle(color: colorSec),
              ),
              activeIcon: Icon(
                Icons.dashboard,
                color: colorMain,
              ),
              icon: Icon(
                Icons.dashboard,
                color: colorSec,
              ),
            ),
            BottomNavigationBarItem(
              title: Text(
                "Feed",
                style: TextStyle(color: colorSec),
              ),
              activeIcon: Icon(
                Icons.dashboard,
                color: colorMain,
              ),
              icon: Icon(
                Icons.dashboard,
                color: colorSec,
              ),
            ),
            BottomNavigationBarItem(
              title: Text(
                "Feed",
                style: TextStyle(color: colorSec),
              ),
              activeIcon: Icon(
                Icons.dashboard,
                color: colorMain,
              ),
              icon: Icon(
                Icons.dashboard,
                color: colorSec,
              ),
            ),
            BottomNavigationBarItem(
              title: Text(
                "Feed",
                style: TextStyle(color: colorSec),
              ),
              activeIcon: Icon(
                Icons.dashboard,
                color: colorMain,
              ),
              icon: Icon(
                Icons.dashboard,
                color: colorSec,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
