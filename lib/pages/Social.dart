import 'package:flutter/material.dart';
import 'package:mttn_app/main.dart';
import 'package:mttn_app/pages/InstagramSection.dart';
import 'package:mttn_app/pages/NoirCard.dart';
import 'Events.dart';
import 'YouTubeSection.dart';

class SocialBody extends StatefulWidget {
  @override
  createState() => new SocialBodyState();
}

class SocialBodyState extends State<SocialBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: darkTheme ? Colors.black : Colors.white,
        key: _scaffoldkey,
        body: ListView(children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 10.0)),
          NoirCard(_scaffoldkey),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          Card(child: new UpcomingEvents(_scaffoldkey)),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          Card(child: InstagramFeed(),),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          Card(child: YouTubeFeed()),
          Padding(padding: EdgeInsets.only(top: 10.0)),
        ]));
  }
}
