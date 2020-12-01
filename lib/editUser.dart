import 'dart:io';

import 'package:avana_academy/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class EditUser extends StatefulWidget {
  String currentUserId;
  String currentUserName;

  EditUser({this.currentUserId, this.currentUserName});

  _EditUserState createState() =>
      _EditUserState(this.currentUserId, this.currentUserName);
}

class _EditUserState extends State<EditUser> {
  String currentUserId;
  String currentUserName;
  _EditUserState(this.currentUserId, this.currentUserName);

  bool isPageLoading = true;
  bool isActiveUser = true;

  int userRole = 3;
  String currentUserEmail = "";
  TextEditingController password = new TextEditingController();
  TextEditingController description = new TextEditingController();

  TextEditingController hospital = new TextEditingController();

  TextEditingController city = new TextEditingController();
  String region = "north";
  File profilePic = null;
  String profilePickUrl = null;

  void initState() {
    fetchUserDetails();
  }

  Future<void> _pickImage() async {
    File selectedFile = await FilePicker.getFile(type: FileType.image);
    if (selectedFile != null && this.mounted) {
      setState(() {
        profilePic = selectedFile;
      });
    }
  }

  Widget profilePicture() {
    return Container(
      height: 130,
      width: 130,
      child: (profilePickUrl == null && profilePic == null)
          ? Center(
              child: Icon(Icons.edit),
            )
          : CircleAvatar(
              child: ClipOval(
              child: profilePic != null
                  ? Image.file(
                      profilePic,
                      width: 130,
                      height: 130,
                      fit: BoxFit.fill,
                    )
                  : CachedNetworkImage(
                      imageUrl: profilePickUrl,
                      width: 130,
                      height: 130,
                      fit: BoxFit.fill,
                    ),
            )),
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: Colors.grey[350]),
    );
  }

  Future<void> updateUserDetails() async {
    final ProgressDialog updateUser = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);

    updateUser.style(message: "Updating user details ...");
    updateUser.show();

    if (profilePic != null) {
      try {
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child('AvanaFiles/profilepics/' + profilePic.path.split("/").last);
        StorageUploadTask uploadTask = storageReference.putFile(profilePic);
        await uploadTask.onComplete;
        profilePickUrl = await storageReference.getDownloadURL();
      } catch (Exception) {}
    }

    await Firestore.instance
        .collection("userdata")
        .document(currentUserId)
        .updateData({
      "password": password.text,
      "isactive": isActiveUser,
      "userrole": userRole,
      "description": description.text,
      "hospital": hospital.text,
      "city": city.text,
      "region": region,
      "profile_pic_url": profilePickUrl,
    });

    if (Utils.userProfilePictures != null) {
      Utils.userProfilePictures[currentUserId] = profilePickUrl;
    }

    updateUser.hide();
    Navigator.pop(context);
  }

  Future<void> fetchUserDetails() async {
    DocumentSnapshot currentUserDetails = await Firestore.instance
        .collection('userdata')
        .document(currentUserId)
        .get();

    currentUserEmail = currentUserDetails["email"];
    isActiveUser = currentUserDetails["isactive"];
    password.text = currentUserDetails["password"];
    hospital.text = currentUserDetails["hospital"];
    city.text = currentUserDetails["city"];
    region = currentUserDetails["region"];
    description.text = currentUserDetails["description"];
    userRole = currentUserDetails["userrole"];
    profilePickUrl = currentUserDetails["profile_pic_url"];

    setState(() {
      isPageLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentUserName),
        actions: [
          IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: () => {
                    showDialog(
                        context: context,
                        builder: (BuildContext bCont) {
                          return AlertDialog(
                            title: Text(
                                "Do you want to remove this user permanently ?"),
                            actions: [
                              FlatButton(
                                onPressed: () => {
                                  Firestore.instance
                                      .collection('userdata')
                                      .document(currentUserId)
                                      .delete(),
                                  Navigator.pop(context),
                                  Navigator.pop(context),
                                },
                                child: Text("Ok"),
                              ),
                              FlatButton(
                                onPressed: () => {Navigator.pop(context)},
                                child: Text("Cancel"),
                              )
                            ],
                          );
                        })
                  })
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: isPageLoading
              ? Center(
                  child: SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator()),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      child: profilePicture(),
                      onTap: _pickImage,
                    ),
                    SizedBox(height: 20),
                    Text(
                      currentUserName,
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      currentUserEmail,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 20),
                    TextField(
                        controller: password,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            labelText: "Password")),
                    SizedBox(height: 10),
                    TextField(
                        controller: hospital,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            labelText: "Hospital Name")),
                    SizedBox(height: 10),
                    TextField(
                        controller: city,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            labelText: "City Name")),
                    SizedBox(height: 10),
                    DropdownButtonFormField(
                        onChanged: (val) => {
                              setState(() {
                                region = val;
                              })
                            },
                        items: [
                          DropdownMenuItem(
                            child: Text("North"),
                            value: "north",
                          ),
                          DropdownMenuItem(
                            child: Text("South"),
                            value: "south",
                          ),
                          DropdownMenuItem(
                            child: Text("East"),
                            value: "east",
                          ),
                          DropdownMenuItem(
                            child: Text("West"),
                            value: "west",
                          )
                        ],
                        value: region,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Region",
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        )),
                    SizedBox(height: 10),
                    TextField(
                      controller: description,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          labelText: "Description"),
                      maxLines: 5,
                    ),
                    SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text(
                        'Activate User',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: isActiveUser,
                      onChanged: (bool value) {
                        setState(() {
                          isActiveUser = value;
                        });
                      },
                    ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: Text(
                          "Choose user role :",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        )),
                    ListTile(
                      title: new Text('Admin'),
                      leading: Radio(
                        value: 1,
                        groupValue: userRole,
                        onChanged: (int value) {
                          setState(() {
                            userRole = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: new Text('Faculty'),
                      leading: Radio(
                        value: 2,
                        groupValue: userRole,
                        onChanged: (int value) {
                          setState(() {
                            userRole = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: new Text('Member'),
                      leading: Radio(
                        value: 3,
                        groupValue: userRole,
                        onChanged: (int value) {
                          setState(() {
                            userRole = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                    ConstrainedBox(
                        constraints: const BoxConstraints(
                            minWidth: double.infinity, minHeight: 40),
                        child: RaisedButton(
                          child: Text(
                            "Edit user",
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: updateUserDetails,
                        )),
                    SizedBox(height: 30),
                  ],
                ),
        ),
      ),
    );
  }
}
