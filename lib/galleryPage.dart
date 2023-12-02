import 'dart:core';

import 'dart:io';

import 'package:avana_academy/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:progress_dialog/progress_dialog.dart';

class GalleryPage extends StatefulWidget {
  GalleryPageState createState() => GalleryPageState();
}

class GalleryPageState extends State<GalleryPage> {
  TextEditingController folderName = new TextEditingController();
  TextEditingController urlContrl = new TextEditingController();
  TextEditingController folderEditForm = new TextEditingController();
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
      FirebaseFirestore.instance.collection("gallery").add({
        "name": name,
        "type": "youtube",
        "level": argMap["superLevel"],
        "parentid": argMap["parentid"],
        "ordertype": 3,
        "url": url,
        "filetype": "youtube",
        "created_time": new DateTime.now().millisecondsSinceEpoch,
      });
      Navigator.pop(context);

      Utils.newResourceNotify();
    }
  }

  Future<String> updateFolderImage() async {
    String dowloadUrl = "";
    if (FolderImage != null) {
      String fileName = FolderImage.path.split("/").last;
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('AvanaFiles/Gallery/' +
          fileName +
          DateTime.now().millisecondsSinceEpoch.toString());
      UploadTask uploadTask = ref.putFile(FolderImage);
      TaskSnapshot taskres = await uploadTask.whenComplete(() => null);
      dowloadUrl = await taskres.ref.getDownloadURL();
    }
    return dowloadUrl;
  }

  Future<void> editFolder(String folderId, String folderName) async {
    String folderFileName = await updateFolderImage();
    Map<String, Object> editedFolderObj = new Map();
    editedFolderObj["name"] = folderName;
    if (folderFileName != "") {
      editedFolderObj["fileurl"] = folderFileName;
    }
    FirebaseFirestore.instance
        .collection("gallery")
        .doc(folderId)
        .update(editedFolderObj)
        .then((value) => Navigator.of(context).pop());
  }

  Future<void> createFolder() async {
    String name = folderName.text;
    if (name.isNotEmpty) {
      String folderFileName = await updateFolderImage();

      FirebaseFirestore.instance.collection("gallery").add({
        "name": name,
        "type": "folder",
        "level": argMap["superLevel"],
        "parentid": argMap["parentid"],
        "ordertype": 1,
        "fileurl": folderFileName,
        "created_time": new DateTime.now().millisecondsSinceEpoch,
      });
      Navigator.pop(context);
    }
  }

  Future<void> deleteFolderOrFile(
      String docId, bool isFolder, String url) async {
    final ProgressDialog deletingPop = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    deletingPop.style(message: "Deleting on progress");
    deletingPop.show();

    await deleteOnLoop(docId);

    deletingPop.hide();
  }

  Future<bool> deleteOnLoop(String docId) async {
    try {
      DocumentSnapshot currDoc = await FirebaseFirestore.instance
          .collection('gallery')
          .doc(docId)
          .get();
      if (currDoc["type"] == "folder") {
        List<DocumentSnapshot> childElements = [];
        final QuerySnapshot userDetails = await FirebaseFirestore.instance
            .collection('gallery')
            .where("parentid", isEqualTo: docId)
            .get();
        childElements = userDetails.docs;

        for (int i = 0; i < childElements.length; i++) {
          deleteOnLoop(childElements[i].id);
        }
      } else if (currDoc["type"] == "file") {
        try {
          Reference storageReference =
              await FirebaseStorage.instance.refFromURL(currDoc["url"]);
          storageReference.delete();
        } catch (Exception) {}
      }
      await FirebaseFirestore.instance
          .collection('gallery')
          .doc(docId)
          .delete();
    } catch (e) {
      return false;
    }

    return true;
  }

  String updatedImageText = "";

  void showEditPop(BuildContext context, bool isFolder, String docId,
      String url, DocumentSnapshot itemObj) {
    folderEditForm.text = itemObj["name"];
    showDialog(
        context: context,
        builder: (BuildContext bCont) {
          return new Dialog(
              child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Container(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: folderEditForm,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusColor: Colors.blue,
                          border: OutlineInputBorder(),
                          //  icon: Icon(Icons.vpn_key),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextButton.icon(
                          onPressed: _pickFolderImage,
                          icon: Icon(Icons.mode_edit_outline),
                          label: Text("Upload Image")),
                      Text(updatedImageText),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 15,
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();

                              deleteFolderOrFile(docId, isFolder, url);
                            },
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all(
                                  Color.fromRGBO(255, 255, 255, 1)),
                              backgroundColor: MaterialStateProperty.all(
                                  Color.fromRGBO(128, 0, 0, 1)),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0))),
                            ),
                            child: Text('Delete'),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0))),
                            ),
                            child: const Text("Cancel"),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          OutlinedButton(
                            onPressed: () {
                              String editedFolderName =
                                  folderEditForm.text != ""
                                      ? folderEditForm.text
                                      : itemObj["name"];
                              editFolder(itemObj.id, editedFolderName);
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0))),
                            ),
                            child: const Text("Update"),
                          ),
                        ],
                      )
                    ],
                  ))));
        });
  }

  File FolderImage = null;
  Future<void> _pickFolderImage() async {
    FolderImage = null;
    FilePickerResult selectedFile =
        await FilePicker.platform.pickFiles(type: FileType.image);
    //await ImagePicker.pickImage(source: source);
    if (selectedFile.files.length > 0 && this.mounted) {
      setState(() {
        FolderImage = File(selectedFile.files.first.path);
      });
    }
  }

  Future<File> cropImage(BuildContext context, File file) async {
    ImageCropper imgCrop = ImageCropper();
    File croppedFile = await imgCrop.cropImage(
      sourcePath: file.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Theme.of(context).primaryColor,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    );

    return croppedFile;
  }

  Future<void> uploadFile(BuildContext context) async {
    try {
      FilePickerResult selectedFile =
          await FilePicker.platform.pickFiles(type: FileType.any);
      final ProgressDialog uploadingPop = ProgressDialog(context,
          type: ProgressDialogType.Download, isDismissible: false);
      if (selectedFile.count > 0) {
        String fileName = selectedFile.files.first.path.split("/").last;
        String fileType = fileName.split(".").last;
        if (fileType == "pdf" ||
            Utils.getImageFormats(fileType) ||
            Utils.getVideoFormats(fileType)) {
          File fileToBeUploaded = File(selectedFile.files.first.path);
          if (Utils.getImageFormats(fileType)) {
            fileToBeUploaded =
                await cropImage(context, File(selectedFile.files.first.path));
          }

          uploadingPop.style(
              message: "Uploading files", maxProgress: 100, progress: 0);
          await uploadingPop.show();

          FirebaseStorage storage = FirebaseStorage.instance;
          Reference ref = storage.ref().child('AvanaFiles/Gallery/' +
              fileName +
              DateTime.now().millisecondsSinceEpoch.toString());
          UploadTask uploadTask = ref.putFile(fileToBeUploaded);

          uploadingPop.style(
              message: "Uploading " + fileName, maxProgress: 100, progress: 0);
          double loadingValue = 0;
          uploadTask.snapshotEvents.listen((event) {
            loadingValue = 100 *
                (uploadTask.snapshot.bytesTransferred /
                    uploadTask.snapshot.totalBytes);
            uploadingPop.update(
                message: "Uploading " + fileName,
                progress: loadingValue.roundToDouble());
          });

          TaskSnapshot taskres = await uploadTask.whenComplete(() => null);
          String url = await taskres.ref.getDownloadURL();

          await FirebaseFirestore.instance.collection("gallery").add({
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

          Fluttertoast.showToast(
              msg: "File successfully added ",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 3,
              backgroundColor: Color.fromARGB(255, 4, 62, 6),
              textColor: Colors.white,
              fontSize: 16.0);

          Utils.newResourceNotify();
        }
      }
    } catch (e) {
      Navigator.of(context).pop();
    }
  }

  void showAddFolderPop(BuildContext context) {
    folderName.clear();
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
                content: Column(
                  children: [
                    TextField(
                        controller: folderName,
                        autofocus: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color.fromRGBO(117, 117, 117, .2),
                          contentPadding: EdgeInsets.all(2),
                        )),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text("Attach Image"),
                        SizedBox(width: 10),
                        IconButton(
                            onPressed: _pickFolderImage,
                            icon: Icon(
                              Icons.attach_file,
                              color: Color.fromRGBO(25, 118, 210, .4),
                            ))
                      ],
                    )
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(128, 0, 0, 1))),
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(128, 0, 0, 1))),
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
    folderName.clear();
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
                  TextButton(
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(128, 0, 0, 1))),
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(128, 0, 0, 1))),
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
      stream: FirebaseFirestore.instance
          .collection("gallery")
          .where("parentid", isEqualTo: argMap["parentid"])
          .orderBy("ordertype")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Container();
        final int messageCount = snapshot.data.docs.length;
        return Container(
            padding: EdgeInsets.all(0),
            child: GridView.builder(
              itemCount: messageCount,
              itemBuilder: (_, int index) {
                final DocumentSnapshot document = snapshot.data.docs[index];
                return buildAttachment(document, context);
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 9 / 11,
                crossAxisSpacing: 22.0,
                mainAxisSpacing: 22.0,
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
                  showEditPop(context, true, galleryItem.id, null, galleryItem);
                }
              : null,
          onTap: () {
            Navigator.pushNamed(context, "/gallery", arguments: {
              "superLevel": galleryItem["level"] + 1,
              "parentid": galleryItem.id,
              "title": galleryItem["name"]
            });
          },
          child: new Container(
              width: 100,
              height: 90,
              child: Column(children: [
                SizedBox(
                    width: 80,
                    height: 75,
                    child: galleryItem.data().toString().contains('fileurl') &&
                            "" != galleryItem["fileurl"]
                        ? Material(
                            elevation: 10,
                            child: CachedNetworkImage(
                              width: 55,
                              height: 65,
                              alignment: Alignment.bottomCenter,
                              fit: BoxFit.fill,
                              progressIndicatorBuilder:
                                  (context, url, progress) => Image.asset(
                                "assets/imagethumbnail.png",
                                width: 120,
                                height: 86,
                              ),
                              imageUrl: galleryItem["fileurl"],
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          )
                        : IconButton(
                            color: Color.fromRGBO(25, 118, 210, .4),
                            icon: Icon(
                              Icons.folder,
                              color: Color.fromRGBO(25, 118, 210, .4),
                            ),
                            iconSize: 80,
                            onPressed: null)),
                Padding(
                    padding: EdgeInsets.only(top: 12, left: 15, right: 5),
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
                  showEditPop(context, false, galleryItem.id,
                      galleryItem["url"], galleryItem);
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
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 134, 131, 131),
                    Color.fromARGB(255, 54, 52, 52),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0, 1],
                ),
              ),
            ),
            leading: IconButton(
              icon: Utils.userProfilePic(Utils.userId, 14),
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
            color: Color.fromARGB(255, 232, 232, 232),
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: buildGallery(context),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: Utils.bottomNavItem(),

            currentIndex: _selectedIndex,
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            //unselectedLabelStyle: TextStyle(color: Colors.grey),
            onTap: _onItemTapped,
          ),
          floatingActionButton: new Visibility(
              visible: Utils.userRole == 1,
              child: FloatingActionButton(
                onPressed: ((Utils.userRole == 1) && argMap["superLevel"] < 10)
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
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 134, 131, 131),
                    Color.fromARGB(255, 54, 52, 52),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0, 1],
                ),
              ),
            ),
            title: Text(
              argMap["title"],
            ),
            elevation: 0,
          ),
          body: new Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: buildGallery(context),
          ),
          floatingActionButton: new Visibility(
              visible: Utils.userRole == 1,
              child: FloatingActionButton(
                onPressed: ((Utils.userRole == 1) && argMap["superLevel"] < 10)
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
    return SafeArea(child: buildPage(context));
  }

  @override
  void dispose() {
    folderName.dispose();
    super.dispose();
  }
}
