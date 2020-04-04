import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagePage extends StatefulWidget {
  _MessagePageState createState() => _MessagePageState();
}


class _MessagePageState extends State<MessagePage> {
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(title: Text("Messages")),

      body:new StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('Threads').orderBy("created_time").snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return new CircularProgressIndicator();
                return new ListView(
                  children: snapshot.data.documents.map((document) {
                    return new ListTile(
                      trailing: Icon(Icons.keyboard_arrow_right),
                      leading: CircleAvatar(
                          backgroundColor: Color.fromRGBO(240, 85, 69, 1),
                        ),
                      title: new Text(document['title'],style: TextStyle(
                        fontWeight: FontWeight.bold
                      )),
                      subtitle: new Text(document['owner']),
                     onTap: (){
                       Navigator.pushNamed(context, "/messageview",arguments:document.documentID );
                     },
                    );
                  }).toList(),
                );
              },
            ),
      drawer: new Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                "text",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
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
        backgroundColor: Colors.green,
      ),
    );
  }
}
