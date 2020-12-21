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
  String docmtId;
  String userName;
  String password;
  String email;
  String role;
  int userRole;
  bool isActive;
  MediaQueryData medQry = null;
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
          children: <Widget>[
            Text("User Name"),
            Text(userName),
            Text("Password"),
            Text(password),
            Text("Role"),
            Text(Utils.getRoleString(role)),
            Text("is Active"),
            Text(isActive.toString()),
            Text("Membership Date"),
            Text(membershipDate.toString())
          ]);
    }
  }

  Future<void> updateUserActive(bool state, String docId) async {
    await Firestore.instance.collection('userdata').document(docId).updateData({
      "isactive": state,
      "membershipdate": DateTime.now().millisecondsSinceEpoch
    });
  }

  Future<void> getUserDetails(String docId) async {
    final DocumentSnapshot userDetails =
        await Firestore.instance.collection('userdata').document(docId).get();
    if (userDetails.data.length > 0) {
      userName = userDetails["username"];
      password = userDetails["password"];
      userRole = userDetails["userrole"];
      role = Utils.getRoleString(userRole.toString());

      isActive = userDetails["isactive"];
      membershipDate = userDetails["membershipdate"];
      email = userDetails["email"];
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
          height: medQry.size.height * .90,
          //  padding:EdgeInsets.all(10),
          child: new Column(
            //  mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: medQry.size.width * .35,
                height: medQry.size.width * .35,
                child: Icon(
                  Icons.account_circle,
                  size: medQry.size.width * .35,
                  color: Color.fromRGBO(44, 44, 44, 1),
                ),
              ),
              SizedBox(height: 10, width: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  //  Utils.getUserBadge(userRole,17),
                  Text(userName,
                      style: TextStyle(
                        fontSize: 26,
                      ),
                      textAlign: TextAlign.center),
                ],
              ),
              SizedBox(height: medQry.size.height * .03),
              Padding(
                  padding: EdgeInsets.all(medQry.size.width * .04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: medQry.size.width * .27,
                        child: Text("Email ", style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(
                        width: medQry.size.width * .60,
                        child:
                            Text(":  " + email, style: TextStyle(fontSize: 15)),
                      ),
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.all(medQry.size.width * .04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: medQry.size.width * .27,
                        child:
                            Text("Password ", style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(
                        width: medQry.size.width * .60,
                        child: Text(":  " + password,
                            style: TextStyle(fontSize: 15)),
                      ),
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.all(medQry.size.width * .04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: medQry.size.width * .27,
                        child: Text("Role ", style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(
                        width: medQry.size.width * .60,
                        child: Text(": " + role.toString(),
                            style: TextStyle(fontSize: 15)),
                      ),
                    ],
                  )),
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                    width: medQry.size.width * .80,
                    child: SwitchListTile(
                      title: Text("User Status"),
                      value: isActive,
                      onChanged: (bool value) {
                        setState(() {
                          isActive = value;
                          updateUserActive(isActive, docmtId);
                        });
                      },
                    )),
              )
            ],
          )),
    );
  }

  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);
    final UserDetailsArguement userDet =
        ModalRoute.of(context).settings.arguments;
    docmtId = userDet.userId;
    getUserDetails(docmtId);
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(title: Text("User Details")),
            body: new Container(
              padding: const EdgeInsets.all(1.0),
              alignment: Alignment.center,
              child: (isPageLoading
                  ? CircularProgressIndicator()
                  : buildUserCard(context)),
            )));
  }
}
