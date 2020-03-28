import 'package:avana_academy/userDetailsPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class userListPage extends StatefulWidget {
  _userListPageState createState() => _userListPageState();
}

class _userListPageState extends State<userListPage> {

  Future<void> openUserDetails(){

  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users")),

      body:new StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('userdata').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return new Text('Loading...');
                return new ListView(
                  children: snapshot.data.documents.map((document) {
                    return new ListTile(
                      trailing: Icon(Icons.keyboard_arrow_right),
                      leading: CircleAvatar(
                          backgroundColor: Color.fromRGBO(240, 85, 69, 1),
                        ),
                      title: new Text(document['username'],style: TextStyle(
                        fontWeight: FontWeight.bold
                      )),
                      subtitle: new Text(document['email']),
                     onTap: (){
                       Navigator.pushNamed(context, "/userdetailpage",arguments:UserDetailsArguement(document.documentID)) ;
                     },
                    );
                  }).toList(),
                );
              },
            ),
        
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/adduser");
          // Add your onPressed code here!
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
