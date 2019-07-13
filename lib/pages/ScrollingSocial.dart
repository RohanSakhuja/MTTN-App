import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class Banner {
  String imageUri;
  String link;
  Banner({this.imageUri, this.link});
}

class BuildSocial extends StatefulWidget {
  @override
  _BuildSocialState createState() => _BuildSocialState();
}

class _BuildSocialState extends State<BuildSocial> {
  PageController controller = PageController(viewportFraction: 1.1);

  final List<Banner> banners = [
    new Banner(
        imageUri: 'assets/facebook.png',
        link: 'https://facebook.com/manipalthetalk/'),
    new Banner(
        imageUri: 'assets/instagram.png',
        link: 'https://www.instagram.com/manipalthetalk/'),
    new Banner(
        imageUri: 'assets/youtube.png',
        link: 'https://www.youtube.com/channel/UCwW9nPcEM2wGfsa06LTYlFg'),
    new Banner(
        imageUri: 'assets/freshers.png',
        link: 'https://www.facebook.com/groups/MITFreshers2019/'),
  ];

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: SizedBox.fromSize(
          size: Size.fromHeight(225.0),
          child: PageView.builder(
              controller: controller,
              itemCount: banners.length,
              itemBuilder: (BuildContext context, int index) {
                Padding padding = Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                  child: GestureDetector(
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        child: new Image.asset(
                          banners[index].imageUri,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    onTap: () {
                      _launchURL(banners[index].link);
                    },
                  ),
                );
                try {
                  Timer(
                      Duration(milliseconds: 3000),
                      () => controller.nextPage(
                          curve: Curves.easeIn,
                          duration: Duration(milliseconds: 500)));
                } on Error {}
                if (index == banners.length - 1)
                  Timer(
                      Duration(milliseconds: 3000),
                      () => controller.animateTo(0,
                          curve: Curves.ease,
                          duration: Duration(milliseconds: 1500)));
                return padding;
              }),
        ),
      ),
    );
  }
}
