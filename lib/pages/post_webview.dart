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

  Post(this.id, this.link, this.title, this.content, this.excerpt, this.imageUrl, this.date);
}

// Feed
class Feed extends StatefulWidget {
  @override
  FeedState createState() => new FeedState();
}
class FeedState extends State<Feed> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  final timeout = const Duration(seconds: 15);

  handleTimeout(){

  }

  List<Post> articles = [];

  ScrollController _scrollController = new ScrollController();
  bool isPerformingRequest = false;
  bool isFabActive = false;
  @override
  void initState(){
    super.initState();
    _scrollController.addListener((){
      if(_scrollController.position.pixels > 100){
        setState(() => isFabActive = true);
      } else{
        setState(() => isFabActive=false);
      }
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        _getData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _getData() async{
    try{
      if(!isPerformingRequest){
        setState(() => isPerformingRequest = true);
        List<Post> newData = await _getPosts((articles.length/10).round()+1);
        setState(() {
              articles.addAll(newData);
              isPerformingRequest = false;
            });
      }
    }on NoSuchMethodError catch(e){
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
            backgroundColor: Colors.black,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),
      ),
    );
  }

  Future<Null> _refresh(){
    bool _needRefresh = true;
    Completer<Null> completer = new Completer<Null>();
    (_getPosts(1)).then((List<Post> newData){
      completer.complete();
      if(newData[0].id != articles[0].id){
        _needRefresh = true;
      } else{
        _needRefresh = false;
      }
    });
    if(_needRefresh){
      setState(() {});
    }
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
      return new Scaffold(
        backgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
        floatingActionButton: isFabActive?FloatingActionButton(
          child: Icon(Icons.arrow_upward),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          onPressed: (){
            _scrollController.animateTo(0, duration: new Duration(seconds: 1), curve: Curves.ease);
          },
        ):null,
        body: new Container(
          child: new RefreshIndicator(
            color: Colors.black,
            child: articles.length == 0?
            FutureBuilder(
              future: _getData(),
              builder: (context, snapshot){
                if(articles.length == 0){
                  return _buildProgressIndicator();
                }
              },):
            ListView.builder(
              addAutomaticKeepAlives: true,
              itemCount: articles.length,
              controller: _scrollController,
              itemBuilder: (context, index){
                if(articles.length == index){
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
          )
        ),
        appBar: AppBar(
          title: Text('MTTN', textAlign: TextAlign.center,style: TextStyle(color: Colors.black,)),
          backgroundColor: Colors.white,
          ),
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
  Future<List<Post>> _getPosts(int index) async{
    try{
      final String postApi = 'http://manipalthetalk.org/wp-json/wp/v2/posts?page=$index';
      final response = await http.get(Uri.encodeFull(postApi));
      if(response.statusCode == 200){
        var jsonData = json.decode(response.body);
        List<Post> posts = [];
        for(var json in jsonData){
          Post post = Post(json['id'].toString(),json['link'],parseTitle(json['title']['rendered']),json['content']['rendered'],json['excerpt']['rendered'],json['better_featured_image']['source_url'], json['date']);
          posts.add(post);
        }
        return posts;
      } else{
        _showDialog("Server Down", "Please try again in some time.");
      }
    }on SocketException catch(e){
      print(e);
      _showDialog("No Internet", "Please check your internet connection and try again!");
    }
  }

  String parseTitle(String title){
    String raw = parse(title).outerHtml;
    int start = raw.indexOf("<body>")+6;
    int last = raw.indexOf("</body>");
    return raw.substring(start, last);
  }
}

class CreateCard extends StatelessWidget{
  final String id;
  final String title;
  final String img;
  final String excerpt;
  final String link;
  final String content;
  final String date;

  CreateCard({this.id, this.title, this.img, this.excerpt, this.link, this.content, this.date});
  
  @override
    Widget build(BuildContext context) {

      return new GestureDetector(
        onTap: (){
          print(link);
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => Article(title: title,content: content,link: link,)));
        },
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
              child: new Text(title, softWrap: true, style: TextStyle(fontSize: 20.0, fontStyle: FontStyle.italic),textAlign: TextAlign.center,),),
              new Container(
                padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                height: 200,
                width: 360,
                child: new ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CachedNetworkImage(
                    imageUrl: img,
                    fit: BoxFit.cover,
                  ),
                  // new Image.network(img, fit: BoxFit.fitWidth,),
                )
              ),
              new Padding(padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              child: new Text(date.substring(0,10), softWrap: true,style: TextStyle(fontSize: 15.0),),
              ),
            ],
          ),
          margin: const EdgeInsets.all(25.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
          elevation: 5.0,
          ),
      );
    }
}

class ArticleState extends State<Article>{

  double _size = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          PopupMenuButton(
            offset: Offset(20.0, 50.0),
            icon: Icon(Icons.format_size, color: Colors.black,),
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: Icon(Icons.add),
              )
            ],
          ),
          // IconButton(
          //   icon: Icon(Icons.format_size, color: Colors.black,),
          //   onPressed: (){
          //     setState(() {
          //       _size = 15.0;
          //     });
          //   },
          // )
        ],
        backgroundColor: Colors.white,
        ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new Text(widget.title, style: TextStyle(fontSize: 30.0, fontStyle: FontStyle.italic),textAlign: TextAlign.center,),
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
        child: Icon(Icons.share, color: Colors.black,),
        backgroundColor: Colors.white,
        onPressed: (){
          Share.share("Check out this post by MTTN\n${widget.link}");
        },
      ),
    );
  }
}
class Article extends StatefulWidget{
  final String content;
  final String title;
  final String link;
  Article({this.title, this.content, this.link});
  ArticleState createState() => ArticleState();
}