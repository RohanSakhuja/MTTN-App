import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedImg {
  final images = [
    CachedNetworkImage(
      imageUrl:
          "https://i.pinimg.com/originals/ca/0f/23/ca0f2340449cbba72890692026f10520.jpg",
      placeholder: (context, url) => Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 50.0),
          child: new CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error),
      fit: BoxFit.fitWidth,
      color: Colors.black.withOpacity(0.7),
      colorBlendMode: BlendMode.darken,
    ),
    CachedNetworkImage(
      imageUrl:
          "https://cdnb.artstation.com/p/assets/images/images/001/566/865/large/wilson-stark-sc-3-2.jpg?1448681613",
      placeholder: (context, url) => Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 50.0),
          child: new CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error),
      fit: BoxFit.fitWidth,
      color: Colors.black.withOpacity(0.7),
      colorBlendMode: BlendMode.darken,
    ),
    CachedNetworkImage(
      imageUrl:
          "https://i.pinimg.com/originals/c8/42/c2/c842c2bc09ce9e821d6bbb78758f6526.jpg",
      placeholder: (context, url) => Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 50.0),
          child: new CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error),
      fit: BoxFit.fitWidth,
      color: Colors.black.withOpacity(0.7),
      colorBlendMode: BlendMode.darken,
    ),
    CachedNetworkImage(
      imageUrl:
          "https://i.pinimg.com/originals/27/cb/5e/27cb5e2ce29518fa59e802e9b2cc761c.jpg",
      placeholder: (context, url) => Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 50.0),
          child: new CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error),
      fit: BoxFit.fitWidth,
      color: Colors.black.withOpacity(0.7),
      colorBlendMode: BlendMode.darken,
    ),
    CachedNetworkImage(
      imageUrl:
          "https://i.pinimg.com/originals/18/26/f5/1826f56435d9dc43e1bd191644bdc650.jpg",
      placeholder: (context, url) => Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 50.0),
          child: new CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error),
      fit: BoxFit.fitWidth,
      color: Colors.black.withOpacity(0.7),
      colorBlendMode: BlendMode.darken,
    ),
    CachedNetworkImage(
      imageUrl:
          "http://www.davidebonazzi.com/uploads/1/7/8/2/17822545/7711679_orig.jpg",
      placeholder: (context, url) => Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 50.0),
          child: new CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error),
      fit: BoxFit.fitWidth,
      color: Colors.black.withOpacity(0.7),
      colorBlendMode: BlendMode.darken,
    ),
    CachedNetworkImage(
      imageUrl:
          "https://i.pinimg.com/originals/99/c1/95/99c1956cf50bca85c57c14bfe3b2681b.jpg",
      placeholder: (context, url) => Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 50.0),
          child: new CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error),
      fit: BoxFit.fitWidth,
      color: Colors.black.withOpacity(0.7),
      colorBlendMode: BlendMode.darken,
    ),
    CachedNetworkImage(
      imageUrl:
          "https://i.pinimg.com/originals/73/82/68/73826822b3ff6f99951bcae63f180b33.jpg",
      placeholder: (context, url) => Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 50.0),
          child: new CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error),
      fit: BoxFit.fitWidth,
      color: Colors.black.withOpacity(0.7),
      colorBlendMode: BlendMode.darken,
    ),
    CachedNetworkImage(
      imageUrl:
          "https://i.pinimg.com/originals/18/26/f5/1826f56435d9dc43e1bd191644bdc650.jpg",
      placeholder: (context, url) => Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 50.0),
          child: new CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error),
      fit: BoxFit.fitWidth,
      color: Colors.black.withOpacity(0.7),
      colorBlendMode: BlendMode.darken,
    ),
    CachedNetworkImage(
      imageUrl:
          "https://i.pinimg.com/originals/18/26/f5/1826f56435d9dc43e1bd191644bdc650.jpg",
      placeholder: (context, url) => Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 50.0),
          child: new CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error),
      fit: BoxFit.fitWidth,
      color: Colors.black.withOpacity(0.7),
      colorBlendMode: BlendMode.darken,
    ),
    CachedNetworkImage(
      imageUrl:
          "https://i.pinimg.com/originals/ca/0f/23/ca0f2340449cbba72890692026f10520.jpg",
      placeholder: (context, url) => Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 50.0),
          child: new CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error),
      fit: BoxFit.fitWidth,
      color: Colors.black.withOpacity(0.7),
      colorBlendMode: BlendMode.darken,
    ),
    CachedNetworkImage(
      imageUrl:
          "https://cdnb.artstation.com/p/assets/images/images/001/566/865/large/wilson-stark-sc-3-2.jpg?1448681613",
      placeholder: (context, url) => Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 50.0),
          child: new CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error),
      fit: BoxFit.fitWidth,
      color: Colors.black.withOpacity(0.7),
      colorBlendMode: BlendMode.darken,
    ),
    CachedNetworkImage(
      imageUrl:
          "https://i.pinimg.com/originals/c8/42/c2/c842c2bc09ce9e821d6bbb78758f6526.jpg",
      placeholder: (context, url) => Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 50.0),
          child: new CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error),
      fit: BoxFit.fitWidth,
      color: Colors.black.withOpacity(0.7),
      colorBlendMode: BlendMode.darken,
    ),
    CachedNetworkImage(
      imageUrl:
          "https://i.pinimg.com/originals/27/cb/5e/27cb5e2ce29518fa59e802e9b2cc761c.jpg",
      placeholder: (context, url) => Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 50.0),
          child: new CircularProgressIndicator()),
      errorWidget: (context, url, error) => new Icon(Icons.error),
      fit: BoxFit.fitWidth,
      color: Colors.black.withOpacity(0.7),
      colorBlendMode: BlendMode.darken,
    ),
  ];
}
