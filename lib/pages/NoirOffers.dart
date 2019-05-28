import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class Offer {
  String imageUri;
  String name;
  String text;

  Offer({this.imageUri, this.name, this.text});
}

class NoirOffers extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  NoirOffers(this._scaffoldKey);

  @override
  _NoirOffersState createState() => _NoirOffersState(this._scaffoldKey);
}

DatabaseReference databaseReference = new FirebaseDatabase().reference();

List<Offer> _offers = new List();

Future<int> _fetch() async {
  var snapshot = await databaseReference.once();

  List<dynamic> json = snapshot.value['Offers'];
  List<Offer> temp = new List();

  for (var item in json) {
    try {
      if(item != null) {
        temp.add(new Offer(
              imageUri: item['Image Url'],
              name: item['Name'],
              text: item['Text']));
      }
    } catch (e) {}
  }
  _offers.clear();
  _offers.addAll(temp);
  _offers = _offers.reversed.toList();
  return 699;
}

class _NoirOffersState extends State<NoirOffers>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<ScaffoldState> _scaffoldKey;
  _NoirOffersState(this._scaffoldKey);

  final Future<int> sixtyninenine = _fetch();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return FutureBuilder<int>(
      future: sixtyninenine,
      builder: (context, snapshot) {
        // print(snapshot.data);
        if (snapshot.hasData == true && snapshot.data == 699) {
          return new Column(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  width: width * 0.915,
                  child: Text("Select Card Offers",
                      style: TextStyle(
                         fontSize: 17.0,
                      fontWeight: FontWeight.w600))),
              Center(
                child: SizedBox.fromSize(
                  size: Size.fromHeight(height * 0.22),
                  child: ListView.builder(
                    padding: EdgeInsets.only(left: 9.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: _offers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: CachedNetworkImage(
                            imageUrl: _offers[index].imageUri,
                            fit: BoxFit.contain,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                          ),
                          width: width * 0.4,
                          height: 0.18,
                        ),
                        onTap: () {
                          _persistentBottomSheet(_offers[index]);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }

  _persistentBottomSheet(Offer offer) {
    _scaffoldKey.currentState.showBottomSheet((context) {
      return Container(
        height: 1000.0,
        width: 1000.0,
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              alignment: Alignment.center,
              child: CachedNetworkImage(
                imageUrl: offer.imageUri,
                fit: BoxFit.fitWidth,
                placeholder: (context, url) => CircularProgressIndicator(),
              ),
            ),
            Divider(height: 20.0),
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              child: Card(
                child: ListView(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(30.0,30.0,30.0,10.0),
                      child: Text(
                        offer.name,
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(30.0,10.0,30.0,30.0),
                      child: Text(
                        offer.text,
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w300),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
