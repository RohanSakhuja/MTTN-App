import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Event {
  String imageUri;
  String title;
  String link; // optional redirection

  Event({this.imageUri, this.title, this.link});
}

class UpcomingEvents extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  UpcomingEvents(this._scaffoldKey);

  @override
  _UpcomingEventsState createState() => _UpcomingEventsState(_scaffoldKey);
}

class _UpcomingEventsState extends State<UpcomingEvents> {
  GlobalKey<ScaffoldState> _scaffoldKey;
  _UpcomingEventsState(this._scaffoldKey);

  DatabaseReference databaseReference = new FirebaseDatabase().reference();
  List<Event> _upcoming = new List();

  Future<int> _fetch() async {
    print('fetching..');
    var snapshot = await databaseReference.once();
    print(snapshot.value['Upcoming Events'].runtimeType);
    List<dynamic> json = snapshot.value['Upcoming Events'];
    for (var item in json) {
      print(item);
    }
    // Map<dynamic, dynamic> json = snapshot.value['Upcoming Events'];
    // print(json);
    // List<Event> temp = new List();
    // // for (var entry in json.keys) {
    // //   if (entry != null) {
    // //     temp.add(new Event(
    // //         imageUri: json['$entry']['Image Url'],
    // //         title: json['$entry']['Name']));
    // //   }
    // // }
    // print('fetched');
    // _upcoming.clear();
    // _upcoming.addAll(temp);
    return 69;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: _fetch(),
      builder: (context, snapshot) {
        print(snapshot.data);
        if (snapshot.hasData == true && snapshot.data == 69) {
          // print(_upcoming[0].imageUri);
          // print(_upcoming[0].title);
          return Container();
          return Column(
            children: <Widget>[
              Center(
                  child: Text(
                "Upcoming Events",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              )),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
              ),
              Center(
                child: SizedBox.fromSize(
                  size: Size.fromHeight(175.0),
                  child: ListView.builder(
                    padding: EdgeInsets.only(left: 35.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: _upcoming.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        child: Container(
                          margin: EdgeInsets.only(right: 20.0),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              image: DecorationImage(
                                  image:
                                      NetworkImage(_upcoming[index].imageUri),
                                  fit: BoxFit.fill)),
                          width: 175.0,
                        ),
                        onTap: () {
                          _persistentBottomSheet(_upcoming[index]);
                        },
                      );
                    },
                  ),
                ),
              )
            ],
          );
        } else {
          return Container(
            height: MediaQuery.of(context).size.height * 0.3,
          );
        }
      },
    );
  }

  void _persistentBottomSheet(Event current) {
    _scaffoldKey.currentState.showBottomSheet((context) {
      return Container(
        color: Colors.red,
        height: 1000.0,
        width: 1000.0,
        child: Center(
            child: Text(
          "POSTER OF THE EVENT",
          style: TextStyle(fontSize: 20.0),
        )),
      );
    });
  }
}
