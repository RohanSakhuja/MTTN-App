import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:share/share.dart';
import 'dart:async';
import 'dart:convert';

class Post {
  final String id;
  final String link;
  final String title;
  final String content;
  final String excerpt;
  final String imageUrl;

  Post(this.id, this.link, this.title, this.content, this.excerpt, this.imageUrl);
}

// Have to fix the status codes thrown other than 200
Future<List<Post>> _getPosts(int index) async{
  final String postApi = 'http://manipalthetalk.org/wp-json/wp/v2/posts?page=$index';
  final response = await http.get(Uri.encodeFull(postApi));
  var jsonData = json.decode(response.body);
  List<Post> posts = [];
  for(var json in jsonData){
    Post post = Post(json['id'].toString(),json['link'],json['title']['rendered'],json['content']['rendered'],json['excerpt']['rendered'],json['better_featured_image']['source_url']);
    posts.add(post);
  }
  return posts;      
}

// Feed
class Feed extends StatefulWidget {
  @override
  FeedState createState() => new FeedState();
}
class FeedState extends State<Feed>{

  Widget _render(){
    return new ListView.builder(
          itemBuilder: (context, pageNumber){
            return KeepAliveFutureBuilder(
              intialData: Container(
                width: MediaQuery.of(context).size.height,
                height: MediaQuery.of(context).size.width,
              ),
              future: _getPosts(pageNumber+1),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.active:
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                  print("CircularProgressIndicator returned");
                  return SizedBox(
                  height: MediaQuery.of(context).size.height * 2,
                );
                  case ConnectionState.done:
                  if(snapshot.hasError){
                    print("ERROR: "+snapshot.error);
                    return Text("Error returned");                    
                  }else {
                    print(pageNumber);
                    var pageData = snapshot.data;
                    return ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: 10,
                      itemBuilder: (context, index){
                        return CreateCard(pageData[index].id ,pageData[index].title, pageData[index].imageUrl, pageData[index].excerpt, pageData[index].link, pageData[index].content);
                      },
                    );
                    }
                  }
                  }
              );
            },
          );
  }

  Future<Null> _refresh(){
    setState(() {});
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
      return new Scaffold(
        backgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
        body: new Container(
          child: new RefreshIndicator(child:_render(),
          onRefresh: _refresh,
          )
        ),
        appBar: AppBar(
          title: Text('Feed', textAlign: TextAlign.center,style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.75)),),
          backgroundColor: Colors.white,
          ),         
        );
        
    }
}

class CreateCard extends StatelessWidget{
  final String id;
  final String title;
  final String img;
  final String excerpt;
  final String link;
  final String content;

  CreateCard(this.id, this.title, this.img, this.excerpt, this.link, this.content);

  String _parseExcerpt(String htmlString){
    var document = parse(htmlString);
    String parsedString = parse(document.body.text).documentElement.text;
    return parsedString;
  }

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
                height: 240,
                width: 330,
                child: new ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: new Image.network(img, fit: BoxFit.fitWidth,),
                )
              ),
              new Padding(padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              child: new Text(_parseExcerpt(excerpt), softWrap: true,),),
            ],
          ),
          margin: const EdgeInsets.all(25.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          elevation: 10.0,
          ),
      );
    }
}

class ArticleState extends State<Article>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromRGBO(0, 0, 0, 0.75),),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new Text(widget.title, style: TextStyle(fontSize: 30.0, fontStyle: FontStyle.italic),textAlign: TextAlign.center,),
            new Html(
              data: widget.content,

            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 5.0,
        child: Icon(Icons.share, color: Colors.grey,),
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

class KeepAliveFutureBuilder extends StatefulWidget {

  final Future future;
  final AsyncWidgetBuilder builder;
  final intialData;
  KeepAliveFutureBuilder({
    this.future,
    this.intialData,
    this.builder
  });

  @override
  _KeepAliveFutureBuilderState createState() => _KeepAliveFutureBuilderState();
}

class _KeepAliveFutureBuilderState extends State<KeepAliveFutureBuilder> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.future,
      initialData: widget.intialData,
      builder: widget.builder,
    );
  }

  @override
  bool get wantKeepAlive => true;
}