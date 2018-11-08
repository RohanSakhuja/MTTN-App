import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

class Feed extends StatefulWidget {
  @override
  FeedState createState() => new FeedState();
}

Future<List<Post>> _getPosts(int index) async{
  final String postApi = 'http://manipalthetalk.org/wp-json/wp/v2/posts?page=${index}';
  final response = await http.get(Uri.encodeFull(postApi));
  if (response.statusCode == 200){
    var jsonData = json.decode(response.body);
    List<Post> posts = [];
    for(var json in jsonData){
      Post post = Post(json['id'].toString(),json['link'],json['title']['rendered'],json['content']['rendered'],json['excerpt']['rendered'],json['better_featured_image']['source_url']);
      posts.add(post);
    }
    return posts;      
  } else{
    throw Exception(response.statusCode);
  }
}

class FeedState extends State<Feed>{
  @override
  Widget build(BuildContext context) {
      return new Container(
        child: new ListView.builder(
          itemBuilder: (context, pageNumber){
            return FutureBuilder(
              future: _getPosts(1),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    return CircularProgressIndicator();
                  case ConnectionState.done:
                  if(snapshot.hasError){
                    return Text('ERROR: ${snapshot.error}');
                  } else {
                    var pageData = snapshot.data;
                    return ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: 10,
                      itemBuilder: (context, index){
                        return CreateCard(pageData[index].title, pageData[index].img, pageData[index].excerpt, pageData[index].link);
                      },
                    );
                  }
                }
              },
            );
          },
        ), 
        // FutureBuilder(
        //   future: _getPosts(_pageIndex),
        //   builder: (context, snapshot){
        //     if(snapshot.hasData && snapshot.data != null){
        //       return ListView.builder(
        //         itemBuilder: (context, i){
        //           int _postIndex = i%10;
        //           return CreateCard(snapshot.data[_postIndex].title, snapshot.data[_postIndex].imageUrl, snapshot.data[_postIndex].excerpt, snapshot.data[_postIndex].link);
        //         },
        //       );
        //     } else if(snapshot.hasError){
        //       return Center(
        //         child: Text('No Internet Connectivity')
        //       );
        //     } else{
        //       return Center(
        //         child: Text('Loading...')
        //       );
        //     }
        //   },
        // ),
      );
    }
}

class CreateCard extends StatelessWidget{
  final String title;
  final String img;
  final String excerpt;
  final String link;

  CreateCard(this.title, this.img, this.excerpt, this.link);

  @override
    Widget build(BuildContext context) {
      return new GestureDetector(
        onTap: (){
          print(link);  // code to navigate to article here
        },
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text(title, softWrap: true),
              new Image.network(img),
              new Text(excerpt, softWrap: true)

            ],
          ),
          margin: const EdgeInsets.all(25.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0)))
          ),
      );
    }
}