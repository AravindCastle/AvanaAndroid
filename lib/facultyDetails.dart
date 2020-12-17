import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Utils.dart';

class FacultyDetailsPage extends StatefulWidget {
  String currentUserId;
  FacultyDetailsPage({this.currentUserId});

  _FacultyDetailsPageState createState() =>
      _FacultyDetailsPageState(this.currentUserId);
}

class _FacultyDetailsPageState extends State<FacultyDetailsPage> {
  String currentUserId;

  _FacultyDetailsPageState(this.currentUserId);

  bool isPageLoading = true;
  String userName;
  String description;
  String profile_pic_url = null;

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
      profile_pic_url = userDetails["profile_pic_url"];
    }
    if (this.mounted) {
      setState(() {
        isPageLoading = false;
      });
    }
  }

  Widget buildUserCard(BuildContext context) {
    return Container(
        width: medQry.size.width * .95,
        padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
        //  padding:EdgeInsets.all(10),
        child: new Column(
          //  mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.transparent,
              child: ClipOval(
                  child: profile_pic_url != null
                      ? CachedNetworkImage(
                          imageUrl: profile_pic_url,
                          height: 160,
                          width: 160,
                          fit: BoxFit.fill,
                        )
                      : Icon(
                          Icons.account_circle,
                          size: 160,
                          color: Colors.grey[350],
                        )),
            ),
            SizedBox(height: 10, width: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 10, width: 10),
                Text(userName,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 17, color: Colors.black54),
                  ),
                ),
              ],
            )
          ],
        ));
  }

  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);
    getUserDetails(currentUserId);
    return SafeArea(
        child: new Scaffold(
            appBar: AppBar(title: Text("Faculty Detail")),
            body: SingleChildScrollView(
                child: new Container(
              padding: const EdgeInsets.all(1.0),
              alignment: Alignment.center,
              child: (isPageLoading
                  ? CircularProgressIndicator()
                  : buildUserCard(context)),
            ))));
  }
}
