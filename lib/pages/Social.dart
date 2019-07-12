import 'package:flutter/material.dart';
import 'ScrollingSocial.dart';
import 'Events.dart';
import 'YouTubeSection.dart';
import 'NoirOffers.dart';

class SocialBody extends StatefulWidget {
  @override
  createState() => new SocialBodyState();
}

class SocialBodyState extends State<SocialBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final timeout = const Duration(seconds: 15);

  handleTimeout() {}

  final _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        key: _scaffoldkey,
        body: ListView(children: <Widget>[
          BuildSocial().createState().build(context),
          Card(child: new UpcomingEvents(_scaffoldkey).createState().build(context)),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          Card(child: new NoirOffers(_scaffoldkey).createState().build(context)),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          Card(child: YouTubeFeed().createState().build(context)),
          Padding(padding: EdgeInsets.only(top: 10.0)),
        ]));
  }
}
