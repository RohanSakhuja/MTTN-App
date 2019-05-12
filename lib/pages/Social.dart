import 'package:flutter/material.dart';
import 'dart:async';    
import 'ScrollingSocial.dart';
import 'Events.dart';
import 'InstagramSection.dart';
import 'YouTubeSection.dart';
import 'colors/color.dart';

class SocialBody extends StatefulWidget{
  @override 
  createState() => new SocialBodyState();
}

class SocialBodyState extends State<SocialBody> with AutomaticKeepAliveClientMixin{

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  final timeout = const Duration(seconds: 15);

  handleTimeout() {}

  final _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context){
    super.build(context);
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        title: Text("Social", style: TextStyle(color: Colors.white),),
        backgroundColor: colorSec,
        centerTitle: true,
        ),
      body: ListView(
      children: <Widget>[ 
        new BuildSocial().createState().build(context),
        Padding(padding: EdgeInsets.only(top: 15.0),),
        new UpcomingEvents(_scaffoldkey).createState().build(context),
        Padding(padding: EdgeInsets.only(top: 20.0),),
        new InstagramFeed().createState().build(context),
        Padding(padding: EdgeInsets.only(top: 25.0),),
        new YouTubeFeed().createState().build(context),
      ]
        )
      );
  }
}

