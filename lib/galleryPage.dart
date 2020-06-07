import 'dart:core';
import 'dart:io';

import 'package:avana_academy/Utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GalleryPage extends StatefulWidget {
  GalleryPageState createState() => GalleryPageState();
}

class GalleryPageState extends State<GalleryPage> {
  TextEditingController folderName = new TextEditingController();
  Map argMap;
  void showAddType(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.folder),
                    title: new Text('Folder'),
                    onTap: () {
                      Navigator.pop(context);
                      showAddFolderPop(context);
                    }),
                new ListTile(
                  leading: new Icon(Icons.file_upload),
                  title: new Text('File'),
                  onTap: () {
                    Navigator.pop(context);
                    uploadFile(context);
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> createFolder() async {
    String name = folderName.text;
    if (name.isNotEmpty) {
      DocumentReference newThread =
          await Firestore.instance.collection("gallery").add({
        "name": name,
        "type": "folder",
        "level": argMap["superLevel"],
        "parentid": argMap["parentid"],
        "ordertype": 1,
        "created_time": new DateTime.now().millisecondsSinceEpoch,
      });
      Navigator.pop(context);
    }
  }

  Future<void> uploadFile(BuildContext context) async {
    File selectedFile = await FilePicker.getFile(type: FileType.any);
    if (selectedFile != null) {
      String fileName = selectedFile.path.split("/").last;
      String fileType = fileName.split(".").last;
      if (fileType == "pdf" ||
          Utils.getImageFormats(fileType) ||
          Utils.getVideoFormats(fileType)) {
        Utils.showLoadingPop(context);
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child('AvanaFiles/' +
                fileName +
                DateTime.now().millisecondsSinceEpoch.toString());
        StorageUploadTask uploadTask = storageReference.putFile(selectedFile);
        await uploadTask.onComplete;
        String url = await storageReference.getDownloadURL();

        Navigator.of(context).pop();
        DocumentReference newThread =
            await Firestore.instance.collection("gallery").add({
          "name": fileName,
          "type": "file",
          "level": argMap["superLevel"],
          "parentid": argMap["parentid"],
          "ordertype": 2,
          "url": url,
          "filetype": fileType,
          "created_time": new DateTime.now().millisecondsSinceEpoch,
        });
      }
    }
  }

  void showAddFolderPop(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext bCont) {
          return new Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(95)),
              child: AlertDialog(
                title: Text(
                  "New folder",
                  textAlign: TextAlign.center,
                ),
                content: TextField(
                    controller: folderName,
                    autofocus: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromRGBO(117, 117, 117, .2),
                      contentPadding: EdgeInsets.all(2),
                    )),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Create'),
                    onPressed: () {
                      createFolder();
                    },
                  ),
                ],
              ));
        });
  }

  Widget buildGallery(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection("gallery")
          .where("parentid", isEqualTo: argMap["parentid"])
          .orderBy("ordertype")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Container();
        final int messageCount = snapshot.data.documents.length;
        return Padding(
            padding: EdgeInsets.all(1),
            child: GridView.builder(
              itemCount: messageCount,
              itemBuilder: (_, int index) {
                final DocumentSnapshot document =
                    snapshot.data.documents[index];
                return buildAttachment(document);
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
            ));
      },
    );
  }

  Widget buildAttachment(DocumentSnapshot galleryItem) {
    if (galleryItem["type"] == "folder") {
      return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, "/gallery", arguments: {
              "superLevel": galleryItem["level"] + 1,
              "parentid": galleryItem.documentID,
              "title": galleryItem["name"]
            });
          },
          child: new Container(
              width: 100,
              height: 90,
              child: Column(children: [
                IconButton(
                    color: Color.fromRGBO(25, 118, 210, .4),
                    icon: Icon(
                      Icons.folder,
                      color: Color.fromRGBO(25, 118, 210, .4),
                    ),
                    iconSize: 80,
                    onPressed: null),
                Padding(
                    padding: EdgeInsets.only(left: 15, right: 5),
                    child: Text(galleryItem["name"],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 11),
                        textAlign: TextAlign.center))
              ])));
    } else if (galleryItem["type"] == "file") {
      return Utils.buildGalleryFileItem(context, galleryItem["url"],
          galleryItem["name"], galleryItem["filetype"]);
    } else {
      return SizedBox();
    }
  }
MediaQueryData medQry;
  Widget build(BuildContext context) {
     medQry = MediaQuery.of(context);
    argMap = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(title: Text(argMap["title"])),
        body: new Container(
          child: buildGallery(context),
        ),
        drawer: Drawer(
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
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: argMap["superLevel"] < 10
              ? () {
                  showAddType(context);
                }
              : null,
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).secondaryHeaderColor,
        ));
  }

  @override
  void dispose() {
    folderName.dispose();
    super.dispose();
  }
}
