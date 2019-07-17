import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:transparent_image/transparent_image.dart';

class Offer {
  String imageUri;
  String name;
  String text;

  Offer({this.imageUri, this.name, this.text});
}

enum SocialState { success, error, noInternet }

class NoirOffers extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  NoirOffers(this._scaffoldKey);

  @override
  _NoirOffersState createState() => _NoirOffersState(this._scaffoldKey);
}

class _NoirOffersState extends State<NoirOffers>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<ScaffoldState> _scaffoldKey;
  _NoirOffersState(this._scaffoldKey);

  @override
  bool get wantKeepAlive => true;

  DatabaseReference databaseReference =
      new FirebaseDatabase().reference().child("Offers");

  List<Offer> _offers = new List();

  _parseOffers(var json) {
    try {
      List<Offer> temp = new List();
      for (var item in json) {
        if (item != null) {
          temp.add(new Offer(
              imageUri: item['Image Url'],
              name: item['Name'],
              text: item['Text']));
        }
        _offers.clear();
        _offers.addAll(temp);
        _offers = _offers.reversed.toList();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return StreamBuilder(
        stream: databaseReference.onValue,
        builder: (context, snap) {
          if (snap.hasData) {
            _parseOffers(snap.data.snapshot.value);
          }
          return _buildOffers(width, height);
        });
  }

  _buildOffers(double width, double height) {
    return Column(
      children: <Widget>[
        Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            width: width * 0.915,
            child: Text("Select Card Offers",
                style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600))),
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
                    padding: EdgeInsets.fromLTRB(5.0, 2.0, 10, 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                      child: CachedNetworkImage(
                        imageUrl: _offers[index].imageUri,
                        fit: BoxFit.fitWidth,
                        placeholder: (context, url) => Container(
                            width: 100,
                            child: Center(child: CircularProgressIndicator())),
                        errorWidget: (context, url, err) => Container(
                          width: 100,
                          child: Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    // width: width * 0.4,
                    // height: 0.18,
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

  _persistentBottomSheet(Offer offer) {
    _scaffoldKey.currentState.showBottomSheet((context) {
      return Container(
        height: 1000.0,
        width: 1000.0,
        alignment: Alignment.center,
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              alignment: Alignment.center,
              child: FadeInImage.memoryNetwork(
                image: offer.imageUri,
                fit: BoxFit.fitWidth,
                placeholder: kTransparentImage,
              ),
            ),
            Divider(height: MediaQuery.of(context).size.height * 0.02),
            Card(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 10.0),
                    child: Text(
                      offer.name,
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 30.0),
                    child: Text(
                      offer.text,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w300),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}
