import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
//videoFrmts.addAll({'.WEBM','.MPG', '.MP2', '.MPEG', '.MPE', '.MPV', '.OGG', '.MP4', '.M4P', '.M4V', '.AVI', '.WMV', '.MOV','.QT', '.FLV', '.SWF', '.AVCHD'});
  Future<void> _pickImage() async {
    if (uploaderImgs.length <= 6) {
      File selectedFile = await FilePicker.getFile(type: FileType.any);
      //await ImagePicker.pickImage(source: source);
      if (selectedFile != null) {
        setState(() {
          uploaderImgs.add(selectedFile);
        });
      }
    }
  }

  Future<void> saveThread() async {
    if(!isSaving)
    setState(() {
      isSaving=true;
    });
    try {
      String content = messageContr.text;
      if (content.isNotEmpty) {
        List<Map> fileUrls = new List();
        final SharedPreferences localStore =
            await SharedPreferences.getInstance();
        for (int i = 0; i < uploaderImgs.length; i++) {
          String fileName = uploaderImgs[i].path.split("/").last;
          StorageReference storageReference =
              FirebaseStorage.instance.ref().child('AvanaFiles/' + fileName);
          StorageUploadTask uploadTask =
              storageReference.putFile(uploaderImgs[i]);
          await uploadTask.onComplete;
          fileUrls.add({
            "url": await storageReference.getDownloadURL(),
            "name": fileName,
            "type": fileName.split(".").last
          });
        }

        var succes = await Firestore.instance.collection("Threads").add({
          "content": messageContr.text,
          "owner": localStore.getString("userId"),
          "ownername": localStore.getString("name"),
          "attachments": fileUrls.toList(),
          "created_time": new DateTime.now().millisecondsSinceEpoch,
          "title": localStore.getString("name") +
              "-" +
              new DateTime.now().toIso8601String()
        });
        Navigator.pushNamed(context, "/messagePage");
      }
    } catch (Exception) {
      print(Exception);
    }
    setState(() {
      isSaving=false;
    });
  }

  Widget buildAttachmentSection(BuildContext context) {
    List<Widget> row1 = new List();
    List<Widget> row2 = new List();
    for (int i = 0; i < uploaderImgs.length; i++) {
      File prevFile = uploaderImgs[i];
      String fileName = prevFile.path.split("/").last;
      String fileType = fileName.split(".").last;
      if (i < 3) {
        row1.add(
            (Utils.attachmentWid(prevFile, null, fileType, context, medQry)));
      } else {
        row2.add(
            (Utils.attachmentWid(prevFile, null, fileType, context, medQry)));
      }
    }

    return new Container(
      child: Column(
        children: <Widget>[Row(children: row1), Row(children: row2)],
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
            IconButton(icon: Icon(Icons.send), onPressed: saveThread)
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
                          child: LinearProgressIndicator(),
                        )
                      : SizedBox(
                          height: medQry.size.height * .01,
                        ),
                  new TextField(
                    autofocus: true,
                      controller: messageContr,
                      maxLines: 15,
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          hintText: "Type ...")),
                  buildAttachmentSection(context)
                ]),
          ),
        ));
  }
}
