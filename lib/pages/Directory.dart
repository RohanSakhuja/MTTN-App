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
    // print(this.entry.length);
    this.tiles = List<Widget>.generate(
        this.entry.length,
        (int index) => new ListTile(
              leading: Icon(Icons.phone),
              title: Text(this.entry[index].name),
              subtitle: Text(this.entry[index].contact),
              onTap: () => _launchURL("tel:${this.entry[index].contact}"),
            ),
        growable: true);
  }
}

class DirectoryHomePage extends StatefulWidget {
  _DirectoryHomePageState createState() => _DirectoryHomePageState();
}

class _DirectoryHomePageState extends State<DirectoryHomePage> {
  List<Category> data = new List();
  DatabaseReference databaseReference = new FirebaseDatabase().reference();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<String> loadAsset() async {
    var snapshot = await databaseReference.once();
    Map<dynamic, dynamic> json = snapshot.value['Directory'];
    List<Info> ent = new List();
    // print(json.keys.length);
    data.clear();
    for (var cat in json.keys) {
      // print(cat);
      // ent.clear();
      if (cat != null) {
        for (var i in json['$cat'].keys) {
          // print(i);
          if (i != null) {
            String val = json['$cat']['$i'].toString();
            // print(val);
            if (val != null) {
              ent.add(new Info(contact: val, name: i));
            }
            // print('done');
          }
        }
        Category temp = new Category(catName: cat, entry: ent);
        data.add(temp);
        print('%%%');
        print(data[0].entry[0].name);
        print(data[0].entry[0].contact);
        print(cat);
        print('%%%');
      }
    }
    print(data.length);
    print('Data Added!');
    return 'success';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Directory",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white),
      body: FutureBuilder(
        future: loadAsset(),
        builder: (context, snapshot) {
          print(snapshot.data);
          if (snapshot.hasData == true && snapshot.data == 'success') {
            print('###');
            for (var i in data) {
              print(i.catName);
              print(i.entry[0]);
            }
            print('###');
            return Container(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    key: PageStorageKey(data[index].catName),
                    title: Text(data[index].catName),
                    children: data[index].tiles,
                    // List<Widget>.generate(
                    //     data[index].entry.length,
                    //     (int i) => new ListTile(
                    //           leading: Icon(Icons.phone),
                    //           title: Text(data[index].entry[i].name),
                    //           subtitle: Text(data[index].entry[i].contact),
                    //           onTap: () =>
                    //               launch("tel:${data[index].entry[i].contact}"),
                    //         ),
                    // growable: true),
                  );
                },
              ),
            );
          } else {
            print('CircularReturned');
            return Center(child: CircularProgressIndicator(
              backgroundColor: Colors.black,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
            ));
          }
        },
      ),
    );
  }
}
