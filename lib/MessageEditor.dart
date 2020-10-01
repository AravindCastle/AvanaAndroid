import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'Utils.dart';

//String[] videoFrmts=new String['.WEBM','.MPG', '.MP2', '.MPEG', '.MPE', '.MPV', '.OGG', '.MP4', '.M4P', '.M4V', '.AVI', '.WMV', '.MOV','.QT', '.FLV', '.SWF', '.AVCHD'];

class MessageEditor extends StatefulWidget {
  _MessageEditorState createState() => _MessageEditorState();
}

class _MessageEditorState extends State<MessageEditor> {
  MediaQueryData medQry;
  bool isSaving = false;
  List<File> uploaderImgs = new List();
  List<String> videoFrmts = new List();
  TextEditingController messageContr = new TextEditingController();
  String dropDownValue = "First Item";

//videoFrmts.addAll({'.WEBM','.MPG', '.MP2', '.MPEG', '.MPE', '.MPV', '.OGG', '.MP4', '.M4P', '.M4V', '.AVI', '.WMV', '.MOV','.QT', '.FLV', '.SWF', '.AVCHD'});
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

  Future<void> saveThread(BuildContext context) async {
    var uuid = new Uuid();
    String folderId = uuid.v4();
    if (!isSaving) {
      if (!isSaving && this.mounted)
        setState(() {
          isSaving = true;
        });
      try {
        Utils.showLoadingPop(context);
        String content = messageContr.text;
        if (content.isNotEmpty) {
          List<Map> fileUrls = new List();
          final SharedPreferences localStore =
              await SharedPreferences.getInstance();
          for (int i = 0; i < uploaderImgs.length; i++) {
            String fileName = uploaderImgs[i].path.split("/").last;
            StorageReference storageReference = FirebaseStorage.instance
                .ref()
                .child('AvanaFiles/' + folderId + '/' + fileName);
            StorageUploadTask uploadTask =
                storageReference.putFile(uploaderImgs[i]);
            await uploadTask.onComplete;
            fileUrls.add({
              "url": await storageReference.getDownloadURL(),
              "name": fileName,
              "type": fileName.split(".").last
            });
          }
          Navigator.pop(context);
          Utils.showLoadingPopText(context, "Saving");
          DocumentReference newThread =
              await Firestore.instance.collection("Threads").add({
            "content": messageContr.text,
            "owner": localStore.getString("userId"),
            "ownername": localStore.getString("name"),
            "ownerrole": localStore.getInt("role"),
            "attachments": fileUrls.toList(),
            "created_time": new DateTime.now().millisecondsSinceEpoch,
            "folderid": folderId,
            "subject": dropDownValue
          });

          String notfyStr = messageContr.text;
          Utils.sendPushNotification(
              "New Message", notfyStr, "messageview", newThread.documentID);
          Navigator.pushNamed(context, "/messagePage");
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
          title: Text("Compose Message"),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.attach_file), onPressed: _pickImage),
            IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  saveThread(context);
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
                  isSaving
                      ? SizedBox(
                          height: medQry.size.height * .01,
                          //child: LinearProgressIndicator(),
                        )
                      : SizedBox(
                          height: medQry.size.height * .01,
                        ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 0, 3),
                      child: SizedBox(
                          child: Text(
                        "Subject",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ))),
                  SizedBox(
                    height: medQry.size.height * .01,
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 0, 3),
                      child: new Container(
                          width: medQry.size.height,
                          child: DropdownButton(
                              value: dropDownValue,
                              items: [
                                DropdownMenuItem(
                                  child: Text("First Item"),
                                  value: "First Item",
                                ),
                                DropdownMenuItem(
                                  child: Text("Second Item"),
                                  value: "Second Item",
                                ),
                                DropdownMenuItem(
                                    child: Text("Third Item"),
                                    value: "Third Item"),
                                DropdownMenuItem(
                                    child: Text("Fourth Item"),
                                    value: "Fourth Item")
                              ],
                              onChanged: (value) {
                                setState(() {
                                  dropDownValue = value;
                                });
                              }))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 0, 3),
                    child: SizedBox(
                        child: Text(
                      "Content",
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
