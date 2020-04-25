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
  String userName="";
  int userRole;
  //void initState() {
    
  //}

  void getUserName() async{
     SharedPreferences prefs = await SharedPreferences.getInstance();
    if (this.mounted){

    setState(() {
     userName=prefs.getString("name"); 
     userRole=prefs.getInt("role");
    });     
    }
  }
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
                      SizedBox(width: medQry.size.height * .01),
                      SizedBox(
                        width: medQry.size.width * .60,
                        child: Text(
                          messageDoc["ownername"],
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: TextStyle(fontSize: 19,color: Colors.black)
                          
                        ),
                      ),
                      SizedBox(
                        width: medQry.size.width*.32,
                      child:Text(
                        Utils.getTimeFrmt(messageDoc["created_time"]),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
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
                        SizedBox(width: medQry.size.width * .01),
                        SizedBox(
                          width: medQry.size.width * .92,
                          child: Text(
                            "\t\t\t"+messageDoc["content"],
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: TextStyle(
                                fontSize: 15,color: Colors.black54),
                          ),
                        ),                       
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
      getUserName();
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
              if (!snapshot.hasData) return SizedBox(child:  new LinearProgressIndicator(),height:5);
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
                            height:medQry.size.width*.15, 
                            width:medQry.size.width*.15,
                            child: CircleAvatar(
                              child: Icon(Icons.account_circle, size: medQry.size.width*.15),
                            ),
                          ),
                          SizedBox(height:15),
                          Text(userName,style: TextStyle(fontSize:18,color: Colors.white))
                        ])),
                (userRole==1) ?
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Users'),
                  onTap: () {
                    Navigator.pushNamed(context, "/userlist");
                  },
                ):SizedBox(height:0),

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
