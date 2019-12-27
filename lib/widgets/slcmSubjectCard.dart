import 'package:flutter/material.dart';
import 'package:flutter_parallax/flutter_parallax.dart';
import 'package:mttn_app/utils/CachedImages.dart';
import 'package:mttn_app/utils/subjectModals.dart';
import 'package:percent_indicator/percent_indicator.dart';

class SLCMSubjectCard extends StatefulWidget {
  final String subName;
  final String subClasses;
  final String subPresent;
  final String subAbsent;
  final String subPercentage;
  final BuildContext context;
  final int index;
  final List<SubjectMarks> marks;

  SLCMSubjectCard(this.subName, this.subClasses, this.subPresent,
      this.subAbsent, this.subPercentage, this.context, this.index, this.marks);

  @override
  SLCMSubjectCardState createState() => new SLCMSubjectCardState();
}

class SLCMSubjectCardState extends State<SLCMSubjectCard> {
  CachedImg camm = new CachedImg();

  @override
  Widget build(BuildContext context) {
    SubjectMarks subMarks;
    bool hasMarks = false;

    for (var i in widget.marks) {
      if (i.name == widget.subName) {
        subMarks = i;
      }
    }

    var marksObtained = _getMarks(subMarks, "obtained");
    var marksMax = _getMarks(subMarks, "max");

    bool nullMarks = false;

    if (marksObtained == -1 || marksMax == -1) {
      nullMarks = true;
      hasMarks = false;
    } else {
      try {
        hasMarks = (marksMax > 0) ? true : false;
      } catch (e) {}
    }
    // print(hasMarks);

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      child: GestureDetector(
        onTap: () {
          if (hasMarks)
            showSubjectMarks(widget.subName, widget.index, subMarks);
        },
        child: Stack(
          children: <Widget>[
            Container(
                height: 395.0,
                child: Parallax.inside(
                  mainAxisExtent: 200.0,
                  child: camm.images[widget.index],
                )),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 110.0,
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(3.0, 10.0, 3.0, 0.0),
                    child: Text(
                      widget.subName,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          child: Center(
                              child: CircularPercentIndicator(
                            radius: 110.0,
                            animation: true,
                            animationDuration: 100,
                            lineWidth: 7.0,
                            percent: double.parse(widget.subPercentage
                                    .substring(
                                        0, widget.subPercentage.length - 1)) /
                                100,
                            center: Text(
                                widget.subPercentage.substring(
                                    0, widget.subPercentage.length - 3),
                                style: TextStyle(
                                    fontSize: 45.0,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white)),
                            progressColor: Colors.white,
                            circularStrokeCap: CircularStrokeCap.round,
                            backgroundColor: Colors.white10,
                          )),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 1.0),
                          alignment: Alignment.center,
                          child: double.parse(widget.subPercentage) <= 76
                              ? Icon(
                                  Icons.warning,
                                  size: 12.0,
                                  color: Colors.redAccent.withOpacity(0.7),
                                )
                              : Container(),
                        ),
                        Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(left: 4.0),
                            child: double.parse(widget.subPercentage) <= 76
                                ? Text(
                                    "low attendance",
                                    style: TextStyle(
                                      color: Colors.redAccent.withOpacity(0.7),
                                    ),
                                  )
                                : Container())
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "Total",
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                            ),
                            Text(
                              widget.subClasses,
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "Attended",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                            ),
                            Text(
                              widget.subPresent,
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "Missed",
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                            ),
                            Text(
                              widget.subAbsent,
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(24.0),
                    color: Colors.white70,
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 1,
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 0.0),
                    child: !(nullMarks || !hasMarks)
                        ? RichText(
                            text: TextSpan(
                                style: Theme.of(context).textTheme.body1,
                                children: [
                                  TextSpan(
                                      text: marksObtained.toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 32.0)),
                                  TextSpan(
                                      text: " / ",
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16.0)),
                                  TextSpan(
                                      text: marksMax.toString(),
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16.0)),
                                ]),
                          )
                        : Container(),
                  ),
                  Container(
                    child: Text(
                        (hasMarks)
                            ? "tap for more"
                            : ((nullMarks)
                                ? "seems like we had some trouble fetching your marks."
                                : "no marks uploaded"),
                        style:
                            TextStyle(color: Colors.white54, fontSize: 12.0)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getMarks(SubjectMarks marks, String type) {
    try {
      if (type == "obtained") {
        double sum = 0;

        for (Marks temp in marks.assignments)
          sum += double.parse(temp.obtained);

        for (Marks temp in marks.sessionals) sum += double.parse(temp.obtained);

        for (Marks temp in marks.otherMarks) sum += double.parse(temp.obtained);

        return sum;
      } else {
        double sum = 0;

        for (Marks temp in marks.assignments) sum += double.parse(temp.total);

        for (Marks temp in marks.sessionals) sum += double.parse(temp.total);

        for (Marks temp in marks.otherMarks) sum += double.parse(temp.total);

        return sum;
      }
    } catch (e) {
      print(e);
      return -1;
    }
  }

  showSubjectMarks(name, index, SubjectMarks subjectMarks) {
    CachedImg camm = new CachedImg();

    SubjectMarks tempMarks = subjectMarks;
    List<Marks> mainMarks = [];
    mainMarks.addAll(tempMarks.assignments);
    mainMarks.addAll(tempMarks.sessionals);
    mainMarks.addAll(tempMarks.otherMarks);

    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        context: context,
        builder: (builder) {
          return Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                child: Container(
                  height: 350.0,
                  width: MediaQuery.of(context).size.width,
                  child: camm.images[widget.index],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                child: Container(
                    height: 350.0,
                    padding: EdgeInsets.all(18.0),
                    color: Colors.black.withOpacity(0.3),
                    child: Column(
                      children: <Widget>[
                        Container(
                            alignment: Alignment.center,
                            child: Text(
                              name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 28.0),
                            )),
                        Container(
                          height: 240,
                          padding: EdgeInsets.only(top: 16.0),
                          child: ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            itemCount: mainMarks.length,
                            itemBuilder: (context, ind) {
                              return Container(
                                padding: EdgeInsets.all(2.0),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          width: 180,
                                          child: Text(
                                            mainMarks[ind].name,
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 16.0),
                                          ),
                                        ),
                                        Text(
                                          "${mainMarks[ind].obtained} / ${mainMarks[ind].total}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24.0),
                                        )
                                      ],
                                    ),
                                    (ind + 1 < mainMarks.length &&
                                            mainMarks[ind + 1]
                                                .name
                                                .contains('Sessional 1'))
                                        ? Container(
                                            margin: EdgeInsets.all(20.0),
                                            color:
                                                Colors.white.withOpacity(1.0),
                                            height: 0.5,
                                            width: 300.0,
                                          )
                                        : Container()
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    )),
              ),
            ],
          );
        });
  }
}
