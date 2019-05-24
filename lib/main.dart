import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/rendering.dart';
import 'pages/Feed.dart';
import 'pages/Alerts.dart';
import 'pages/login.dart';
import 'pages/Directory.dart';
import 'pages/Social.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'pages/NoirOffers.dart';

Color turq = Color.fromRGBO(0, 206, 209, 1.0);

Color colorSec = Color.fromRGBO(0, 44, 62, 1);
Color colorMain = Color.fromRGBO(120, 188, 196, 1);

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
            floatingActionButtonTheme:
                FloatingActionButtonThemeData(backgroundColor: turq),
            primaryColor: colorSec,
            brightness: brightness,
            secondaryHeaderColor: Colors.white,
          ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          theme: theme,
          title: 'MTTN App',
          home: HomePage(),
          debugShowCheckedModeBanner: false,
        );
      },
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

  String titleOfBar;

  @override
  void initState() {
    titleOfBar = "Feed";
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
        appBar: titleOfBar != 'SLCM'
            ? AppBar(
                backgroundColor:
                    DynamicTheme.of(context).data.primaryColor == turq
                        ? turq
                        : colorSec,
                elevation: 8.0,
                centerTitle: false,
                title: Text(
                  titleOfBar,
                  style: TextStyle(
                      color:
                          DynamicTheme.of(context).data.secondaryHeaderColor ==
                                  Colors.white
                              ? Colors.white
                              : Colors.black),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                        DynamicTheme.of(context).data.primaryColor == turq
                            ? Icons.brightness_3
                            : Icons.brightness_7,
                        size: 30.0,
                        color:
                            DynamicTheme.of(context).data.primaryColor != turq
                                ? Colors.white
                                : Colors.black),
                    onPressed: changeBrightness,
                  )
                ],
              )
            : null,
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: onPageChanged,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            new Feed(),
            //new Container(),
            new DirectoryHomePage(),
            //new Container(),
            new Login(),
         //   new Container(),
            new SocialBody(),
             //new Container(),
            new AlertsHomePage(),
            //new Container(),
          ],
        ),
        bottomNavigationBar: new BottomNavigationBar(
          backgroundColor: DynamicTheme.of(context).data.primaryColor,
          selectedItemColor:
              DynamicTheme.of(context).data.primaryColor == colorSec
                  ? Colors.white
                  : turq,
          unselectedItemColor: Colors.white54,
          currentIndex: _page,
          type: BottomNavigationBarType.shifting,
          onTap: (index) {
            navigationTapped(index);
            switch (index) {
              case 0:
                titleOfBar = "MTTN : Feed";
                break;
              case 1:
                titleOfBar = "Directory";
                break;
              case 2:
                titleOfBar = "SLCM";
                break;
              case 3:
                titleOfBar = "Social";
                break;
              case 4:
                titleOfBar = "Alerts";
                break;
              default:
            }
          },
          items: [
            BottomNavigationBarItem(
              backgroundColor:
                  DynamicTheme.of(context).data.primaryColor != turq
                      ? colorSec
                      : Colors.black38,
              title: Text(
                "Feed",
              ),
              activeIcon: Icon(
                Icons.developer_board,
              ),
              icon: Icon(
                Icons.dashboard,
              ),
            ),
            BottomNavigationBarItem(
              backgroundColor:
                  DynamicTheme.of(context).data.primaryColor != turq
                      ? colorSec
                      : Colors.black38,
              title: Text(
                "Directory",
              ),
              activeIcon: Icon(
                Icons.contact_phone,
              ),
              icon: Icon(
                Icons.contacts,
              ),
            ),
            BottomNavigationBarItem(
              backgroundColor:
                  DynamicTheme.of(context).data.primaryColor != turq
                      ? colorSec
                      : Colors.black38,
              title: Text(
                "SLCM",
              ),
              activeIcon: Icon(
                Icons.local_library,
              ),
              icon: Icon(
                Icons.local_library,
              ),
            ),
            BottomNavigationBarItem(
              backgroundColor:
                  DynamicTheme.of(context).data.primaryColor != turq
                      ? colorSec
                      : Colors.black38,
              title: Text(
                "Social",
              ),
              activeIcon: Icon(
                Icons.gps_fixed,
              ),
              icon: Icon(
                Icons.gps_not_fixed,
              ),
            ),
            BottomNavigationBarItem(
              backgroundColor:
                  DynamicTheme.of(context).data.primaryColor != turq
                      ? colorSec
                      : Colors.black38,
              title: Text(
                "Alerts",
              ),
              activeIcon: Icon(
                Icons.notifications,
              ),
              icon: Icon(
                Icons.notifications_none,
                // color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void changeBrightness() {
    DynamicTheme.of(context).setThemeData(
      ThemeData(
        secondaryHeaderColor:
            Theme.of(context).secondaryHeaderColor == Colors.white
                ? Colors.black
                : Colors.white,
        primaryColor:
            Theme.of(context).primaryColor == colorSec ? turq : colorSec,
        brightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor:
              Theme.of(context).floatingActionButtonTheme.backgroundColor ==
                      turq
                  ? colorMain
                  : turq,
        ),
      ),
    );
  }
}
