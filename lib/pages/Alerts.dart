import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

class Alerts {
  String heading;
  String date;
  String content;
  String url;

  Alerts(this.heading, this.content, this.url, this.date);
}

class AlertsHomePage extends StatefulWidget {
  @override
  _AlertsHomePageState createState() => _AlertsHomePageState();
}

class _AlertsHomePageState extends State<AlertsHomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  DatabaseReference _databaseReference =
      new FirebaseDatabase().reference().child('Alerts');
  List<Alerts> alertList = List();

  _parseAlerts(var data) {
    alertList.clear();
    for (var item in data) {
      if (item != null) {
        alertList.add(
            new Alerts(item['Head'], item['Body'], item['Url'], item['Date']));
      }
    }
  }

  _buildAlerts() {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            itemCount: alertList.length,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.only(bottom: 15.0),
                child: Card(
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
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 5.0)),
                          Text(
                            alertList[index].content.length > 70
                                ? alertList[index].content.substring(0, 70) +
                                    "..."
                                : alertList[index].content,
                            style: TextStyle(fontSize: 17),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      _showDialog(context, alertList[index].heading,
                          alertList[index].content, alertList[index].url);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
        stream: _databaseReference.onValue,
        builder: (context, snap) {
          if (snap.hasData) {
            _parseAlerts(snap.data.snapshot.value);
          }
          return Scaffold(
            body: _buildAlerts(),
          );
        });
  }

  _showDialog(
      BuildContext context, String heading, String content, String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(heading),
          content: new Text(content),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Know more"),
              onPressed: () {
                _launchURL(url);
              },
            ),
          ],
        );
      },
    );
  }

  _launchURL(url) async {
    print('URL launched: $url');
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
