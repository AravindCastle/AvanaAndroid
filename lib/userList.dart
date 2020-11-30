import 'package:avana_academy/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class userListPage extends StatefulWidget {
  _userListPageState createState() => _userListPageState();
}

class _userListPageState extends State<userListPage> {
  MediaQueryData medQry;

  int _selectedIndex = 3;
  void _onItemTapped(int index) {
    Utils.bottomNavAction(index, context);
  }

  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);
    return Scaffold(
        // appBar: AppBar(title: Text("Users")),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Utils.showUserPop(context);
            },
          ),
          title: Text("Users"),
        ),
        backgroundColor: Colors.white,
        body: new StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('userdata')
              .orderBy("userrole", descending: true)
              .orderBy("username")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return new Text('Loading...');
            return new ListView(
              children: snapshot.data.documents.map((document) {
                return new Visibility(
                    visible: (Utils.userRole == 1 ||
                        Utils.userRole == 2 ||
                        (Utils.userRole == 3 && document['userrole'] == 3)),
                    child: new ListTile(
                      dense: false,
                      trailing: Utils.isSuperAdmin()
                          ? Icon(Icons.keyboard_arrow_right)
                          : SizedBox(),
                      leading: Utils.userProfilePic(document.documentID, 20),
                      title: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            (1 == document['userrole'] ||
                                    2 == document['userrole'])
                                ? new Padding(
                                    padding: EdgeInsets.fromLTRB(0, 2, 3, 0),
                                    child: Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: document['userrole'] == 1
                                          ? Colors.redAccent
                                          : Colors.blueAccent,
                                    ))
                                : SizedBox(),
                            new Text(document['username'],
                                style: TextStyle(fontWeight: FontWeight.bold))
                          ]),
                      //subtitle: new Text(document['email']),
                      onTap: Utils.isSuperAdmin()
                          ? () {
                              Navigator.pushNamed(context, "/userdetailpage",
                                  arguments: {
                                    "userid": document.documentID,
                                    "username": document["username"]
                                  });
                            }
                          : null,
                    ));
              }).toList(),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: Utils.bottomNavItem(),

          currentIndex: _selectedIndex,
          // backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          //unselectedLabelStyle: TextStyle(color: Colors.grey),
          onTap: _onItemTapped,
        ),
        /*drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(25, 118, 210, 1),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: medQry.size.width * .15,
                        width: medQry.size.width * .15,
                        child: CircleAvatar(
                          child: Icon(Icons.account_circle,
                              size: medQry.size.width * .15),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(Utils.userName,
                          style: TextStyle(fontSize: 18, color: Colors.white))
                    ])),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
              onTap: () {
                Navigator.pushNamed(context, "/messagePage");
              },
            ),
            (Utils.userRole == 1)
                ? ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text('Users'),
                    onTap: () {
                      Navigator.pushNamed(context, "/userlist");
                    },
                  )
                : SizedBox(height: 0),
            ListTile(
              leading: Icon(Icons.supervisor_account),
              title: Text('Faculties'),
              onTap: () {
                Navigator.pushNamed(context, "/facultyPage");
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Resources'),
              onTap: () {
                Navigator.pushNamed(context, "/gallery", arguments: {
                  "superLevel": 0,
                  "parentid": "0",
                  "title": "Gallery"
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
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
      ),*/
        floatingActionButton: new Visibility(
          visible: (Utils.isSuperAdmin()),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, "/adduser");
              // Add your onPressed code here!
            },
            child: Icon(
              Icons.add,
              color: Theme.of(context).primaryColor,
            ),
            backgroundColor: Theme.of(context).secondaryHeaderColor,
          ),
        ));
  }
}
