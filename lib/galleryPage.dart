import 'dart:core';

import 'dart:io';

import 'package:avana_academy/Utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class GalleryPage extends StatefulWidget {
  GalleryPageState createState() => GalleryPageState();
}

class GalleryPageState extends State<GalleryPage> {
  TextEditingController folderName = new TextEditingController();
  TextEditingController urlContrl = new TextEditingController();
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
                new ListTile(
                  leading: new Icon(Icons.insert_link),
                  title: new Text('Youtube'),
                  onTap: () {
                    Navigator.pop(context);
                    showAddYoutubePop(context);
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> createYoutubeLink() async {
    String name = folderName.text;
    String url = urlContrl.text;
    if (name.isNotEmpty) {
      Firestore.instance.collection("gallery").add({
        "name": name,
        "type": "youtube",
        "level": argMap["superLevel"],
        "parentid": argMap["parentid"],
        "ordertype": 3,
        "url": url,
        "filetype": "youttube",
        "created_time": new DateTime.now().millisecondsSinceEpoch,
      });
      Navigator.pop(context);

      Utils.newResourceNotify();
    }
  }

  Future<void> createFolder() async {
    String name = folderName.text;
    if (name.isNotEmpty) {
      Firestore.instance.collection("gallery").add({
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

  Future<void> deleteFolderOrFile(
      String docId, bool isFolder, String url) async {
    final ProgressDialog deletingPop = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    deletingPop.show();
    deletingPop.style(message: "Deleting on progress");

    if (!isFolder) {
      await Firestore.instance.collection("gallery").document(docId).delete();

      try {
        StorageReference storageReference =
            await FirebaseStorage.instance.getReferenceFromUrl(url);
        storageReference.delete();
      } catch (Exception) {}
    } else {
      try {} catch (Exception) {}
    }

    deletingPop.hide();
  }

  // bool deleteOnLoop(String docId) async {}

  void deleteAlert(
      BuildContext context, bool isFolder, String docId, String url) {
    showDialog(
        context: context,
        builder: (BuildContext bCont) {
          return new Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(95)),
              child: AlertDialog(
                title: Text(
                  "Do you want to delete this message",
                  textAlign: TextAlign.center,
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Delete'),
                    onPressed: () {
                      Navigator.of(context).pop();

                      deleteFolderOrFile(docId, isFolder, url);
                    },
                  ),
                ],
              ));
        });
  }

  Future<void> uploadFile(BuildContext context) async {
    try {
      File selectedFile = await FilePicker.getFile(type: FileType.any);
      final ProgressDialog uploadingPop = ProgressDialog(context,
          type: ProgressDialogType.Download, isDismissible: false);
      if (selectedFile != null) {
        String fileName = selectedFile.path.split("/").last;
        String fileType = fileName.split(".").last;
        if (fileType == "pdf" ||
            Utils.getImageFormats(fileType) ||
            Utils.getVideoFormats(fileType)) {
          await uploadingPop.show();
          uploadingPop.style(
              message: "Uploading files", maxProgress: 100, progress: 0);

          StorageReference storageReference = FirebaseStorage.instance
              .ref()
              .child('AvanaFiles/Gallery/' +
                  fileName +
                  DateTime.now().millisecondsSinceEpoch.toString());
          StorageUploadTask uploadTask = storageReference.putFile(selectedFile);
          uploadingPop.style(
              message: "Uploading " + fileName, maxProgress: 100, progress: 0);
          double loadingValue = 0;
          uploadTask.events.listen((event) {
            loadingValue = 100 *
                (uploadTask.lastSnapshot.bytesTransferred /
                    uploadTask.lastSnapshot.totalByteCount);
            uploadingPop.update(
                message: "Uploading " + fileName,
                progress: loadingValue.roundToDouble());
          });

          await uploadTask.onComplete;
          String url = await storageReference.getDownloadURL();

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

          await uploadingPop.hide();

          Utils.newResourceNotify();
        }
      }
    } catch (e) {
      Navigator.of(context).pop();
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

  void showAddYoutubePop(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext bCont) {
          return new Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(95)),
              child: AlertDialog(
                title: Text(
                  "Youtube",
                  textAlign: TextAlign.center,
                ),
                content: Column(children: [
                  TextField(
                      controller: folderName,
                      autofocus: true,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: "Title",
                        //  fillColor: Color.fromRGBO(117, 117, 117, .2),
                        contentPadding: EdgeInsets.all(2),
                      )),
                  SizedBox(height: 10),
                  TextField(
                      controller: urlContrl,
                      autofocus: true,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: "URL",
                        //  fillColor: Color.fromRGBO(117, 117, 117, .2),
                        contentPadding: EdgeInsets.all(2),
                      )),
                ]),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Add'),
                    onPressed: () {
                      createYoutubeLink();
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
                return buildAttachment(document, context);
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 9 / 11,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
            ));
      },
    );
  }

  Widget buildAttachment(DocumentSnapshot galleryItem, BuildContext context) {
    if (galleryItem["type"] == "folder") {
      return GestureDetector(
          onLongPress: Utils.isSuperAdmin()
              ? () {
                  deleteAlert(context, true, galleryItem.documentID, null);
                }
              : null,
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
                        maxLines: 2,
                        style: TextStyle(fontSize: 13),
                        textAlign: TextAlign.center))
              ])));
    } else if (galleryItem["type"] == "file" ||
        galleryItem["type"] == "youtube") {
      return GestureDetector(
          onLongPress: Utils.isSuperAdmin()
              ? () {
                  deleteAlert(context, false, galleryItem.documentID,
                      galleryItem["url"]);
                }
              : null,
          child: Utils.buildGalleryFileItem(context, galleryItem["url"],
              galleryItem["name"], galleryItem["filetype"]));
    } else {
      return SizedBox();
    }
  }

  int _selectedIndex = 2;
  void _onItemTapped(int index) {
    Utils.bottomNavAction(index, context);
  }

  Widget buildPage(BuildContext context) {
    if (argMap["superLevel"].toString().contains("0")) {
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Utils.showUserPop(context);
              },
            ),
            title: Text(
              argMap["title"],
            ),
            elevation: 0,
          ),
          body: new Container(
            child: buildGallery(context),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: Utils.bottomNavItem(),

            currentIndex: _selectedIndex,
            // backgroundColor: Colors.white,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            //unselectedLabelStyle: TextStyle(color: Colors.grey),
            onTap: _onItemTapped,
          ),
          floatingActionButton: new Visibility(
              visible: Utils.userRole == 1 || Utils.userRole == 2,
              child: FloatingActionButton(
                onPressed: ((Utils.userRole == 1 || Utils.userRole == 2) &&
                        argMap["superLevel"] < 10)
                    ? () {
                        showAddType(context);
                      }
                    : null,
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                ),
                backgroundColor: Theme.of(context).secondaryHeaderColor,
              )));
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              argMap["title"],
            ),
            elevation: 0,
          ),
          body: new Container(
            child: buildGallery(context),
          ),
          floatingActionButton: new Visibility(
              visible: Utils.userRole == 1 || Utils.userRole == 2,
              child: FloatingActionButton(
                onPressed: ((Utils.userRole == 1 || Utils.userRole == 2) &&
                        argMap["superLevel"] < 10)
                    ? () {
                        showAddType(context);
                      }
                    : null,
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                ),
                backgroundColor: Theme.of(context).secondaryHeaderColor,
              )));
    }
  }

  MediaQueryData medQry;
  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);
    argMap = ModalRoute.of(context).settings.arguments;
    return buildPage(context);
  }

  @override
  void dispose() {
    folderName.dispose();
    super.dispose();
  }
}
