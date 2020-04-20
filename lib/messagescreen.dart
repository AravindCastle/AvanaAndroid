import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'Utils.dart';

class MessagePage extends StatefulWidget {
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  MediaQueryData medQry = null;
  Widget messageItem(DocumentSnapshot messageDoc, BuildContext context) {
    int createdTime = messageDoc["created_time"];
    return new GestureDetector(
        child: Card(
            elevation: 3,
            child: new Container(
              height: 110,
              child: new Padding(
                  padding: EdgeInsets.all(medQry.size.width * .02),
                  child: new Column(children: [
                    Row(children: [
                      SizedBox(
                        width: medQry.size.width * .68,
                        child: Text(
                          messageDoc["ownername"],
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: TextStyle(fontSize: 19),
                        ),
                      ),
                      SizedBox(
                        width: medQry.size.width*.25,
                      child:Text(
                        Utils.getTimeFrmt(messageDoc["created_time"]),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: TextStyle(
                            fontSize: 13,
                            textBaseline: TextBaseline.alphabetic),
                      ),
                      ),                      
                    ]),
                    SizedBox(height: medQry.size.height * .01),
                    Row(
                      children: <Widget>[
                        SizedBox(width: medQry.size.width * .05),
                        SizedBox(
                          width: medQry.size.width * .84,
                          child: Text(
                            messageDoc["content"],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w300),
                          ),
                        ),
                        //SizedBox(width: medQry.size.width * .05),
                      ],
                    ),
                  ])),
            )),
        onTap: () {
          Navigator.pushNamed(context, "/messageview",
              arguments: messageDoc.documentID);
        });
  }

  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(title: Text("Messages")),
          body: new StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('Threads')
                .orderBy("created_time")
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return new CircularProgressIndicator();
              return new ListView(
                children: snapshot.data.documents.map((document) {
                  return messageItem(document, context);
                }).toList(),
              );
            },
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(183, 28, 28, 1),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            child: CircleAvatar(
                              child: Icon(Icons.account_circle, size: 60),
                            ),
                          )
                        ])),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Users'),
                  onTap: () {
                    Navigator.pushNamed(context, "/userlist");
                  },
                ),
                ListTile(
                  leading: Icon(Icons.add_call),
                  title: Text('Log out'),
                  onTap: () async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.clear();
                    Navigator.pushNamed(context, "/login");
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, "/messageeditor");
            },
            child: Icon(Icons.add),
            backgroundColor: Theme.of(context).secondaryHeaderColor,
          ),
        ));
  }
}
