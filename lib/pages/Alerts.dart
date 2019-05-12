import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'colors/color.dart';

class Alerts {
  String heading;
  String content;

  Alerts(this.heading, this.content);
}

class AlertsHomePage extends StatefulWidget {
  @override
  _AlertsHomePageState createState() => _AlertsHomePageState();
}

class _AlertsHomePageState extends State<AlertsHomePage> with AutomaticKeepAliveClientMixin{

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  final FirebaseMessaging _messaging = new FirebaseMessaging();

  List<Alerts> alertList = List();

  void initState() {
    _fetchAlerts();
    super.initState();
  }

  Future<Null> _refresh() {
    bool _needRefresh = true;
    Completer<Null> completer = new Completer<Null>();
    _fetchAlerts().then((value){
      
    });
    return completer.future;
  }

  _fetchAlerts() {
    DatabaseReference databaseReference = new FirebaseDatabase().reference();
    databaseReference.once().then((DataSnapshot snapshot) {
      List json = snapshot.value['Alerts'];
      List<Alerts> temp = new List();
      for (var ele in json) {
        Alerts al = new Alerts(ele['title'], ele['content']);
        temp.add(al);
      }
      print(temp.length);
      if (temp.length != 1) {
        print('!%%%!');
        temp.removeAt(0);
        alertList.clear();
        alertList.addAll(temp);
        setState(() {});
      } else {
        print('###');
        alertList.clear();
        alertList.addAll(temp);
        setState(() {});
      }
    });
  }

  _buildAlerts() {
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: alertList.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.only(bottom: 15.0),
                  child: Card(
                    color: Colors.white.withOpacity(1.0),
                    elevation: 3.0,
                    child: InkWell(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              alertList[index].heading,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 5.0)),
                            Text(
                              alertList[index].content.length > 70
                                  ? alertList[index].content.substring(0, 70) +
                                      "..."
                                  : alertList[index].content,
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 17),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        _showDialog(context, alertList[index].heading,
                            alertList[index].content);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text("Alerts", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
        backgroundColor: colorSec
      ),
      body: _buildAlerts(),
    );
  }

  _showDialog(BuildContext context, String heading, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(heading),
          content: new Text(content),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
