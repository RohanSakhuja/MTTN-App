import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pages/Feed.dart';
import 'pages/Alerts.dart';
import 'pages/slcm.dart';
import 'pages/Directory.dart';
import 'pages/Social.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/services.dart';

Color turq = Color.fromRGBO(0, 206, 209, 1.0);

Color colorSec = Color.fromRGBO(0, 44, 62, 1);
Color colorMain = Color.fromRGBO(120, 188, 196, 1);

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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

bool darkTheme;

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  final FirebaseMessaging _messaging = FirebaseMessaging();
  DatabaseReference _databaseReference = new FirebaseDatabase().reference();
  DatabaseReference slcmRef;
  bool isHidden;

  PageController _pageController;
  int _page = 0;

  String titleOfBar;
  List<String> titleItem = [
    "MTTN : Social",
    "Feed",
    "Directory",
    "SLCM",
    "Alerts"
  ];
  List<BottomNavigationBarItem> navBarItem;
  List<Widget> routes;

  @override
  void initState() {
    titleOfBar = "Social";
    isHidden = true;
    super.initState();
    _pageController = new PageController();
    _messaging.getToken().then((token) {
      print(token);
      // update(token);
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

  _buildDrawerTile(icon, title, url) {
    return InkWell(
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        leading: icon,
        onTap: () {
          _launchURL(url);
        },
      ),
    );
  }

  _buildDrawer() {
    return Drawer(
        child: ListView(
      children: <Widget>[
        UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: darkTheme ? turq : colorSec),
            accountName: Text("MTTN",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.0,
                    color: darkTheme ? Colors.black : Colors.white)),
            accountEmail: InkWell(
              onTap: () {
                _launchURL(
                    "mailto:editors@manipalthetalk.org?subject=Is this manipal blog?&body=is it?");
              },
              child: Text(
                "editors@manipalthetalk.org",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: darkTheme ? Colors.black : Colors.white),
              ),
            ),
            currentAccountPicture: CircleAvatar(
                backgroundImage: darkTheme
                    ? AssetImage(
                        "assets/ic_launcher.png",
                      )
                    : AssetImage(
                        "assets/ic_launcher_white.png",
                      ))),
        ListTile(
          leading: Icon(Icons.people),
          title: Text("Connect with Us",
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        _buildDrawerTile(Icon(Icons.arrow_right), "Instagram",
            "https://www.instagram.com/manipalthetalk/"),
        _buildDrawerTile(Icon(Icons.arrow_right), "Facebook",
            "https://facebook.com/manipalthetalk/"),
        _buildDrawerTile(Icon(Icons.arrow_right), "Twitter",
            "https://twitter.com/manipalthetalk?ref_src=twsrc%5Egoogle%7Ctwcamp%5Eserp%7Ctwgr%5Eauthor"),
        _buildDrawerTile(Icon(Icons.arrow_right), "Website",
            "https://www.manipalthetalk.org"),
        Divider(),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text("App Settings",
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        ListTile(
          leading: Icon(Icons.settings_brightness),
          title:
              Text("Dark Theme", style: TextStyle(fontWeight: FontWeight.w400)),
          trailing: Switch(
            value: darkTheme,
            onChanged: (bool val) {
              setState(() {
                darkTheme = val;
              });
              changeBrightness();
            },
          ),
        ),
        ListTile(
          leading: allowNotification
              ? Icon(Icons.notifications)
              : Icon(Icons.notifications_off),
          title: Text("Notification",
              style: TextStyle(fontWeight: FontWeight.w400)),
          trailing: Switch(
            value: allowNotification,
            onChanged: (bool val) {
              // Implement notification toggle here

              setState(() {
                allowNotification = val;
              });
            },
          ),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.hdr_weak),
          title: Text("Others", style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        _buildDrawerTile(Icon(Icons.assignment), "Privacy Policy",
            "https://www.termsfeed.com/privacy-policy/ec69fc0be140c10cf91cf70816a8ba79"),
      ],
    ));
  }

  _launchURL(url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  bool allowNotification = true;

  _buildBottomNavBarItem(String title, Icon activeIcon, Icon icon) {
    return BottomNavigationBarItem(
      backgroundColor: darkTheme ? Colors.black38 : colorSec,
      title: Text(title),
      activeIcon: activeIcon,
      icon: icon,
    );
  }

  final _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    darkTheme = Theme.of(context).brightness == Brightness.dark;

    navBarItem = [
      _buildBottomNavBarItem(
          "Social", Icon(Icons.gps_fixed), Icon(Icons.gps_not_fixed)),
      _buildBottomNavBarItem(
          "Feed", Icon(Icons.developer_board), Icon(Icons.dashboard)),
      _buildBottomNavBarItem(
          "Directory", Icon(Icons.contact_phone), Icon(Icons.contacts)),
      _buildBottomNavBarItem(
          "SLCM", Icon(Icons.local_library), Icon(Icons.local_library)),
      _buildBottomNavBarItem(
          "Alerts", Icon(Icons.notifications), Icon(Icons.notifications_none)),
    ];

    routes = <Widget>[
      new SocialBody(),
      new Feed(),
      new DirectoryHomePage(),
      new SLCM(),
      new AlertsHomePage(),
    ];

    return StreamBuilder(
        stream: slcmRef.onValue,
        builder: (context, snap) {
          if (snap.hasData) {
            isHidden = snap.data.snapshot.value;
          }

          return Scaffold(
            key: _scaffoldkey,
            appBar: titleOfBar != 'SLCM'
                ? AppBar(
                    leading: IconButton(
                      icon: Icon(Icons.menu,
                          color: darkTheme ? Colors.black : Colors.white),
                      onPressed: () {
                        _scaffoldkey.currentState.openDrawer();
                      },
                    ),
                    backgroundColor: darkTheme ? turq : colorSec,
                    centerTitle: false,
                    title: Text(
                      titleOfBar,
                      style: TextStyle(
                          color: darkTheme ? Colors.black : Colors.white),
                    ),
                  )
                : null,
            drawer: _buildDrawer(),
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
              backgroundColor: darkTheme ? turq : colorSec,
              selectedItemColor: darkTheme ? turq : Colors.white,
              unselectedItemColor: Colors.white54,
              currentIndex: _page,
              type: BottomNavigationBarType.shifting,
              onTap: (index) {
                navigationTapped(index);
                titleOfBar = (isHidden != null && isHidden)
                    ? [
                        ...titleItem.sublist(0, 3),
                        ...titleItem.sublist(4)
                      ][index]
                    : titleItem[index];
              },
              items: (isHidden != null && isHidden)
                  ? [...navBarItem.sublist(0, 3), ...navBarItem.sublist(4)]
                  : navBarItem,
            ),
          );
        });
  }

  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(
        Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark);
    // DynamicTheme.of(context).setThemeData(
    //   ThemeData(
    //     primaryColor:
    //         Theme.of(context).primaryColor == colorSec ? turq : colorSec,
    //     brightness: Theme.of(context).brightness == Brightness.dark
    //         ? Brightness.light
    //         : Brightness.dark,
    //     floatingActionButtonTheme: FloatingActionButtonThemeData(
    //       backgroundColor:
    //           Theme.of(context).floatingActionButtonTheme.backgroundColor ==
    //                   turq
    //               ? colorMain
    //               : turq,
    //     ),
    //   ),
    // );
  }
}
