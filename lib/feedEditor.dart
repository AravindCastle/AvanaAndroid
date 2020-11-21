import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'Utils.dart';

//String[] videoFrmts=new String['.WEBM','.MPG', '.MP2', '.MPEG', '.MPE', '.MPV', '.OGG', '.MP4', '.M4P', '.M4V', '.AVI', '.WMV', '.MOV','.QT', '.FLV', '.SWF', '.AVCHD'];

class FeedEditor extends StatefulWidget {
  _FeedEditorState createState() => _FeedEditorState();
}

class _FeedEditorState extends State<FeedEditor> {
  MediaQueryData medQry;
  bool isSaving = false;
  List<File> uploaderImgs = new List();
  TextEditingController messageContr = new TextEditingController();

  Future<void> _pickImage() async {
    if (uploaderImgs.length < 10) {
      File selectedFile = await FilePicker.getFile(type: FileType.any);
      //await ImagePicker.pickImage(source: source);
      if (selectedFile != null && this.mounted) {
        setState(() {
          uploaderImgs.add(selectedFile);
        });
      }
    }
  }

  Future<void> addNewFeed(BuildContext context) async {
    final ProgressDialog uploadingPop = ProgressDialog(context,
        type: ProgressDialogType.Download, isDismissible: false);
    var uuid = new Uuid();
    String folderId = uuid.v4();
    if (!isSaving) {
      if (!isSaving && this.mounted)
        setState(() {
          isSaving = true;
        });
      try {
        String content = messageContr.text;
        if (content.isNotEmpty) {
          List<Map> fileUrls = new List();
          final SharedPreferences localStore =
              await SharedPreferences.getInstance();
          await uploadingPop.show();
          uploadingPop.style(
              message: "Uploading files", maxProgress: 100, progress: 0);
          int totalFiles = uploaderImgs.length;

          for (int i = 0; i < uploaderImgs.length; i++) {
            String fileName = uploaderImgs[i].path.split("/").last;
            StorageReference storageReference = FirebaseStorage.instance
                .ref()
                .child('AvanaFiles/' + folderId + '/' + fileName);
            StorageUploadTask uploadTask =
                storageReference.putFile(uploaderImgs[i]);

            int fileNumber = i + 1;
            String loaderInfo = "$fileNumber/$totalFiles file is uploading  ";

            uploadingPop.style(
                message: loaderInfo, maxProgress: 100, progress: 0);
            double loadingValue = 0;
            uploadTask.events.listen((event) {
              loadingValue = 100 *
                  (uploadTask.lastSnapshot.bytesTransferred /
                      uploadTask.lastSnapshot.totalByteCount);
              uploadingPop.update(
                  message: loaderInfo, progress: loadingValue.roundToDouble());
            });

            await uploadTask.onComplete;
            fileUrls.add({
              "url": await storageReference.getDownloadURL(),
              "name": fileName,
              "type": fileName.split(".").last,
            });
          }
          await uploadingPop.hide();

          Utils.showLoadingPopText(context, "Saving");

          final SharedPreferences store = await SharedPreferences.getInstance();
          DocumentReference newFeed =
              await Firestore.instance.collection("feed").add({
            "content": content,
            "owner": localStore.getString("userId"),
            "ownername": localStore.getString("name"),
            "ownerrole": localStore.getInt("role"),
            "feedtype": 0,
            "created_time": new DateTime.now().millisecondsSinceEpoch,
            "attachments": fileUrls
          });

          String notfyStr =
              localStore.getString("name") + " has added a new post ";

          Utils.sendPushNotification(
              "New feed ", notfyStr, "feed", newFeed.documentID);

          Navigator.pushNamed(context, "/feed");
        }
      } catch (Exception) {
        print(Exception);
      }
      if (this.mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget buildAttachmentSection(BuildContext context) {
    List<Widget> row1 = new List();
    List<Widget> row2 = new List();
    List<Widget> row3 = new List();
    List<Widget> row4 = new List();
    for (int i = 0; i < uploaderImgs.length; i++) {
      File prevFile = uploaderImgs[i];
      String fileName = prevFile.path.split("/").last;
      String fileType = fileName.split(".").last;
      if (i < 3) {
        row1.add((Utils.attachmentWid(
            fileName, prevFile, null, fileType, context, medQry)));
      } else if (i < 6) {
        row2.add((Utils.attachmentWid(
            fileName, prevFile, null, fileType, context, medQry)));
      } else if (i < 9) {
        row3.add((Utils.attachmentWid(
            fileName, prevFile, null, fileType, context, medQry)));
      } else {
        row4.add((Utils.attachmentWid(
            fileName, prevFile, null, fileType, context, medQry)));
      }
    }

    return new Container(
      child: Column(
        children: <Widget>[
          Row(children: row1),
          Row(children: row2),
          Row(children: row3),
          Row(children: row4)
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);

    return new Scaffold(
        appBar: AppBar(
          title: Text("New  Feed"),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.attach_file), onPressed: _pickImage),
            IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  addNewFeed(context);
                })
          ],
        ),
        body: new SingleChildScrollView(
          child: new Container(
            padding: const EdgeInsets.all(1.0),
            alignment: Alignment.center,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 0, 3),
                    child: SizedBox(
                        child: Text(
                      "Feed Content",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(5),
                      child: new TextField(
                          autofocus: true,
                          controller: messageContr,
                          maxLines: 15,
                          decoration: InputDecoration(
                              border: new OutlineInputBorder(
                                  borderSide: new BorderSide(
                                      color: Theme.of(context).primaryColor)),
                              contentPadding:
                                  EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Type ..."))),
                  buildAttachmentSection(context)
                ]),
          ),
        ));
  }
}
