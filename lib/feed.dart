import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'Utils.dart';

class FeedPage extends StatefulWidget {
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  MediaQueryData medQry = null;
  int _selectedIndex = 1;
  void _onItemTapped(int index) {
    Utils.bottomNavAction(index, context);
  }

  @override
  void initState() {
    super.initState();
  }

  Widget feedItem(DocumentSnapshot feedDoc, BuildContext context) {
    return new GestureDetector(
        child: Card(
            elevation: 1,
            child: new Container(
              height: 125,
              child: new Padding(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 0, left: 8, right: 8),
                  child: new Column(children: [
                    Row(children: [
                      SizedBox(
                        width: 22,
                        child: Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(
                        width: medQry.size.width * .64,
                        child: Text(feedDoc["ownername"],
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style:
                                TextStyle(fontSize: 19, color: Colors.black)),
                      ),
                      SizedBox(
                        width: medQry.size.width * .19,
                        child: Text(
                          Utils.getTimeFrmt(feedDoc["created_time"]),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ]),
                    SizedBox(height: medQry.size.height * .01),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 15),
                        SizedBox(
                          width: medQry.size.width * .89,
                          child: Text(
                            feedDoc["subject"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style:
                                TextStyle(fontSize: 15, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(width: 15),
                        Text(
                          "Comments :",
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(Utils.threadCount.containsKey(feedDoc.documentID)
                            ? "  " +
                                Utils.threadCount[feedDoc.documentID].toString()
                            : "  0"),
                        SizedBox(width: 10),
                        Text(
                          "Attachment :",
                          style: TextStyle(fontSize: 14),
                        ),
                        Text((feedDoc["attachments"].length > 0)
                            ? "  " + feedDoc["attachments"].length.toString()
                            : "  0"),
                      ],
                    )
                  ])),
            )),
        onTap: () {
          Navigator.pushNamed(context, "/messageview",
              arguments: feedDoc.documentID);
        });
  }

  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Utils.showUserPop(context);
              },
            ),
            title: Text('Feed'),
          ),
          body: new StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('feed')
                .orderBy("created_time", descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return SizedBox(
                    child: new LinearProgressIndicator(), height: 5);
              return new ListView(
                children: snapshot.data.documents.map((document) {
                  return new Card(
                      child: new Padding(
                    padding: EdgeInsets.all(10),
                    child: new Flexible(
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
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        fontSize: 16),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: document["content"],
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black)),
                                    ],
                                  ),
                                ),
                              )
                            : new Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(document["ownername"],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            fontSize: 16)),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(document["content"],
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 16,
                                            color: Colors.black))
                                  ],
                                ),
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                            Utils.getMessageTimerFrmt(document["created_time"]),
                            style:
                                TextStyle(color: Colors.black45, fontSize: 12))
                      ],
                    )),
                  ));
                }).toList(),
              );
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Text('Home'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.rss_feed),
                title: Text('Feed'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                title: Text('Message'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.image),
                title: Text('Resources'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.supervisor_account),
                title: Text(
                  'Users',
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.verified_user),
                title: Text(
                  'Faculties',
                ),
              )
            ],
            currentIndex: _selectedIndex,
            backgroundColor: Colors.white,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            //unselectedLabelStyle: TextStyle(color: Colors.grey),
            onTap: _onItemTapped,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, "/feededitor");
            },
            child: Icon(Icons.add, color: Theme.of(context).primaryColor),
            backgroundColor: Theme.of(context).secondaryHeaderColor,
          ),
        ));
  }
}
