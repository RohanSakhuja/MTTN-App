import 'package:flutter/material.dart';

class YouTubeFeed extends StatefulWidget {
  @override
  _YouTubeFeedState createState() => _YouTubeFeedState();
}

class _YouTubeFeedState extends State<YouTubeFeed> {
  List<Color> profileColor = [
    Colors.orange,
    Colors.indigoAccent,
    Colors.deepPurpleAccent,
    Colors.deepPurpleAccent,
    Colors.blueGrey,
    Colors.brown,
    Colors.limeAccent,
    Colors.tealAccent,
    Colors.amberAccent,
    Colors.indigo,
  ];

  List<String> videoName = [
    "Sample Video One",
    "Sample Video Two",
    "Sample Video Three",
    "Sample Video Four",
    "Sample Video five",
    "Sample Video six",
    "Sample Video seven",
    "Sample Video eight",
    "Sample Video nine",
    "Sample Video ten",
  ];

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Column(
      children: <Widget>[
        Center(
          child: Text(
            "YouTube Feed",
            style: TextStyle(
                color: Colors.black,
                fontSize: 25.0,
                fontWeight: FontWeight.bold),
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0)),
        Center(
          child: SizedBox.fromSize(
            size: Size.fromHeight(height * 0.3),
            child: ListView.builder(
              padding: EdgeInsets.only(left: 35.0),
              scrollDirection: Axis.horizontal,
              itemCount: videoName.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  child: SizedBox(
                    width: width * 0.75,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: width * 0.75,
                          height: width * 0.75 / 1.77,
                          margin: EdgeInsets.only(right: 5.0),
                          child: Card(color: profileColor[index]),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.0),
                        ),
                        Container(
                            padding: EdgeInsets.only(right: 20.0),
                            child: Center(
                              child: Text(
                                videoName[index],
                                style: TextStyle(fontSize: 20.0),
                                overflow: TextOverflow.clip,
                              ),
                            ))
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        )
      ],
    );
  }
}
