import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Utils.dart';

class FeedPage extends StatefulWidget {
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  MediaQueryData medQry = null;
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    Utils.bottomNavAction(index, context);
  }

  @override
  void initState() {
    super.initState();
    Utils.isNewResourceAdded();
    Utils.getAllFeedComments(setSt);
  }

  void setSt() {
    setState(() {});
  }

  List<Widget> getFeeds(QuerySnapshot snapshot) {
    List<Widget> result = List<Widget>.empty();

    snapshot.docs.forEach((document) {
      //result.add();
    });

    return result;
  }

  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);
    return WillPopScope(
        onWillPop: () async => false,
        child: SafeArea(
            child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Utils.userProfilePic(Utils.userId, 14),
              onPressed: () {
                Utils.showUserPop(context);
              },
            ),
            title: Text('Feed'),
          ),
          body: new StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('feed')
                .orderBy("created_time", descending: true)
                .limit(300)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return SizedBox(
                    child: new LinearProgressIndicator(), height: 5);
              return new ListView(
                children: snapshot.data.docs.map((document) {
                  if (document.id == null || document["ownername"] == null) {
                    return SizedBox();
                  } else {
                    return GestureDetector(
                        onTap: () => {
                              Navigator.pushNamed(context, "/feeddetails",
                                  arguments: document.id)
                            },
                        child: new Card(
                          child: new Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  document["feedtype"] == 1
                                      ? new Container(
                                          child: RichText(
                                            text: TextSpan(
                                              text: document["ownername"],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 16),
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: document["content"],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black)),
                                              ],
                                            ),
                                          ),
                                        )
                                      : new Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      5, 0, 0, 0),
                                                  child: Row(children: [
                                                    Utils.userProfilePic(
                                                        document["owner"], 12),
                                                    SizedBox(
                                                      width: 7,
                                                    ),
                                                    Text(document["ownername"],
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 18))
                                                  ])),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      5, 0, 0, 0),
                                                  child: Text(
                                                      Utils.getMessageTimerFrmt(
                                                          document[
                                                              "created_time"]),
                                                      style: TextStyle(
                                                          color: Colors.black45,
                                                          fontSize: 12))),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      5, 0, 0, 0),
                                                  child: Text(
                                                      document["content"],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 15,
                                                          color:
                                                              Colors.black))),
                                              document["attachments"].length > 0
                                                  ? new Container(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              0, 5, 0, 5),
                                                      height: 100,
                                                      width: medQry.size.width *
                                                          .88,
                                                      child: Utils
                                                          .attachmentPreviewSlider(
                                                              context,
                                                              document,
                                                              null))
                                                  : SizedBox()
                                            ],
                                          ),
                                        ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(children: [
                                    document["attachments"].length > 0
                                        ? Text(
                                            document["attachments"]
                                                    .length
                                                    .toString() +
                                                " Attachment",
                                            style: TextStyle(fontSize: 14),
                                          )
                                        : SizedBox(),
                                    Spacer(),
                                    Utils.feedCommentCount
                                            .containsKey(document.id)
                                        ? Text(
                                            Utils.feedCommentCount[document.id]
                                                    .toString() +
                                                " "
                                                    "Comment",
                                            style: TextStyle(fontSize: 14),
                                          )
                                        : SizedBox(),
                                  ]),
                                ],
                              )),
                        ));
                  }
                }).toList(),
              );
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: Utils.bottomNavItem(),
            currentIndex: _selectedIndex,
            backgroundColor: Colors.white,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            //unselectedLabelStyle: TextStyle(color: Colors.grey),
            onTap: _onItemTapped,
          ),
          floatingActionButton: new Visibility(
              visible: Utils.userRole == 1,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/feededitor");
                },
                child: Icon(Icons.add, color: Theme.of(context).primaryColor),
                backgroundColor: Theme.of(context).secondaryHeaderColor,
              )),
        )));
  }
}
