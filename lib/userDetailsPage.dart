import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Utils.dart';

class UserDetailsArguement {
  final String userId;

  UserDetailsArguement(this.userId);
}

class UserDetailsPage extends StatefulWidget {
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  bool isPageLoading = true;
  String userName;
  String password;
  String role;
  bool isActive;
  int membershipDate;
  Widget DisplayBuilder(String userId) {
 

    if (isPageLoading) {
      getUserDetails(userId);
      return new CircularProgressIndicator();
    } else {
      return GridView.count(
         childAspectRatio: 1,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          crossAxisCount: 2,
          children: <Widget>[Text("User Name"), Text(userName),Text("Password"), Text(password),Text("Role"), Text(Utils.getRoleString(role) ),Text("is Active"), Text(isActive.toString()),Text("Membership Date"), Text(membershipDate.toString())]);
    }
  }
  Future<void> getUserDetails(String docId) async {
     final DocumentSnapshot userDetails = await Firestore.instance
          .collection('userdata')
          .document(docId).get();
          if(userDetails.data.length>0){
              userName=userDetails["username"];
              password=userDetails["password"];
              role=userDetails["role"];
              isActive=userDetails["isactive"];
              membershipDate= userDetails["membershipdate"];
          }
         setState(() {
           isPageLoading=false;
         });
   
  }
  Widget build(BuildContext context) {
    final UserDetailsArguement userDet =
        ModalRoute.of(context).settings.arguments;

    return new Scaffold(
      appBar: AppBar(title: Text("User Details")),
      body: new Container(
          padding: const EdgeInsets.all(1.0),
          alignment: Alignment.center,
          child: DisplayBuilder(userDet.userId)),
    );
  }
}
