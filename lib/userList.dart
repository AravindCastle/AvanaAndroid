import 'package:avana_academy/Utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class userListPage extends StatefulWidget {
  _userListPageState createState() => _userListPageState();
}

class _userListPageState extends State<userListPage> {
  MediaQueryData medQry;

  int _selectedIndex = 4;
  void _onItemTapped(int index) {
    Utils.bottomNavAction(index, context);
  }

  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);
    return SafeArea(
        child: Scaffold(
            // appBar: AppBar(title: Text("Users")),
            appBar: AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 134, 131, 131),
                      Color.fromARGB(255, 54, 52, 52),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0, 1],
                  ),
                ),
              ),
              leading: IconButton(
                icon: Utils.userProfilePic(Utils.userId, 14),
                onPressed: () {
                  Utils.showUserPop(context);
                },
              ),
              title: Text("Users"),
            ),
            backgroundColor: Colors.white,
            body: new StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('userdata')
                  .orderBy("userrole", descending: true)
                  .orderBy("username")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return new Text('Loading...');
                return new ListView(
                  children: snapshot.data.docs.map((document) {
                    return new Visibility(
                        visible: (Utils.userRole == 1 ||
                            (Utils.userRole == 2 &&
                                document['userrole'] == 2) ||
                            (Utils.userRole == 3 && document['userrole'] == 3)),
                        child: new ListTile(
                          dense: false,
                          trailing: Utils.isSuperAdmin()
                              ? Icon(Icons.keyboard_arrow_right)
                              : SizedBox(),
                          leading: Utils.userProfilePic(document.id, 20),
                          title: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                (1 == document['userrole'] ||
                                        2 == document['userrole'])
                                    ? new Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 2, 3, 0),
                                        child: Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: document['userrole'] == 1
                                              ? Colors.redAccent
                                              : Colors.blueAccent,
                                        ))
                                    : SizedBox(),
                                new Text(document['username'],
                                    softWrap: true,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ))
                              ]),
                          //subtitle: new Text(document['email']),
                          onTap: Utils.isSuperAdmin()
                              ? () {
                                  Navigator.pushNamed(
                                      context, "/userdetailpage", arguments: {
                                    "userid": document.id,
                                    "username": document["username"],
                                    "ismemberedit": false
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
              backgroundColor: Colors.black,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
              //unselectedLabelStyle: TextStyle(color: Colors.grey),
              onTap: _onItemTapped,
            ),
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
            )));
  }
}
