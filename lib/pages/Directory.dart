import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';

class Info {
  String name;
  String contact;
  Info({this.name, this.contact});
}

class Category {
  String catName;
  List<Info> entry;
  List<Widget> tiles;

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Category({this.catName, this.entry}) {
    this.tiles = List<Widget>.generate(this.entry.length, (int index) {
      String str = this.entry[index].contact;
      return Card(
        elevation: 0.0,
        child: new ListTile(
          leading: Icon(Icons.phone),
          title: Text(this.entry[index].name),
          subtitle: Text(this.entry[index].contact),
          onTap: () => _launchURL("tel:" + str),
        ),
      );
    });
  }
}

class DirectoryHomePage extends StatefulWidget {
  _DirectoryHomePageState createState() => _DirectoryHomePageState();
}

class _DirectoryHomePageState extends State<DirectoryHomePage>
    with AutomaticKeepAliveClientMixin {
  List<Category> data = new List();

  @override
  bool get wantKeepAlive => true;

  DatabaseReference databaseReference = new FirebaseDatabase().reference();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<String> loadAsset() async {
    FirebaseDatabase database;
    database = FirebaseDatabase.instance;
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);

    var snapshot = await databaseReference.once();
    Map<dynamic, dynamic> json = snapshot.value['Directory'];
    List<Info> ent = new List();
    data.clear();
    for (var cat in json.keys) {
      ent.clear();
      if (cat != null) {
        for (var i in json['$cat'].keys) {
          if (i != null) {
            String val = json['$cat']['$i'].toString();
            if (val != null) {
              ent.add(new Info(contact: val, name: i));
            }
          }
        }
        Category temp = new Category(catName: cat, entry: ent);
        data.add(temp);
      }
    }
    return 'success';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder(
        future: loadAsset(),
        builder: (context, snapshot) {
          if (snapshot.hasData == true && snapshot.data == 'success') {
            return Container(
              padding: EdgeInsets.only(bottom: 1.0),
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4.0,
                    margin: EdgeInsets.all(3.0),
                    child: ExpansionTile(
                      leading: _getIcon(data[index].catName),
                      key: PageStorageKey(data[index].catName),
                      title: Text(data[index].catName),
                      children: data[index].tiles,
                    ),
                  );
                },
              ),
            );
          } else {
            return Center(
                child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
            ));
          }
        },
      ),
    );
  }

  _getIcon(String name) {
    switch(name){
      case "Auto Service" : {
        return Icon(Icons.local_taxi);
      }
      break;
      case "Eateries" : {
        return Icon(Icons.local_dining);
      }
      break;
      case "Emergency and Important Contacts" : {
        return Icon(Icons.import_contacts);
      }
      break;
      case "Grocery Stores" : {
        return Icon(Icons.local_grocery_store);
      }
      break;
      case "Hotels and Accommodation" : {
        return Icon(Icons.local_hotel);
      }
      break;
      case "MAHE Colleges' Departments" : {
        return Icon(Icons.location_city);
      }
      break;
      case "Medical Services" : {
        return Icon(Icons.local_hospital);
      }
      break;
      case "Miscellaneous Services" : {
        return Icon(Icons.hdr_strong);
      }
      break;
      case "Project Work and Tech Stores" : {
        return Icon(Icons.layers);
      }
      break;
      case "Rent a Bike" : {
        return Icon(Icons.directions_bike);
      }
      break;
      case "Travel Agencies" : {
        return Icon(Icons.card_travel);
      }
      break;
      default :
        return Icon(Icons.chrome_reader_mode);
    }
  }
}