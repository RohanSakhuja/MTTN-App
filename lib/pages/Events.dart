import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:transparent_image/transparent_image.dart';

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

DatabaseReference databaseReference =
    new FirebaseDatabase().reference().child('Upcoming Events');

List<Event> _upcoming = new List();
bool noEvents = false;

_parseEvents(var data) async {
  List<Event> temp = new List();
  if (data == null) {
    noEvents = true;
    return false;
  } else {
    noEvents = false;
  }
  try {
    if (data is List) {
      for (var item in data) {
        if (item != null) {
          temp.add(new Event(imageUri: item["Image Url"], title: item["Name"]));
        }
      }
    } else {
      var keys = data.keys;
      for (var key in keys) {
        var item = data["$key"];
        if (item != null) {
          temp.add(new Event(imageUri: item["Image Url"], title: item["Name"]));
        }
      }
    }
  } catch (e) {
    print(e);
    return false;
  }
  _upcoming.clear();
  _upcoming.addAll(temp.reversed);
  return true;
}

class _UpcomingEventsState extends State<UpcomingEvents>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<ScaffoldState> _scaffoldKey;
  _UpcomingEventsState(this._scaffoldKey);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return StreamBuilder(
      stream: databaseReference.onValue,
      builder: (context, snap) {
        if (snap.hasData) {
          _parseEvents(snap.data.snapshot.value);
        }
        return _buildEvents(width, height);
      },
    );
  }

  _buildEvents(var width, var height) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          width: width * 0.915,
          child: Text(
            "Upcoming Events",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
          ),
        ),
        noEvents
            ? Container(
                height: 100,
                child: Center(
                  child: Text(
                    "No Upcoming Events",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                  ),
                ),
              )
            : Center(
                child: SizedBox.fromSize(
                  size: Size.fromHeight(height * 0.25),
                  child: ListView.builder(
                    padding: EdgeInsets.only(left: 10.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: _upcoming.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        child: Container(
                          width: 130.0,
                          height: 90.0,
                          padding: EdgeInsets.all(5.0),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(7.0)),
                            child: Container(
                              child: CachedNetworkImage(
                                imageUrl: _upcoming[index].imageUri,
                                fit: BoxFit.fitHeight,
                                errorWidget: (context, url, err) => Container(
                                  width: 100,
                                  child: Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                          ),
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
  }

  void _persistentBottomSheet(Event current) {
    _scaffoldKey.currentState.showBottomSheet((context) {
      return Container(
        height: 1000.0,
        width: 1000.0,
        child: Center(
          child: FadeInImage.memoryNetwork(
            image: current.imageUri,
            placeholder: kTransparentImage,
            fit: BoxFit.scaleDown,
          ),
        ),
      );
    });
  }
}
