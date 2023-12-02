import 'dart:io';
import 'dart:math';

import 'package:avana_academy/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditUser extends StatefulWidget {
  String currentUserId;
  String currentUserName;
  bool isMemberEdit;

  EditUser({this.currentUserId, this.currentUserName, this.isMemberEdit});

  _EditUserState createState() => _EditUserState(
      this.currentUserId, this.currentUserName, this.isMemberEdit);
}

class _EditUserState extends State<EditUser> {
  String currentUserId;
  String currentUserName;
  bool isMemberEdit;
  _EditUserState(this.currentUserId, this.currentUserName, this.isMemberEdit);

  bool isPageLoading = true;
  bool isActiveUser = true;

  int userRole = 3;
  String currentUserEmail = "";
  TextEditingController password = new TextEditingController();
  TextEditingController description = new TextEditingController();
  TextEditingController distributor_name = new TextEditingController();

  //TextEditingController hospital = new TextEditingController();

  TextEditingController city = new TextEditingController();
  String region = "north";
  File profilePic = null;
  String profilePickUrl = null;

  void initState() {
    fetchUserDetails();
  }

  Future<void> _pickImage() async {
    FilePickerResult selectedFile =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (selectedFile != null && this.mounted) {
      setState(() {
        profilePic = File(selectedFile.files.first.path);
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
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('AvanaFiles/profilepics/' +
          profilePic.path.split("/").last +
          DateTime.now().millisecondsSinceEpoch.toString());
      UploadTask uploadTask = ref.putFile(profilePic);

      TaskSnapshot taskres = await uploadTask.whenComplete(() => null);
      profilePickUrl = await taskres.ref.getDownloadURL();
    }

/*
    if (profilePic != null) {
      try {
        profilePickUrl = await Utils.uploadImageGetUrl(
            'AvanaFiles/profilepics/' + profilePic.path.split("/").last,
            profilePic);
      } catch (Exception) {
        print(Exception);
      }
    }
*/
    await FirebaseFirestore.instance
        .collection("userdata")
        .doc(currentUserId)
        .update({
      "password": password.text,
      "distributor_name": distributor_name.text,
      "isactive": isActiveUser,
      "userrole": userRole,
      "description": description.text,
      //"hospital": hospital.text,
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

  List<Widget> userEditFields() {
    List<Widget> fields = [
      GestureDetector(
        child: profilePicture(),
        onTap: _pickImage,
      ),
      SizedBox(height: 20),
      Text(
        currentUserName,
        style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10),
      Text(
        currentUserEmail,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
      SizedBox(height: 20),
      TextField(
          controller: password,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              labelText: "Password")),
      SizedBox(height: 10),
      TextField(
          controller: distributor_name,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              labelText: "Distributor Name")),
      SizedBox(height: 10),
      TextField(
          controller: city,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              labelText: "City Name")),
    ];
    if (!isMemberEdit) {
      fields.addAll([
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
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            )),
        SizedBox(height: 10),
        TextField(
          controller: description,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
          title: new Text(Utils.distributorName),
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
      ]);
    }

    fields.addAll([
      SizedBox(height: 30),
      ConstrainedBox(
          constraints:
              const BoxConstraints(minWidth: double.infinity, minHeight: 40),
          child: TextButton(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(
                    Color.fromRGBO(134, 134, 134, 1))),
            child: Text(
              "Update",
              style: TextStyle(fontSize: 20),
            ),
            onPressed: updateUserDetails,
          )),
      SizedBox(height: 30),
    ]);

    if (isMemberEdit) {
      fields.add(TextButton(
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.white),
            backgroundColor:
                MaterialStateProperty.all(Color.fromRGBO(128, 0, 0, 1))),
        onPressed: () async {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.clear();
          Navigator.pushReplacementNamed(context, "/login");
        },
        child: Text(
          "Logout",
          style: TextStyle(fontSize: 18),
        ),
      ));
    }
    return fields;
  }

  Future<void> fetchUserDetails() async {
    DocumentSnapshot currentUserDetailsSnap = await FirebaseFirestore.instance
        .collection('userdata')
        .doc(currentUserId)
        .get();
    Map currentUserDetails = currentUserDetailsSnap.data();
    currentUserEmail = currentUserDetails["email"];
    isActiveUser = currentUserDetails["isactive"];
    password.text = currentUserDetails["password"];
    if (currentUserDetails["distributor_name"] != null) {
      distributor_name.text = currentUserDetails["distributor_name"];
    } else {
      distributor_name.text = "";
    }
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
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(currentUserName),
        actions: "admin@avanasurgical.com" == currentUserEmail.trim() ||
                isMemberEdit
            ? []
            : [
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
                                    TextButton(
                                      style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.white),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Color.fromRGBO(
                                                      128, 0, 0, 1))),
                                      onPressed: () => {
                                        FirebaseFirestore.instance
                                            .collection('userdata')
                                            .doc(currentUserId)
                                            .delete(),
                                        Navigator.pop(context),
                                        Navigator.pop(context),
                                      },
                                      child: Text("Ok"),
                                    ),
                                    TextButton(
                                      style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.white),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Color.fromRGBO(
                                                      128, 0, 0, 1))),
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
                  children: userEditFields(),
                ),
        ),
      ),
    ));
  }
}
