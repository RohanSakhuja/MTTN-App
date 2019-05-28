import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:wallpaper/wallpaper.dart';

class WallpaperPacks extends StatefulWidget {
  WallpaperPacksState createState() => new WallpaperPacksState();
}

class WallpaperPacksState extends State<WallpaperPacks> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('Wallpaper packs');
  bool _loaded = false;
  List<PackInfo> _packs = new List();

  @override
  void initState() {
    _getPacks();
    super.initState();
  }

  _parsePacks(var json) {
    _packs.clear();
    print(json);
    for (var item in json.keys) {
      _packs.add(new PackInfo(
          title: item,
          date: json[item]['date'],
          thumbnailUrl: json[item]['thumbnail'],
          originalUrl: json[item]['original'],
          imageCount: json[item]['image count']));
    }
    setState(() {});
  }

  _getPacks() async {
    return _databaseReference.onValue.listen((Event event) {
      _parsePacks(event.snapshot.value);
      setState(() {
        _loaded = true;
      });
    }, onError: (Object o) {
      print(o);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallpaper Packs'),
        centerTitle: true,
      ),
      body: (_packs.length == 0 && _loaded == true)
          ? Center(
              child: Text('No Packs Present'),
            )
          : (_loaded == true
              ? _renderList()
              : Center(
                  child: CircularProgressIndicator(),
                )),
    );
  }

  _renderList() {
    return ListView.builder(
      itemCount: _packs.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_packs[index].title),
          onTap: () {
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new Pack(_packs[index])));
          },
        );
      },
    );
  }
}

class PackInfo {
  String title;
  String date;
  String thumbnailUrl;
  String originalUrl;
  int imageCount;

  PackInfo(
      {this.title,
      this.date,
      this.thumbnailUrl,
      this.originalUrl,
      this.imageCount});
}

class ImageData {
  String thumbnailUrl;
  String originalUrl;

  ImageData({this.thumbnailUrl, this.originalUrl});
}

class Pack extends StatefulWidget {
  final PackInfo _pack;
  Pack(this._pack);
  @override
  PackState createState() => new PackState();
}

class PackState extends State<Pack> {
  static const platform = const MethodChannel('wallpaper');
  final StorageReference _storageReference = FirebaseStorage.instance.ref();
  List<ImageData> _images = new List();

  @override
  void initState() {
    _loadWallpapers();
    super.initState();
  }

  _loadWallpapers() async {
    _images.clear();
    for (int i = 1; i <= widget._pack.imageCount; i++) {
      _getDownloadUrls(i);
    }
  }

  _getDownloadUrls(int i) async {
    String thum, orig;
    String packName = widget._pack.title;
    thum = await _storageReference
        .child('Wallpaper packs')
        .child('$packName')
        .child('thumbnail')
        .child('$i' + '_thumbnail.jpg')
        .getDownloadURL();
    orig = await _storageReference
        .child('Wallpaper packs')
        .child('$packName')
        .child('original')
        .child('$i' + '_original.jpg')
        .getDownloadURL();
    _images.add(new ImageData(originalUrl: orig, thumbnailUrl: thum));
    setState(() {});
  }

  _setWallpaper(String _url) async {
    try {
      String res = await Wallpaper.homeScreen(_url);
      print('result: '+res);
    } catch (e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._pack.title),
        centerTitle: true,
      ),
      body: _images.length != widget._pack.imageCount
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GridView.count(
              crossAxisCount: 2,
              scrollDirection: Axis.vertical,
              addAutomaticKeepAlives: true,
              children: List<Widget>.generate(widget._pack.imageCount, (index) {
                return GestureDetector(
                  child: Image.network(
                    _images[index].thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                  onTap: () {
                    print('gesture detected');
                    _setWallpaper(_images[index].originalUrl);
                  },
                );
              }),
            ),
    );
  }
}
