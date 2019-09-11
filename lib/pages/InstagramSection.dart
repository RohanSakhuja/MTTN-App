import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Post {
  String type;
  CachedNetworkImage thumbnail;
  CachedNetworkImage original;
  String link;

  Post({this.type, this.thumbnail, this.original, this.link});
}

enum SocialState { success, error, noInternet }

class InstagramFeed extends StatefulWidget {
  @override
  _InstagramFeedState createState() => _InstagramFeedState();
}

class _InstagramFeedState extends State<InstagramFeed>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Post> posts = new List();

  Future<SocialState> _fetchPosts() async {
    try {
      String uri =
          "https://api.instagram.com/v1/users/self/media/recent/?access_token=1605816208.94452f5.889dcc69bb6546cbac349d542d1b49ef";
      var response = await http.get(uri);
      var body = jsonDecode(response.body);

      posts.clear();
      for (var item in body['data']) {
        posts.add(new Post(
            thumbnail: CachedNetworkImage(
              imageUrl: item['images']['thumbnail']['url'],
              placeholder: (context, url) => new Container(),
              errorWidget: (context, url, error) => new Icon(Icons.error),
              fit: BoxFit.cover,
            ),
            original: CachedNetworkImage(
              imageUrl: item['images']['standard_resolution']['url'],
              placeholder: (context, url) => new CircularProgressIndicator(),
              errorWidget: (context, url, error) => new Icon(Icons.error),
              alignment: Alignment.center,
              fit: BoxFit.contain,
            ),
            type: item['type'],
            link: item['link']));
      }
      return SocialState.success;
    } on SocketException {
      return SocialState.noInternet;
    } catch (e) {
      // posts.add(new Post(
      //     thumbnail: CachedNetworkImage(
      //       imageUrl:
      //           'https://i.pinimg.com/originals/ca/0f/23/ca0f2340449cbba72890692026f10520.jpg',
      //       placeholder: (context, url) => new CircularProgressIndicator(),
      //       errorWidget: (context, url, error) => new Icon(Icons.error),
      //       fit: BoxFit.cover,
      //     ),
      //     original: CachedNetworkImage(
      //       imageUrl:
      //           'https://i.pinimg.com/originals/ca/0f/23/ca0f2340449cbba72890692026f10520.jpg',
      //       placeholder: (context, url) => new CircularProgressIndicator(),
      //       errorWidget: (context, url, error) => new Icon(Icons.error),
      //       alignment: Alignment.center,
      //       fit: BoxFit.contain,
      //     ),
      //     type: "efef",
      //     link: "eef"));
      return SocialState.error;
    }
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
    super.build(context);
    List<GestureDetector> containers =
        new List<GestureDetector>.generate(numberOfTiles, (int index) {
      return GestureDetector(
        child: Hero(
          child: new Container(
            child: posts[index].thumbnail,
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
                              child: posts[index].original,
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

  buildChild(context) {
    super.build(context);
    return FutureBuilder(
        future: _fetchPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == SocialState.success) {
              return Center(
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
              );
            } else {
              return Container(
                child: Center(
                  child: Text(
                    snapshot.data == SocialState.noInternet
                        ? "No Internet."
                        : "An unexpected error occured.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.purple,
                    ),
                  ),
                ),
                height: 100,
              );
            }
          } else {
            return Container(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
              ),
              height: 200,
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 10.0),
          width: MediaQuery.of(context).size.width * 0.915,
          child: Text(
            "Instagram",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 15.0)),
        Center(
          child: buildChild(context),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 15.0)),
      ],
    );
  }
}
