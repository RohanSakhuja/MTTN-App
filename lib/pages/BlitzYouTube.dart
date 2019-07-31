import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;
// import 'package:html/parser.dart' show parse;

class BlitzYouTubeItem {
  String thumbnail;
  String title;
  String link;

  BlitzYouTubeItem({this.thumbnail, this.title, this.link});
}

List<BlitzYouTubeItem> blitzItems = new List();

DatabaseReference databaseReference =
    new FirebaseDatabase().reference().child('Blitz');

bool noData = false;

_parseBlitzItems(var data) async {
  List<BlitzYouTubeItem> temp = new List();
  if (data == null) {
    noData = true;
    return false;
  } else {
    noData = false;
  }

  try {
    if (data is List) {
      for (var item in data) {
        if (item != null) {
          temp.add(new BlitzYouTubeItem(
              thumbnail: item["thumbnailUrl"],
              title: item["title"],
              link: item["youtubeUrl"]));
        }
      }
    } else {
      var keys = data.keys;
      for (var key in keys) {
        var item = data["$key"];
        if (item != null) {
          temp.add(new BlitzYouTubeItem(
              thumbnail: item["thumbnailUrl"],
              title: item["title"],
              link: item["youtubeUrl"]));
        }
      }
    }
  } catch (e) {
    print(e);
    return false;
  }
  blitzItems.clear();
  blitzItems.addAll(temp.reversed);
  return true;
}

class BlitzFeed extends StatefulWidget {
  @override
  _BlitzFeedState createState() => _BlitzFeedState();
}

class _BlitzFeedState extends State<BlitzFeed>
    with AutomaticKeepAliveClientMixin {
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
          _parseBlitzItems(snap.data.snapshot.value);
        }
        return _buildBlitz(width, height);
      },
    );
  }

  _buildBlitz(width, height) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          width: width * 0.915,
          child: Text(
            "Blitzkrieg Dance Crew India",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
          ),
        ),
        Center(
          child: SizedBox.fromSize(
            size: Size.fromHeight(height * 0.28),
            child: ListView.builder(
              padding: EdgeInsets.only(left: 15.0),
              scrollDirection: Axis.horizontal,
              itemCount: blitzItems.length,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: width * 0.62,
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: height * 0.17,
                        width: width * 0.62,
                        margin: EdgeInsets.only(right: 10.0),
                        child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                            child: GestureDetector(
                                onTap: () => _launchUrl(blitzItems[index].link),
                                child: CachedNetworkImage(
                                    imageUrl: blitzItems[index].thumbnail,
                                    fit: BoxFit.fitWidth))),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                      ),
                      Flexible(
                        child: Container(
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.only(right: 20.0),
                          child: Text(
                            blitzItems[index].title,
                            style: Theme.of(context).textTheme.subhead,
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

_launchUrl(url) async =>
    (await canLaunch(url)) ? await launch(url) : throw 'Could not lauch $url';
