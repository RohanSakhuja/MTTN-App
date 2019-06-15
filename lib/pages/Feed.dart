import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:share/share.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Post {
  final String id;
  final String link;
  final String title;
  final String content;
  final String excerpt;
  final String imageUrl;
  final String date;

  Post(this.id, this.link, this.title, this.content, this.excerpt,
      this.imageUrl, this.date);
}

// Feed
class Feed extends StatefulWidget {
  @override
  FeedState createState() => new FeedState();
}

class FeedState extends State<Feed> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final timeout = const Duration(minutes: 10);

  handleTimeout() {}

  List<Post> articles = [];

  ScrollController _scrollController = new ScrollController();
  bool isPerformingRequest = false;
  bool isFabActive = false;
  @override
  void initState() {
    super.initState();
     _scrollController.addListener(() {
      if (_scrollController.position.pixels > 100) {
        setState(() => isFabActive = true);
      } else {
        setState(() => isFabActive = false);
      }
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _getData() async {
    try {
      if (!isPerformingRequest) {
        setState(() => isPerformingRequest = true);
        List<Post> newData =
            await _getPosts((articles.length / 10).round() + 1);
            imageCache.clear();
        setState(() {
          articles.addAll(newData);
          isPerformingRequest = false;
        });
      }
    } on NoSuchMethodError catch (e) {
      print(e);
    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isPerformingRequest ? 1.0 : 0.0,
          child: new CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),
      ),
    );
  }

  Future<Null> _refresh() {
    bool _needRefresh = true;
    Completer<Null> completer = new Completer<Null>();
    (_getPosts(1)).then((List<Post> newData) {
      completer.complete();
      if (newData[0].id != articles[0].id) {
        _needRefresh = true;
      } else {
        _needRefresh = false;
      }
    });
    if (_needRefresh) {
      setState(() {});
    }
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Scaffold(
      floatingActionButton: isFabActive
          ? FloatingActionButton(
              child: Icon(Icons.arrow_upward),
             foregroundColor: Colors.white,
              backgroundColor: Color.fromRGBO(0, 206, 209, 1.0),
              onPressed: () {
                _scrollController.animateTo(0,
                    duration: new Duration(seconds: 1), curve: Curves.ease);
              },
            )
          : null,
      body: new Container(
          padding: EdgeInsets.fromLTRB(11.0, 10.0, 11.0, 0.0),
          child: articles.length == 0
              ? FutureBuilder(
                  future: _getData(),
                  builder: (context, snapshot) {
                    if (articles.length == 0) {
                      return _buildProgressIndicator();
                    }
                  },
                )
              : new RefreshIndicator(
                  child: ListView.builder(
                    controller: _scrollController,
                    cacheExtent: 0.1,
                    padding: EdgeInsets.all(0.0),
                    addAutomaticKeepAlives: true,
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      if (articles.length == index) {
                        return _buildProgressIndicator();
                      } else {
                        return CreateCard(
                          id: articles[index].id,
                          title: articles[index].title,
                          img: articles[index].imageUrl,
                          excerpt: articles[index].excerpt,
                          link: articles[index].link,
                          content: articles[index].content,
                          date: articles[index].date,
                        );
                      }
                    },
                  ),
                  onRefresh: _refresh,
                )),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(content),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Have to fix the status codes thrown other than 200
  Future<List<Post>> _getPosts(int index) async {
    List<Post> posts = [];

    try {
      final String postApi =
          'http://manipalthetalk.org/wp-json/wp/v2/posts?page=$index';
      final response = await http.get(Uri.encodeFull(postApi));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        for (var json in jsonData) {
          String img;
          try {
            img = (jsonEncode(json['better_featured_image']['media_details']
                            ['sizes'])
                        .indexOf('medium_large') !=
                    -1)
                ? json['better_featured_image']['media_details']['sizes']
                    ['medium_large']['source_url']
                : ((jsonEncode(json['better_featured_image']['media_details']
                                ['sizes'])
                            .indexOf('medium') !=
                        -1)
                    ? json['better_featured_image']['media_details']['sizes']
                        ['medium']['source_url']
                    : json['better_featured_image']['source_url']);
          } // when no image in available
          catch (e) {
            img =
                'https://i.pinimg.com/originals/ca/0f/23/ca0f2340449cbba72890692026f10520.jpg';
          }
          Post post = Post(
              json['id'].toString(),
              json['link'],
              parseTitle(json['title']['rendered']),
              json['content']['rendered'],
              json['excerpt']['rendered'],
              img,
              json['date']);
          posts.add(post);
        }
      } else {
        _showDialog("Server Down", "Please try again in some time.");
      }
    } on SocketException catch (e) {
      print(e);
      _showDialog("No Internet",
          "Please check your internet connection and try again!");
    }
    return posts;
  }

  String parseTitle(String title) {
    String raw = parse(title).outerHtml;
    int start = raw.indexOf("<body>") + 6;
    int last = raw.indexOf("</body>");
    return raw.substring(start, last);
  }
}

class CreateCard extends StatelessWidget {
  final String id;
  final String title;
  final String img;
  final String excerpt;
  final String link;
  final String content;
  final String date;

  CreateCard({
    this.id,
    this.title,
    this.img,
    this.excerpt,
    this.link,
    this.content,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
return new GestureDetector(
      onTap: () {
        print(link);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Article(
                      title: title,
                      content: content,
                      link: link,
                    )));
      },
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            margin: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.transparent,
                image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: NetworkImage(
                      img,
                    )
                )),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            margin: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
                gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    stops: [
                      0.0,
                      1.0
                    ])),
          ),
          Material(
            type: MaterialType.transparency,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.25,
              margin: EdgeInsets.all(12.0),
              child: InkWell(
                onTap: () {
                  print(link);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Article(
                                title: title,
                                content: content,
                                link: link,
                              )));
                },
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.06,
            //color: Colors.red.withOpacity(0.3),
            margin: EdgeInsets.fromLTRB(
                20.0, MediaQuery.of(context).size.height * 0.205, 20.0, 0.0),
            child: Center(
              child: Text(
                title.length > 60 ? title.substring(0, 60) + '...' : title,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.027,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    //fontStyle: FontStyle.italic,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ArticleState extends State<Article> {
  double _size = 15.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          PopupMenuButton(
            offset: Offset(20.0, 50.0),
            icon: Icon(
              Icons.format_size,
            ),
            itemBuilder: (context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    child: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (_size < 30) {
                          setState(() {
                            _size += 2.0;
                          });
                        }
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: IconButton(
                      icon: Icon(Icons.minimize),
                      onPressed: () {
                        if (_size > 8) {
                          setState(() {
                            _size -= 2.0;
                          });
                        }
                      },
                    ),
                  )
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new Text(
              widget.title,
              style: TextStyle(fontSize: 30.0, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            Html(
              data: widget.content,
              padding: EdgeInsets.fromLTRB(20.0, 20.0, 10.0, 20.0),
              defaultTextStyle: TextStyle(fontSize: _size),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 5.0,
        child: Icon(
          Icons.share,
        ),
        // backgroundColor: colorMain,
        onPressed: () {
          Share.share("Check out this post by MTTN\n${widget.link}");
        },
      ),
    );
  }
}

class Article extends StatefulWidget {
  final String content;
  final String title;
  final String link;
  Article({this.title, this.content, this.link});
  ArticleState createState() => ArticleState();
}

class Person{
  final String gender;
  final String name;
  final int age;
  final bool isEarning;
  final double salary;

  Person({this.gender,this.name,this.age,this.isEarning,this.salary});
}