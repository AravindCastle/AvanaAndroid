import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

bool isActive = true;
String userRole = "3";
bool loading = false;

class AddUserPage extends StatefulWidget {
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  TextEditingController userName = new TextEditingController();
  TextEditingController emailId = new TextEditingController();
  TextEditingController password = new TextEditingController();
  TextEditingController description = new TextEditingController();

  TextEditingController hospital = new TextEditingController();

  TextEditingController city = new TextEditingController();
  String region = "north";
  File profilePic = null;
  void initState() => loading = false;

  Widget buttonOrLoading() {
    if (loading)
      return new LinearProgressIndicator();
    else {
      return ConstrainedBox(
          constraints:
              const BoxConstraints(minWidth: double.infinity, minHeight: 40),
          child: RaisedButton(
            child: Text(
              "Add new user",
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              addnewUser(context);
            },
          ));
    }
  }

  Future<void> _pickImage() async {
    File selectedFile = await FilePicker.getFile(type: FileType.image);
    if (selectedFile != null && this.mounted) {
      setState(() {
        profilePic = selectedFile;
      });
    }
  }

  void addnewUser(BuildContext context) async {
    final ProgressDialog uploadingPop = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    try {
      if (userName.text.isNotEmpty &&
          password.text.isNotEmpty &&
          emailId.text.isNotEmpty) {
        if (this.mounted) {
          setState(() {
            loading = true;
          });
        }

        uploadingPop.style(message: "Adding new user ...");
        uploadingPop.show();
        String profile_pic_url = null;
        if (profilePic != null) {
          StorageReference storageReference = FirebaseStorage.instance
              .ref()
              .child('AvanaFiles/' + profilePic.path.split("/").last);
          StorageUploadTask uploadTask = storageReference.putFile(profilePic);
          await uploadTask.onComplete;
          profile_pic_url = await storageReference.getDownloadURL();
        }
        await Firestore.instance.collection("userdata").add({
          "username": userName.text,
          "email": emailId.text,
          "password": password.text,
          "isactive": isActive,
          "userrole": int.parse(userRole),
          "membershipdate": new DateTime.now().millisecondsSinceEpoch,
          "description": description.text,
          "hospital": hospital.text,
          "city": city.text,
          "region": region,
          "profile_pic_url": profile_pic_url,
        });

        userName.clear();
        emailId.clear();
        password.clear();
        description.clear();
        if (this.mounted) {
          setState(() {
            loading = false;
          });
        }
        uploadingPop.hide();
        Navigator.pop(context);
      }
    } catch (Exception) {
      setState(() {
        loading = false;
      });
      uploadingPop.hide();
    }
  }

  Widget profilePicture() {
    return Container(
      height: 90,
      width: 90,
      child: profilePic == null
          ? Center(
              child: Icon(Icons.edit),
            )
          : CircleAvatar(
              child: ClipOval(
              child: Image.file(
                profilePic,
                width: 90,
                height: 90,
                fit: BoxFit.fill,
              ),
            )),
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: Colors.grey[350]),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add user"),
      ),
      body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.all(1.0),
              //alignment: Alignment.t,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      child: profilePicture(),
                      onTap: _pickImage,
                    ),
                    SizedBox(height: 20),
                    TextField(
                        controller: userName,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            labelText: "Username")),
                    SizedBox(height: 10),
                    TextField(
                        controller: emailId,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            labelText: "Email Id")),
                    SizedBox(height: 10),
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
                      value: isActive,
                      onChanged: (bool value) {
                        setState(() {
                          isActive = value;
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
                        value: "1",
                        groupValue: userRole,
                        onChanged: (String value) {
                          setState(() {
                            userRole = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: new Text('Faculty'),
                      leading: Radio(
                        value: "2",
                        groupValue: userRole,
                        onChanged: (String value) {
                          setState(() {
                            userRole = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: new Text('Member'),
                      leading: Radio(
                        value: "3",
                        groupValue: userRole,
                        onChanged: (String value) {
                          setState(() {
                            userRole = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                    buttonOrLoading(),
                    SizedBox(height: 30),
                  ],
                ),
              ))),
    );
  }
}
