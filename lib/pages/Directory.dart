import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'colors/color.dart';

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
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Directory",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: colorSec),
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
              backgroundColor: Colors.black,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
            ));
          }
        },
      ),
    );
  }
}

// child: Card(
//                       elevation: 20.0,
//                       child: Container(
//                         child: Center(
//                           child: Column(
//                             children: <Widget>[
//                               Container(
//                                 padding: EdgeInsets.only(top:height * 0.02),
//                                 child:
//                                     Icon(Icons.person_pin, size: height * 0.14),
//                               ),
//                               Padding(
//                                   padding: EdgeInsets.symmetric(vertical: 6.0)),
//                               TextFormField(
//                                 controller: controllerReg,
//                                 decoration: InputDecoration(
//                                     prefixIcon: Icon(Icons.folder),
//                                     labelText: "Registration No."),
//                                 keyboardType: TextInputType.numberWithOptions(),
//                               ),
//                               Padding(
//                                   padding: EdgeInsets.symmetric(
//                                       vertical: height * 0.01)),
//                               TextFormField(
//                                 controller: controllerPass,
//                                 obscureText: obs,
//                                 decoration: InputDecoration(
//                                   prefixIcon: obs
//                                       ? Icon(Icons.lock)
//                                       : Icon(Icons.lock_open),
//                                   labelText: "Password",
//                                 ),
//                               ),
//                               Padding(
//                                   padding: EdgeInsets.symmetric(
//                                       vertical: height * 0.005)),
//                               IconButton(
//                                 icon: obs
//                                     ? Icon(Icons.visibility_off)
//                                     : Icon(Icons.visibility),
//                                 onPressed: () {
//                                   setState(() {
//                                     obs = !obs;
//                                   });
//                                 },
//                               ),
//                               FlatButton(
//                                 child: Container(
//                                   margin: EdgeInsets.only(top: height * 0.001),
//                                   width: width * 0.89,
//                                   height: height * 0.071,
//                                   child: Card(
//                                     elevation: 1.0,
//                                     color: Color.fromRGBO(234, 116, 76, 1.0),
//                                     child: Center(
//                                       child: Text(
//                                         "Login",
//                                         style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 18.0),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   regNo = controllerReg.text;
//                                   password = controllerPass.text;
//                                   _checkCredentials(regNo, password);
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
