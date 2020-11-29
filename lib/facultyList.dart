import 'package:avana_academy/Utils.dart';
import 'package:avana_academy/userDetailsPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class facultyListPage extends StatefulWidget {
  _facultyListPageState createState() => _facultyListPageState();
}

class _facultyListPageState extends State<facultyListPage> {
  MediaQueryData medQry;
  int _selectedIndex = 4;
  void _onItemTapped(int index) {
    Utils.bottomNavAction(index, context);
  }

  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Faculties"),
        leading: IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () {
            Utils.showUserPop(context);
          },
        ),
      ),
      body: new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('userdata')
            .where("userrole", isEqualTo: 2)
            .orderBy("username")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return new Text('Loading...');
          return new ListView(
            children: snapshot.data.documents.map((document) {
              return new ListTile(
                trailing: Icon(Icons.keyboard_arrow_right),
                leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white60,
                    child: (document["profile_pic_url"] == null ||
                            document["profile_pic_url"] == "")
                        ? Icon(
                            Icons.account_circle_rounded,
                            size: 40,
                            color: Colors.grey[350],
                          )
                        : ClipOval(
                            child: CachedNetworkImage(
                            imageUrl: document["profile_pic_url"],
                            height: 38,
                            width: 38,
                            fit: BoxFit.fill,
                          ))),
                title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      new Padding(
                          padding: EdgeInsets.fromLTRB(0, 2, 3, 0),
                          child: Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.blueAccent,
                          )),
                      new Text(document['username'],
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ]),
                subtitle: new Text(document['email']),
                onTap: () {
                  Navigator.pushNamed(context, "/facultyDetail",
                      arguments: document.documentID);
                },
              );
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
      )
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
                            height:medQry.size.width*.15, 
                            width:medQry.size.width*.15,
                            child: CircleAvatar(
                              child: Icon(Icons.account_circle, size: medQry.size.width*.15),
                            ),
                          ),
                          SizedBox(height:15),
                          Text(Utils.userName,style: TextStyle(fontSize:18,color: Colors.white))
                        ])),
                ListTile(
                  leading: Icon(Icons.message),
                  title: Text('Messages'),
                  onTap: () {
                    Navigator.pushNamed(context, "/messagePage" ); 
                  },
                ),
                (Utils.userRole==1) ?
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Users'),
                  onTap: () {
                    Navigator.pushNamed(context, "/userlist");
                  },
                ):SizedBox(height:0),
                ListTile(
                  leading: Icon(Icons.supervisor_account),
                  title: Text('Faculties'),
                  onTap: () {
                     Navigator.pushNamed(context, "/facultyPage" );  
                  },
                ),
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Resources'),
                  onTap: () {
                    Navigator.pushNamed(context, "/gallery",arguments:{"superLevel":0,"parentid":"0","title":"Gallery"} ); 
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
          )*/
      ,
    );
  }
}
