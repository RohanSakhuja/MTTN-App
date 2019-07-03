import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

class Event {
  String imageUri;
  String title;
  String link;

  Event({this.imageUri, this.title, this.link});
}

class UpcomingEvents extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  UpcomingEvents(this._scaffoldKey);

  @override
  _UpcomingEventsState createState() => _UpcomingEventsState(_scaffoldKey);
}

DatabaseReference databaseReference = new FirebaseDatabase().reference();

List<Event> _upcoming = new List();

Future<int> _fetch() async {
  var snapshot = await databaseReference.once();
  Map<dynamic, dynamic> json = snapshot.value['Upcoming Events'];
  print(json);
  List<Event> temp = new List();
  for (var item in json.keys) {
    if (item != null) {
      temp.add(new Event(
          imageUri: json[item]['Image Url'], title: json[item]['Name']));
    }
  }
  _upcoming.clear();
  _upcoming.addAll(temp);
  return 69;
}

class _UpcomingEventsState extends State<UpcomingEvents>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<ScaffoldState> _scaffoldKey;
  _UpcomingEventsState(this._scaffoldKey);

  final Future<int> sixtynine = _fetch();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return FutureBuilder<int>(
      future: sixtynine,
      builder: (context, snapshot) {
        if (snapshot.hasData == true && snapshot.data == 69) {
          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                width: width * 0.915,
                child: Text(
                  "Upcoming Events",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Center(
                child: SizedBox.fromSize(
                  size: Size.fromHeight(height * 0.25),
                  child: ListView.builder(
                    padding: EdgeInsets.only(left: 15.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: _upcoming.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        child: Container(
                          padding: EdgeInsets.all(5.0),
                          child: CachedNetworkImage(
                            imageUrl: _upcoming[index].imageUri,
                            fit: BoxFit.cover,
                          ),
                          width: width * 0.35,
                          height: height * 0.2,
                        ),
                        onTap: () {
                          _persistentBottomSheet(_upcoming[index]);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        } else {
          return Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  void _persistentBottomSheet(Event current) {
    _scaffoldKey.currentState.showBottomSheet((context) {
      return Container(
        height: 1000.0,
        width: 1000.0,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: current.imageUri,
            fit: BoxFit.scaleDown,
          ),
        ),
      );
    });
  }
}
