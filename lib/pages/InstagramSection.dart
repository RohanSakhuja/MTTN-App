import 'package:flutter/material.dart';

class InstagramFeed extends StatefulWidget {
  @override
  _InstagramFeedState createState() => _InstagramFeedState();
}

class _InstagramFeedState extends State<InstagramFeed> {

  final List<String> images = List.generate(25, (index) => 'https://pbs.twimg.com/profile_images/640666088271839233/OTKlt5pC_400x400.jpg');


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(
          child: Text(
            "Instagram Feed",
            style: TextStyle(
              color: Colors.black,
              fontSize: 25.0,
              fontWeight: FontWeight.bold
            ),)
        ),
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
              children: _buildGridImages(images.length,context),
              ),
          ),
        )
      ],
    );
  }

  List<Widget> _buildGridImages(numberOfTiles,context){
      List<GestureDetector> containers = new List<GestureDetector>.generate(numberOfTiles, 
      (int index){
        return GestureDetector(
            child: Hero(
                child: new Container(
                  child: new Image.network(
                    images[index],
                    fit: BoxFit.cover,
                ),
              ),
              tag: index,
            ),
            onTap: (){
                Navigator.of(context).push(new PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (BuildContext context, _, __){
                    return new Material(
                      color: Colors.black54,
                      child: new Container(
                        child: Center(
                          child: new InkWell(
                            child: new Hero(
                              child: new Image.network(
                                images[index],
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                                width: 400.0,
                                height: 400.0,
                              ),
                              tag: index,
                            ),
                            onTap: (){Navigator.pop(context);},
                          ),
                        ),
                      ),
                    );
                  }
                ));
            },
          );
      });
      return containers;
    }
}