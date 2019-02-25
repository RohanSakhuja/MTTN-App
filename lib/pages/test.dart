import 'package:flutter/material.dart';
import 'Events.dart';

class Test extends StatefulWidget{
  @override
  TestState createState() => new TestState();
}

class TestState extends State<Test>{
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(),
      body: UpcomingEvents(_scaffoldKey).createState().build(context),
    );
  }
}