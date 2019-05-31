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
import 'pages/wallpaper_packs.dart';
import 'package:flutter/services.dart';

Color turq = Color.fromRGBO(0, 206, 209, 1.0);

Color colorSec = Color.fromRGBO(0, 44, 62, 1);
Color colorMain = Color.fromRGBO(120, 188, 196, 1);

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);

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
  DatabaseReference _databaseReference = new FirebaseDatabase().reference();
  DatabaseReference slcmRef;
  bool isHidden;

  update(String token) {
    _databaseReference.child('fcm-token/$token').set({"token": token});
  }

  PageController _pageController;
  int _page = 0;

  String titleOfBar;
  List<String> titleItem = [
    "MTTN : Feed",
    "Directory",
    "SLCM",
    "Social",
    "Alerts"
  ];
  List<BottomNavigationBarItem> navBarItem;
  List<Widget> routes;

  @override
  void initState() {
    titleOfBar = "Feed";
    isHidden = true;
    super.initState();
    _pageController = new PageController();
    _messaging.getToken().then((token) {
      print(token);
      update(token);
    });
    slcmRef = _databaseReference.child('SLCM').child("isHidden");
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
    navBarItem = [
      BottomNavigationBarItem(
        backgroundColor: DynamicTheme.of(context).data.primaryColor != turq
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
        backgroundColor: DynamicTheme.of(context).data.primaryColor != turq
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
        backgroundColor: DynamicTheme.of(context).data.primaryColor != turq
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
        backgroundColor: DynamicTheme.of(context).data.primaryColor != turq
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
        backgroundColor: DynamicTheme.of(context).data.primaryColor != turq
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
    ];

    routes = <Widget>[
      new Feed(),
      new DirectoryHomePage(),
      new Login(),
      new SocialBody(),
      new AlertsHomePage(),
    ];

    return StreamBuilder(
        stream: slcmRef.onValue,
        builder: (context, snap) {
          if (snap.hasData) {
            isHidden = snap.data.snapshot.value;
          }

          return Scaffold(
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
                          color: DynamicTheme.of(context)
                                      .data
                                      .secondaryHeaderColor ==
                                  Colors.white
                              ? Colors.white
                              : Colors.black),
                    ),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.image),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => new WallpaperPacks()));
                        },
                      ),
                      IconButton(
                        icon: Icon(
                            DynamicTheme.of(context).data.primaryColor == turq
                                ? Icons.brightness_3
                                : Icons.brightness_7,
                            size: 30.0,
                            color: DynamicTheme.of(context).data.primaryColor !=
                                    turq
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
              children: (isHidden != null && isHidden)
                  ? [...routes.sublist(0, 2), ...routes.sublist(3)]
                  : routes,
            ),
            bottomNavigationBar: BottomNavigationBar(
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
                titleOfBar = (isHidden != null && isHidden)
                    ? [
                        ...titleItem.sublist(0, 2),
                        ...titleItem.sublist(3)
                      ][index]
                    : titleItem[index];
              },
              items: (isHidden != null && isHidden)
                  ? [...navBarItem.sublist(0, 2), ...navBarItem.sublist(3)]
                  : navBarItem,
            ),
          );
        });
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
