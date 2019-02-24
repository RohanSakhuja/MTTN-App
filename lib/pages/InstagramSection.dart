import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Post {
  String type;
  String thumbnail;
  String original;
  String link;

  Post({this.type, this.thumbnail, this.original, this.link});
}

class InstagramFeed extends StatefulWidget {
  @override
  _InstagramFeedState createState() => _InstagramFeedState();
}

class _InstagramFeedState extends State<InstagramFeed> {
  List<Post> posts = new List();

  Future<String> _fetchPosts() async {
    String uri =
        'https://api.instagram.com/v1/users/self/media/recent/?access_token=1605816208.94452f5.f63f1c8790b84d6a980d5610e99a9594';
    var response = await http.get(uri);
    var body = jsonDecode(response.body);
    posts.clear();
    for (var item in body['data']) {
      posts.add(new Post(
          thumbnail: item['images']['thumbnail']['url'],
          original: item['images']['standard_resolution']['url'],
          type: item['type'],
          link: item['link']));
    }
    return 'success';
  }

  _launchURL(url) async {
    print('URL launched: $url');
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  List<Widget> _buildGridImages(numberOfTiles, context) {
    List<GestureDetector> containers =
        new List<GestureDetector>.generate(numberOfTiles, (int index) {
      return GestureDetector(
        child: Hero(
          child: new Container(
            child: new Image.network(
              posts[index].thumbnail,
              fit: BoxFit.cover,
            ),
          ),
          tag: index,
        ),
        onTap: () {
          Navigator.of(context).push(new PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) {
                return new Material(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: new InkWell(
                            child: new Hero(
                              child: new Image.network(
                                posts[index].original,
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                              ),
                              tag: index,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Center(
                          child: FlatButton(
                            child: Text(
                              'View in Instagram',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.0),
                            ),
                            onPressed: () => _launchURL(posts[index].link),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }));
        },
      );
    });
    return containers;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchPosts(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == 'success') {
          return Column(
            children: <Widget>[
              Center(
                  child: Text(
                "Instagram Feed",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              )),
              Padding(padding: EdgeInsets.symmetric(vertical: 15.0)),
              Center(
                child: SizedBox.fromSize(
                  size: Size.fromHeight(300),
                  child: GridView.count(
                    scrollDirection: Axis.horizontal,
                    crossAxisCount: 3,
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    children: _buildGridImages(posts.length, context),
                  ),
                ),
              )
            ],
          );
        } else {
          return Container(
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.purple,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            ),
            height: 200,
          );
        }
      },
    );
  }
}
