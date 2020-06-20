import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Utils.dart';

class UserDetailsArguement {
  final String userId;

  UserDetailsArguement(this.userId);
}

class FacultyDetailsPage extends StatefulWidget {
  _FacultyDetailsPageState createState() => _FacultyDetailsPageState();
}

class _FacultyDetailsPageState extends State<FacultyDetailsPage> {
  bool isPageLoading = true;
  String docmtId;
  String userName;
  String description;

  String role;
  int userRole;
  bool isActive;
  MediaQueryData medQry = null;
  int membershipDate;

  Future<void> getUserDetails(String docId) async {
    final DocumentSnapshot userDetails =
        await Firestore.instance.collection('userdata').document(docId).get();
    if (userDetails.data.length > 0) {
      userName = userDetails["username"];
      description = userDetails["description"];
      userRole = userDetails["userrole"];
      role = Utils.getRoleString(userRole.toString());
    }
    if (this.mounted) {
      setState(() {
        isPageLoading = false;
      });
    }
  }

  Widget buildUserCard(BuildContext context) {
    return Card(
      elevation: 3,
      child: Container(
          width: medQry.size.width * .95,
         padding: EdgeInsets.all(5),
          //  padding:EdgeInsets.all(10),
          child: new Column(
            //  mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: medQry.size.width * .35,
                height: medQry.size.width * .35,
                child: Icon(
                  Icons.account_circle,
                  size: medQry.size.width * .35,
                  color: Colors.lightBlue,
                ),
              ),
              SizedBox(height: 10, width: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10, width: 10),
                  Text(userName,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center),
                ],
              ),
              SizedBox(height: medQry.size.height * .03),
              Row(
                
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10, width: 10),
                  SizedBox(
                          width: medQry.size.width * .89,
                          child: Text(
                            description,
                            maxLines: 50,                                                      
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: TextStyle(
                                fontSize: 17,color: Colors.black54),
                          ),
                        ),
                ],
              )
            ],
          )),
    );
  }

  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);
    docmtId = ModalRoute.of(context).settings.arguments;
    getUserDetails(docmtId);
    return new Scaffold(
        appBar: AppBar(title: Text("Faculty Detail")),
        body: SingleChildScrollView(child:new Container(
          padding: const EdgeInsets.all(1.0),
          alignment: Alignment.center,
          child: (isPageLoading
              ? CircularProgressIndicator()
              : buildUserCard(context)),
        )));
  }
}
