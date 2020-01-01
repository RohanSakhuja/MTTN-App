import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mttn_app/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Info {
  String name;
  String contact;
  String url;
  Info({this.name, this.contact, this.url});
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
      String url = this.entry[index].url;
      bool location = url != "null";
      return Card(
        elevation: 0.0,
        child: Container(
          color: darkTheme ? Colors.black45 : Colors.white,
          child: new ListTile(
            leading: Icon(Icons.phone, color: Colors.blue,),
            title: Text(this.entry[index].name),
            subtitle: Text(this.entry[index].contact),
            onTap: () => _launchURL("tel:" + str),
            trailing: location?IconButton(
              icon: Icon(Icons.map, color: Colors.blue,),
              onPressed: () => _launchURL(url),
            ):null,
          ),
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
  SharedPreferences _preferences;

  @override
  bool get wantKeepAlive => true;

  DatabaseReference databaseReference = new FirebaseDatabase().reference();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _fetchDirectory() async {
    _preferences = await SharedPreferences.getInstance();
    String data = _preferences.getString('directory')??'null';
    Map<dynamic, dynamic> json;
    if(data != 'null'){
      json = jsonDecode(data);
    } else {
      FirebaseDatabase database;
    database = FirebaseDatabase.instance;
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);

    var snapshot = await databaseReference.once();
    json = snapshot.value['Dir'];
    }
    return json;
  }

  Future<String> loadAsset() async {
    var json = await _fetchDirectory();
    List<Info> ent = new List();
    data.clear();
    var categoryKeys = json.keys.toList()..sort();
    for (var cat in categoryKeys) {
      ent.clear();
      if (cat != null) {
        var entryKeys = json['$cat'].keys.toList()..sort();
        for (var i in entryKeys) {
          if (i != null) {
            String contact = json['$cat']['$i']['contact'].toString();
            String location = json['$cat']['$i']['location'].toString()??"null";
            if (contact != null) {
              ent.add(new Info(contact: contact, name: i, url: location));
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
      backgroundColor: darkTheme ? Colors.black : Colors.white,
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
                    color: darkTheme ? Colors.white10 : Colors.white,
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