import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class YouTubeItem {
  String type;
  String title;
  String itemId;
  String description;
  String thumbnail;
  String link;

  YouTubeItem(
      {this.type,
      this.title,
      this.itemId,
      this.description,
      this.thumbnail,
      this.link});
}

enum SocialState { success, error, noInternet }

class YouTubeFeed extends StatefulWidget {
  @override
  _YouTubeFeedState createState() => _YouTubeFeedState();
}

List<YouTubeItem> items = new List();

String parseTitle(String title) {
  String raw = parse(title).outerHtml;
  int start = raw.indexOf("<body>") + 6;
  int last = raw.indexOf("</body>");
  return raw.substring(start, last);
}

class _YouTubeFeedState extends State<YouTubeFeed>
    with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;

  Future<SocialState> _fetchItems() async {
    try {
      String uri =
          "https://www.googleapis.com/youtube/v3/search?key=AIzaSyDMzJvdj7xH40CMVnoW6kZPgVpXhn93aA8&channelId=UCwW9nPcEM2wGfsa06LTYlFg&part=snippet,id&order=date&maxResults=50";
      var response = await http.get(uri);
      var body = jsonDecode(response.body);

      for (var item in body['items']) {
        String temp = item['id']['kind'].substring(8);
        String id = (temp == 'video')
            ? item['id']['videoId']
            : item['id']['playlistId'];
        String link = (temp == 'video')
            ? 'https://www.youtube.com/watch?v=$id'
            : 'https://www.youtube.com/watch?v=I5y-v_QDmwg&list=$id';
        items.add(new YouTubeItem(
            type: temp,
            title: parseTitle(item['snippet']['title']),
            itemId: id,
            description: item['snippet']['description'],
            thumbnail: item['snippet']['thumbnails']['medium']['url'],
            link: link));
      }
    } on SocketException {
      return SocialState.noInternet;
    } catch (e) {
      print(e);
      return SocialState.error;
    }
    return SocialState.success;
  }

  _launchUrl(url) async =>
      (await canLaunch(url)) ? await launch(url) : throw 'Could not lauch $url';

  Widget build(BuildContext context) {
    super.build(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return FutureBuilder<SocialState>(
      future: _fetchItems(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                width: MediaQuery.of(context).size.width * 0.915,
                child: Text(
                  "YouTube",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
                ),
              ),
              snapshot.data != SocialState.success
                  ? Container(
                      height: 100,
                      child: Center(
                        child: Text(
                          snapshot.data == SocialState.noInternet
                              ? "No Internet."
                              : "An unexpected error occured.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: SizedBox.fromSize(
                        size: Size.fromHeight(height * 0.3),
                        child: ListView.builder(
                          padding: EdgeInsets.only(left: 15.0),
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              width: width * 0.68,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(right: 10.0),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0)),
                                        child: GestureDetector(
                                            onTap: () =>
                                                _launchUrl(items[index].link),
                                            child: CachedNetworkImage(
                                                imageUrl:
                                                    items[index].thumbnail,
                                                fit: BoxFit.fill))),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 5.0),
                                  ),
                                  Flexible(
                                    child: Container(
                                        alignment: Alignment.topCenter,
                                        padding: EdgeInsets.only(right: 20.0),
                                        child: Text(
                                          items[index].type == 'playlist'
                                              ? 'Playlist: ' +
                                                  items[index].title
                                              : items[index].title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subhead,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        )),
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
        } else {
          return Container(
            height: height * 0.2,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
          );
        }
      },
    );
  }
}
