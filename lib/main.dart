import 'dart:convert';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

Color primaryLight = Colors.indigoAccent;
Color primaryDark = Colors.black12;
Color secondaryLight = Color.fromRGBO(240, 240, 240, 1);
Color secondaryDark = Color.fromRGBO(25, 25, 25, 1);

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Cabin',
        floatingActionButtonTheme:
            FloatingActionButtonThemeData(backgroundColor: Colors.blueGrey),
        primaryColor: primaryLight,
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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  DatabaseReference _databaseReference = new FirebaseDatabase().reference();
  DatabaseReference slcmRef;
  bool isHidden;
  SharedPreferences _preferences;

  PageController _pageController;
  int _page = 0;

  String titleOfBar;
  List<String> titleItem = ["Feed", "SLCM", "Social", "Directory", "Alerts"];
  List<BottomNavigationBarItem> navBarItem;
  List<Widget> routes;

  // bool allowNotification = true;
  final _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    titleOfBar = "Feed";
    isHidden = false;
    super.initState();
    firebaseCloudMessagingListeners();
    _pageController = new PageController();
    slcmRef = _databaseReference.child('SLCM').child("isHidden");
    _startupCache();
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        // print('on message $message');
        String url = message["data"]["URL"] ?? "null";
        String tab = message["data"]["TAB"] ?? "null";

        if (url != "null" || tab != null) {
          fcmShowDialog(
              message["notification"]["title"], message["notification"]["body"],
              url: url, tab: tab);
        }
      },
      onResume: (Map<String, dynamic> message) async {
        // print('on resume $message');
        String url = message["data"]["URL"] ?? "null";
        String tab = message["data"]["TAB"] ?? "null";
        if (url != "null") {
          _launchURL(url);
        }
        if (tab != "null") {
          fcmChangeTab(tab);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        // print('on launch $message');
        String url = message["data"]["URL"] ?? "null";
        String tab = message["data"]["TAB"] ?? "null";
        if (url != "null") {
          _launchURL(url);
        }
        if (tab != "null") {
          fcmChangeTab(tab);
        }
      },
    );
  }

  void fcmChangeTab(String tab) {
    if (!(isHidden == true && tab == "SLCM")) {
      if (titleItem.contains(tab)) {
        int val = titleItem.indexOf(tab);
        if (tab != "Feed" && isHidden == true) {
          val = val - 1;
        }
        changePageView(val);
      }
    }
  }

  void fcmShowDialog(String title, String content, {String url, String tab}) {
    showDialog(
        context: _scaffoldkey.currentContext,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              FlatButton(
                child: Text("Explore"),
                onPressed: () {
                  if (tab != "null") {
                    fcmChangeTab(tab);
                  }
                  if (url != "null") {
                    _launchURL(url);
                  }
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Close"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
  }

  void _startupCache() async {
    _preferences = await SharedPreferences.getInstance();
    _cacheDirectory();
    _cacheUrls();
    _cacheAvatars();
    // var temp = _preferences.getBool("Notifications") ?? null;
    // if (temp == null) {
    //   _preferences.setBool("Notifications", true);
    // } else {
    //   allowNotification = temp;
    // }
  }

  void _cacheUrls() async {
    _databaseReference.child('URL').once().then((data) {
      _preferences.setString('url', jsonEncode(data.value));
    });
  }

  void _cacheDirectory() async {
    _databaseReference.child('Dir').once().then((data) {
      _preferences.setString('directory', jsonEncode(data.value));
    });
  }

  void _cacheAvatars() async {
    _databaseReference.child('Avatars').once().then((data) {
      _preferences.setString("Akshit", data.value["Akshit"]);
      _preferences.setString("Rohan", data.value["Rohan"]);
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
            decoration:
                BoxDecoration(color: darkTheme ? primaryDark : primaryLight),
            accountName: Text("MTTN",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.0,
                    color: !darkTheme ? Colors.white : Colors.white)),
            accountEmail: InkWell(
              onTap: () {
                _launchURL("mailto:editors@manipalthetalk.org?subject=&body=");
              },
              child: Text(
                "editors@manipalthetalk.org",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: !darkTheme ? Colors.white : Colors.white),
              ),
            ),
            currentAccountPicture: CircleAvatar(
                backgroundImage: !darkTheme
                    ? AssetImage(
                        "assets/ic_launcher.png",
                      )
                    : AssetImage(
                        "assets/ic_launcher_white.png",
                      ))),
        ListTile(
          leading: Icon(Icons.people),
          title: Text("Connect with Us",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        _buildDrawerTile(Icon(FontAwesomeIcons.instagram), "Instagram",
            "https://www.instagram.com/manipalthetalk/"),
        _buildDrawerTile(Icon(FontAwesomeIcons.facebook), "Facebook",
            "https://facebook.com/manipalthetalk/"),
        _buildDrawerTile(Icon(FontAwesomeIcons.twitter), "Twitter",
            "https://twitter.com/manipalthetalk?ref_src=twsrc%5Egoogle%7Ctwcamp%5Eserp%7Ctwgr%5Eauthor"),
        _buildDrawerTile(Icon(FontAwesomeIcons.wordpress), "Website",
            "https://www.manipalthetalk.org"),
        Divider(),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text("App Settings",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
        // ListTile(
        //   leading: allowNotification
        //       ? Icon(Icons.notifications)
        //       : Icon(Icons.notifications_off),
        //   title: Text("Notification",
        //       style: TextStyle(fontWeight: FontWeight.w400)),
        //   trailing: Switch(
        //     value: allowNotification,
        //     onChanged: (bool val) {
        //       _preferences.setBool('Notifications', val);
        //       setState(() {
        //         allowNotification = val;
        //       });
        //     },
        //   ),
        // ),
        Divider(),
        ListTile(
          leading: Icon(Icons.hdr_weak),
          title: Text("Others", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        ListTile(
          leading: Icon(Icons.developer_mode),
          title: Text(
            "Developers",
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          onTap: () {
            Navigator.of(context).pop();
            _showDevelopersSheet(_scaffoldkey.currentContext);
          },
        ),
        _buildDrawerTile(Icon(FontAwesomeIcons.github), "Source Code",
            "https://github.com/RohanSakhuja/MTTN-App"),
        _buildDrawerTile(Icon(Icons.assignment), "Privacy Policy",
            "https://www.termsfeed.com/privacy-policy/ec69fc0be140c10cf91cf70816a8ba79"),
      ],
    ));
  }

  _showDevelopersSheet(context) {
    String avatar1 = _preferences.getString("Rohan");
    String avatar2 = _preferences.getString("Akshit");
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext buildContext) {
          return Container(
            decoration: new BoxDecoration(
                color: darkTheme ? secondaryDark : secondaryLight,
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(30.0),
                  topRight: const Radius.circular(30.0),
                )),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Material(
                  color: darkTheme ? Colors.white : primaryLight,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  child: Container(
                    height: 5,
                    width: 35,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Developers",
                  style: TextStyle(
                      fontSize: 24,
                      color: darkTheme ? Colors.white : primaryLight),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          minRadius: 40,
                          maxRadius: 60,
                          backgroundImage: avatar1 == null
                              ? AssetImage("assets/avatar.jpg")
                              : CachedNetworkImageProvider(avatar1),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Rohan Sakhuja",
                          style: TextStyle(
                              fontSize: 20,
                              color: darkTheme ? Colors.white : primaryLight),
                        ),
                        Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                FontAwesomeIcons.github,
                                color: darkTheme ? Colors.white : primaryLight,
                              ),
                              onPressed: () =>
                                  _launchURL("https://github.com/RohanSakhuja"),
                            ),
                            IconButton(
                              icon: Icon(
                                FontAwesomeIcons.linkedin,
                                color: darkTheme ? Colors.white : primaryLight,
                              ),
                              onPressed: () => _launchURL(
                                  "https://www.linkedin.com/in/rohan-sakhuja-b633a514b/"),
                            ),
                            IconButton(
                              icon: Icon(
                                FontAwesomeIcons.instagram,
                                color: darkTheme ? Colors.white : primaryLight,
                              ),
                              onPressed: () => _launchURL(
                                  "https://www.instagram.com/rohan_sakhuja/"),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        CircleAvatar(
                          minRadius: 40,
                          maxRadius: 60,
                          backgroundImage: avatar2 == null
                              ? AssetImage("assets/avatar.jpg")
                              : CachedNetworkImageProvider(avatar2),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Akshit Saxena",
                          style: TextStyle(
                              fontSize: 20,
                              color: darkTheme ? Colors.white : primaryLight),
                        ),
                        Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                FontAwesomeIcons.github,
                                color: darkTheme ? Colors.white : primaryLight,
                              ),
                              onPressed: () => _launchURL(
                                  "https://github.com/Akshiiitsaxena"),
                            ),
                            IconButton(
                              icon: Icon(
                                FontAwesomeIcons.linkedin,
                                color: darkTheme ? Colors.white : primaryLight,
                              ),
                              onPressed: () => _launchURL(
                                  "https://www.linkedin.com/in/akshit-saxena-b6b613184"),
                            ),
                            IconButton(
                              icon: Icon(
                                FontAwesomeIcons.instagram,
                                color: darkTheme ? Colors.white : primaryLight,
                              ),
                              onPressed: () => _launchURL(
                                  "https://www.instagram.com/akshit.saxenamide/"),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Material(
                      color: darkTheme ? Colors.red : Colors.redAccent,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "Report a Bug",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.bug_report,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        onTap: () => _launchURL(
                            "mailto:mttndevelopers@gmail.com?subject=&body="),
                      ),
                    ),
                    Material(
                      color: darkTheme ? Colors.red : Colors.redAccent,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "Rate the App",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.star_half,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        onTap: () => _launchURL(
                            "https://play.google.com/store/apps/details?id=com.mttn.android"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  _launchURL(url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  _buildBottomNavBarItem(String title, Icon activeIcon, Icon icon) {
    return BottomNavigationBarItem(
      backgroundColor: darkTheme ? secondaryDark : secondaryLight,
      title: Text(title),
      activeIcon: activeIcon,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    darkTheme = Theme.of(context).brightness == Brightness.dark;

    navBarItem = [
      _buildBottomNavBarItem(
          "Feed", Icon(Icons.developer_board), Icon(Icons.dashboard)),
      _buildBottomNavBarItem(
          "SLCM", Icon(Icons.person_pin), Icon(Icons.person_outline)),
      _buildBottomNavBarItem(
          "Social", Icon(Icons.favorite), Icon(Icons.public)),
      _buildBottomNavBarItem(
          "Directory", Icon(Icons.contact_phone), Icon(Icons.contacts)),
      _buildBottomNavBarItem(
          "Alerts", Icon(Icons.notifications), Icon(Icons.notifications_none)),
    ];

    //feed slcm social direc alerts

    routes = <Widget>[
      new Feed(),
      new SLCM(),
      new SocialBody(),
      new DirectoryHomePage(),
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
                          color: darkTheme ? Colors.white : Colors.white),
                      onPressed: () {
                        _scaffoldkey.currentState.openDrawer();
                      },
                    ),
                    backgroundColor: darkTheme ? primaryDark : primaryLight,
                    centerTitle: false,
                    title: Text(
                      titleOfBar,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: darkTheme ? Colors.white : Colors.white),
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
                  ? [...routes.sublist(0, 1), ...routes.sublist(2)]
                  : routes,
            ),
            bottomNavigationBar: BottomNavigationBar(
              //backgroundColor: darkTheme ? turq : Colors.brown,
              selectedItemColor:
                  darkTheme ? Colors.indigo : Colors.indigoAccent,
              unselectedItemColor:
                  darkTheme ? Colors.white24 : Colors.black.withOpacity(0.65),
              currentIndex: _page,
              type: BottomNavigationBarType.shifting,
              onTap: (index) => changePageView(index),
              items: (isHidden != null && isHidden)
                  ? [...navBarItem.sublist(0, 1), ...navBarItem.sublist(2)]
                  : navBarItem,
            ),
          );
        });
  }

  changePageView(index) {
    {
      navigationTapped(index);
      titleOfBar = (isHidden != null && isHidden)
          ? [...titleItem.sublist(0, 1), ...titleItem.sublist(2)][index]
          : titleItem[index];
    }
  }

  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(
        Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark);
  }
}
