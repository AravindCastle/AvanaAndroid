import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'Utils.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MediaQueryData medQry = null;
  SharedPreferences prefs;
  String userName = "";
  int userRole = 1;
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    Utils.bottomNavAction(index, context);
  }

  @override
  void initState() {
    super.initState();
    Utils.getAllComments();
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
                      Utils.isNewMessage(feedDoc.documentID, prefs),
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
            title: Text('Home'),
          ),
          body: Stack(children: <Widget>[
            Column(children: <Widget>[
              Flexible(
                  child: ListView(children: [
                new Container(
                    height: 300,
                    width: medQry.size.width,
                    child: Column(children: [
                      new Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Feed",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          )),
                    ])),
                new Container(
                    height: 300,
                    width: medQry.size.width,
                    child: new Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Messages",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        )))
              ]))
            ])
          ])

          /* new StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('Threads')
                .orderBy("created_time", descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return SizedBox(
                    child: new LinearProgressIndicator(), height: 5);
              return new ListView(
                children: snapshot.data.documents.map((document) {
                  return feedItem(document, context);
                }).toList(),
              );
            },
          )*/
          ,
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
        ));
  }
}
