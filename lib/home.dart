import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  Widget feedCard(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('feed')
          .where("feedtype", isEqualTo: 0)
          .orderBy("created_time", descending: true)
          .limit(10)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return SizedBox();
        return new ListView(
          scrollDirection: Axis.horizontal,
          children: snapshot.data.docs.map((document) {
            return Card(
              elevation: 2,
              child: new Container(
                padding: EdgeInsets.all(20),
                height: 180,
                width: medQry.size.width * .9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.blueAccent,
                        ),
                        Text(
                          document["ownername"],
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(document["content"],
                        maxLines: 4, style: TextStyle(fontSize: 16)),
                    Spacer(),
                    Text(Utils.getMessageTimerFrmt(document["created_time"]),
                        style: TextStyle(color: Colors.black45, fontSize: 12))
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget messageCard(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Threads')
          .orderBy("created_time", descending: true)
          .limit(10)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData)
          return SizedBox(child: new LinearProgressIndicator(), height: 5);
        return new ListView(
          scrollDirection: Axis.horizontal,
          children: snapshot.data.docs.map((document) {
            return Card(
              elevation: 2,
              child: new Container(
                padding: EdgeInsets.all(20),
                height: 180,
                width: medQry.size.width * .9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.blueAccent,
                        ),
                        Text(
                          document["ownername"],
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(document["subject"],
                        maxLines: 1,
                        style: TextStyle(fontSize: 17, color: Colors.black)),
                    SizedBox(
                      height: 5,
                    ),
                    Text(document["content"],
                        maxLines: 3,
                        style: TextStyle(fontSize: 15, color: Colors.black87)),
                    Spacer(),
                    Text(Utils.getMessageTimerFrmt(document["created_time"]),
                        style: TextStyle(color: Colors.black45, fontSize: 12))
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget build(BuildContext context) {
    if (Utils.isNewResourcesAdded) {
      Utils.isNewResourcesAdded = false;
      Fluttertoast.showToast(
          msg: "New resources added please checkout",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

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
          body: SingleChildScrollView(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("Feed",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                new Container(
                  height: 200,
                  child: feedCard(context),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("Messages",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                new Container(
                  height: 200,
                  child: messageCard(context),
                )
              ],
            ),
          )

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
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.rss_feed),
                label: 'Feed',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: 'Message',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.image),
                label:'Resources',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.supervisor_account),
                label:  'Users',
                
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.verified_user),
                label: 'Faculties',
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
