import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'colors/color.dart';

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

class _UpcomingEventsState extends State<UpcomingEvents> with AutomaticKeepAliveClientMixin {
  GlobalKey<ScaffoldState> _scaffoldKey;
  _UpcomingEventsState(this._scaffoldKey);

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  DatabaseReference databaseReference = new FirebaseDatabase().reference();
  List<Event> _upcoming = new List();

  Future<int> _fetch() async {
    print('fetching..');
    var snapshot = await databaseReference.once();
    print(snapshot.value['Upcoming Events'].runtimeType);
    List<dynamic> json = snapshot.value['Upcoming Events'];
    print(json.length);
    List<Event> temp = new List();
    for(var item in json){
      if(item != null){
        temp.add(new Event(
            imageUri: item['Image Url'],
            title: item['Name']));
      }
    }
    print('fetched');
    _upcoming.clear();
    _upcoming.addAll(temp);
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
          return Column(
            children: <Widget>[
              Container(
                width: width * 0.915,
                child: Text(
                  "Upcoming Events",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                  color: colorSec,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
              ),
              Center(
                child: SizedBox.fromSize(
                  size: Size.fromHeight(175.0),
                  child: ListView.builder(
                    padding: EdgeInsets.only(left: 15.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: _upcoming.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        child: Container(
                          margin: EdgeInsets.only(right: 20.0),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
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
        height: 1000.0,
        width: 1000.0,
        child: Center(
            child: Image.network(current.imageUri)
            ),
      );
    });
  }
}
