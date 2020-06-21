import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class Utils {
  static Map<int, Color> primColor = {
    50: Color.fromRGBO(25, 118, 210, .1),
    100: Color.fromRGBO(25, 118, 210, .2),
    200: Color.fromRGBO(25, 118, 210, .3),
    300: Color.fromRGBO(25, 118, 210, .4),
    400: Color.fromRGBO(25, 118, 210, .5),
    500: Color.fromRGBO(25, 118, 210, .6),
    600: Color.fromRGBO(25, 118, 210, .7),
    700: Color.fromRGBO(25, 118, 210, .8),
    800: Color.fromRGBO(25, 118, 210, .9),
    900: Color.fromRGBO(25, 118, 210, 1),
  };
  static Map<String, int> threadCount = new Map();
  static const String notifyTopic="test1";
  static bool getImageFormats(String isSupported) {
    List<String> imgFrmt = new List();
    imgFrmt.add("jpeg");
    imgFrmt.add("jpeg");
    imgFrmt.add("jpg");
    imgFrmt.add("bmp");
    imgFrmt.add("png");
    imgFrmt.add("gif");
    imgFrmt.add("heif");

    return imgFrmt.contains(isSupported.toLowerCase());
  }

  static String userName = "";
  static int userRole = 1;
  static bool getVideoFormats(String isSupported) {
    List<String> imgFrmt = new List();

    imgFrmt.add("mp4");
    imgFrmt.add("m4a");
    imgFrmt.add("FMP4");
    imgFrmt.add("WebM");
    imgFrmt.add("Matroska");
    imgFrmt.add("MP3");
    imgFrmt.add("Ogg");
    imgFrmt.add("WAV");
    imgFrmt.add("MPEG-TS");
    imgFrmt.add("MPEG-PS");
    imgFrmt.add("FLV");
    imgFrmt.add("AMR");
    return imgFrmt.contains(isSupported.toLowerCase());
  }

  static String getMessageTimerFrmt(int time) {
    DateTime dt = new DateTime.fromMillisecondsSinceEpoch(time);

    String dateFrmt = "";
    String amPm = " am";

    int hour = dt.hour;
    dateFrmt += dt.day < 10 ? "0" + dt.day.toString() : dt.day.toString();
    dateFrmt +=
        "/" + (dt.month < 10 ? "0" + dt.month.toString() : dt.month.toString());
    dateFrmt += "/" + (dt.year.toString());

    if (hour > 12) {
      amPm = " pm";
      hour = hour - 12;
    }
    dateFrmt += " " + (hour < 10 ? "0" + hour.toString() : hour.toString());
    dateFrmt += ":" +
        (dt.minute < 10 ? "0" + dt.minute.toString() : dt.minute.toString());
    dateFrmt += amPm;

    return dateFrmt;
  }

  static String getTimeFrmt(int time) {
    var monthMap = new Map();
    monthMap["01"] = "Jan";
    monthMap["2"] = "Feb";
    monthMap["3"] = "Mar";
    monthMap["4"] = "Apr";
    monthMap["5"] = "May";
    monthMap["6"] = "Jun";
    monthMap["7"] = "Jul";
    monthMap["8"] = "Aug";
    monthMap["9"] = "Sep";
    monthMap["10"] = "Oct";
    monthMap["11"] = "Nov";
    monthMap["12"] = "Dec";

    DateTime dt = new DateTime.fromMillisecondsSinceEpoch(time);
    DateTime todat = new DateTime.now();
    String dateFrmt = "";
    String datemonthyr = "";
    String timeStr = "";
    String dateMonth = "";
    String amPm = " am";

    int hour = dt.hour;
    datemonthyr += dt.day < 10 ? "0" + dt.day.toString() : dt.day.toString();
    datemonthyr +=
        "/" + (dt.month < 10 ? "0" + dt.month.toString() : dt.month.toString());
    datemonthyr += "/" + (dt.year.toString());

    if (hour > 12) {
      amPm = " pm";
      hour = hour - 12;
    }
    timeStr += " " + (hour < 10 ? "0" + hour.toString() : hour.toString());
    timeStr += ":" +
        (dt.minute < 10 ? "0" + dt.minute.toString() : dt.minute.toString());
    timeStr += amPm;

    dateMonth += dt.day < 10 ? "0" + dt.day.toString() : dt.day.toString();
    dateMonth += " " + monthMap[dt.month.toString()];

    if (dt.year == todat.year &&
        dt.day == todat.day &&
        dt.month == todat.month) {
      dateFrmt = timeStr;
    } else if (dt.year == todat.year) {
      dateFrmt = dateMonth;
    } else {
      dateFrmt = datemonthyr;
    }

    return dateFrmt;
  }

  static bool validateLogin(String email, String password) {
    if (email.trim().isNotEmpty) {
      return true;
    }
    if (password.trim().isNotEmpty) {
      return true;
    }
    return false;
  }

  static Widget attachmentWid(String name, File attach, String url, String type,
      BuildContext context, MediaQueryData medQry) {
    if (getImageFormats(type)) {
      return Container(
        width: medQry.size.width * .29,
        height: medQry.size.width * .29,
        child: OutlineButton(
          child: Material(
            child: attach == null
                ? CachedNetworkImage(
                    width: medQry.size.width * .29,
                    height: medQry.size.width * .29,
                    fit: BoxFit.contain,
                    progressIndicatorBuilder: (context, url, progress) =>
                        Image.asset(
                      "assets/imagethumbnail.png",
                      width: medQry.size.width * .29,
                      height: medQry.size.width * .29,
                    ),
                    imageUrl: url,
                  )
                : Image.file(
                    attach,
                    width: medQry.size.width * .29,
                    height: medQry.size.width * .29,
                    fit: BoxFit.cover,
                  ),
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
            clipBehavior: Clip.hardEdge,
          ),
          onPressed: attach != null
              ? null
              : () {
                  Navigator.pushNamed(context, "/photoview",
                      arguments: {"url": url, "name": name});
                },
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0)),
          borderSide: BorderSide(color: Colors.grey),
          padding: EdgeInsets.all(0),
        ),
        margin: EdgeInsets.only(
            left: medQry.size.width * .03, top: medQry.size.width * .03),
      );
    } else if (getVideoFormats(type)) {
      return Container(
        width: medQry.size.width * .29,
        height: medQry.size.width * .29,
        child: OutlineButton(
          child: Material(
            child: Image.asset(
              "assets/videothumbnail.png",
              width: medQry.size.width * .29,
              height: medQry.size.width * .29,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
            clipBehavior: Clip.hardEdge,
          ),
          onPressed: () {
            Navigator.pushNamed(context, "/videoview",
                arguments: {"url": url, "name": name});
          },
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0)),
          borderSide: BorderSide(color: Colors.grey),
          padding: EdgeInsets.all(0),
        ),
        margin: EdgeInsets.only(
            left: medQry.size.width * .03, top: medQry.size.width * .03),
      );
    } else {
      return Container(
        height: medQry.size.width * .29,
        width: medQry.size.width * .29,
        child: OutlineButton(
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0)),
          borderSide: BorderSide(color: Colors.grey),
          child: Material(
            child: Text(type, style: TextStyle(fontSize: 15)),
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
            clipBehavior: Clip.hardEdge,
          ),
          onPressed: () {
            Navigator.pushNamed(context, "/videoview",
                arguments: {"url": url, "name": name});
          },
          padding: EdgeInsets.all(0),
        ),
        margin: EdgeInsets.only(
            left: medQry.size.width * .03, top: medQry.size.width * .03),
      );
    }
  }

/*
static void openFile(File file,String url){
  if(file==null){
    OpenFile.open(filePath)
  }
}
*/
  static Widget isNewMessage(String messageId, SharedPreferences localStore) {
    List notifyList = new List();
    if (localStore.containsKey("notifylist")) {
      notifyList = localStore.getStringList("notifylist");
    }
    if (notifyList != null && notifyList.contains(messageId)) {
      return SizedBox(
          width: 10,
          child: ClipOval(
            child: Material(
              color: Colors.red, // button color
              child: InkWell(
                splashColor: Colors.red, // inkwell color
                child: SizedBox(width: 10, height: 10),
              ),
            ),
          ));
    } else {
      return SizedBox(width: 10);
    }
  }

  static Color getColor(String key) {
    key = key.toLowerCase();
    var colors = new Map();
    colors["a"] = Color.fromRGBO(252, 4, 4, 1);
    colors["b"] = Color.fromRGBO(4, 4, 252, 1);
    colors["c"] = Color.fromRGBO(217, 83, 79, 1);
    colors["d"] = Color.fromRGBO(252, 68, 68, 1);
    colors["e"] = Color.fromRGBO(84, 36, 52, 1);
    colors["f"] = Color.fromRGBO(68, 44, 76, 1);
    colors["g"] = Color.fromRGBO(68, 44, 76, 1);
    colors["h"] = Color.fromRGBO(36, 36, 36, 1);
    colors["i"] = Color.fromRGBO(76, 68, 36, 1);
    colors["j"] = Color.fromRGBO(252, 204, 92, 1);
    colors["k"] = Color.fromRGBO(252, 4, 4, 1);
    colors["l"] = Color.fromRGBO(4, 4, 252, 1);
    colors["m"] = Color.fromRGBO(217, 83, 79, 1);
    colors["n"] = Color.fromRGBO(252, 68, 68, 1);
    colors["o"] = Color.fromRGBO(84, 36, 52, 1);
    colors["p"] = Color.fromRGBO(68, 44, 76, 1);
    colors["q"] = Color.fromRGBO(68, 44, 76, 1);
    colors["r"] = Color.fromRGBO(36, 36, 36, 1);
    colors["s"] = Color.fromRGBO(76, 68, 36, 1);
    colors["t"] = Color.fromRGBO(252, 204, 92, 1);
    colors["u"] = Color.fromRGBO(252, 4, 4, 1);
    colors["v"] = Color.fromRGBO(4, 4, 252, 1);
    colors["w"] = Color.fromRGBO(217, 83, 79, 1);
    colors["x"] = Color.fromRGBO(252, 68, 68, 1);
    colors["y"] = Color.fromRGBO(84, 36, 52, 1);
    colors["z"] = Color.fromRGBO(68, 44, 76, 1);

    if (colors.containsKey(key)) {
      return colors[key];
    } else {
      return Color.fromRGBO(252, 204, 92, 1);
    }
  }

  static Widget getUserBadge(int userRole, double fntsize) {
    if (userRole == 1) {
      return Icon(
        Icons.supervisor_account,
        size: fntsize,
        color: Color.fromRGBO(25, 118, 210, 1),
      );
    } else if (userRole == 2) {
      return Icon(
        Icons.verified_user,
        size: fntsize,
        color: Color.fromRGBO(25, 118, 210, 1),
      );
    } else {
      return Icon(
        Icons.person,
        size: fntsize,
        color: Color.fromRGBO(25, 118, 210, 1),
      );
    }
  }

  static bool isDeleteAvail(int threadTime) {
    DateTime todat = new DateTime.now();
    int diffTime = todat.millisecondsSinceEpoch - threadTime;
    return diffTime < 28800000;
  }

  static Future<void> sendPushNotification(
      String title, String body, String screenName, String docId) async {
  
    final SharedPreferences localStore = await SharedPreferences.getInstance();
    String ownerId = localStore.getString("userId");
    String serverToken =
        "AAAA7_Sx8pg:APA91bE1afmUpIcNCCe9leKNrNOHut5JajyvKmUBRKxdfELopzap3XJaHw4Ih_Cj6EzebCGi8QeSA_m6kXIvRq4WiGiqDYj7c-G8YklDX9feOm1eusmN0eIPa914m4APgLVC5Iqx96Nw";
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'screen': screenName,
            'docid': docId,
            'ownerId': ownerId
          },
          'to': "/topics/"+notifyTopic,
        },
      ),
    );
  }

  static String getRoleString(String role) {
    switch (role) {
      case "1":
        return "Admin";
        break;
      case "2":
        return "Faculty";
        break;
      case "3":
        return "Member";
        break;
    }
    return "";
  }

  static Future<void> removeNotifyItem(String docId) async {
    final SharedPreferences localStore = await SharedPreferences.getInstance();
    List<String> listDocId = new List<String>();
    if (localStore.containsKey("notifylist")) {
      listDocId = localStore.getStringList("notifylist");
    }
    if (listDocId.contains(docId)) {
      listDocId.remove(docId);
    }
    localStore.setStringList("notifylist", listDocId);
  }

  static void addNotificationId(String docId, String ownerId) async {
    final SharedPreferences localStore = await SharedPreferences.getInstance();
    if (ownerId != null && ownerId != localStore.getString("userId")) {
      List<String> listDocId = new List<String>();
      if (localStore.containsKey("notifylist")) {
        listDocId = localStore.getStringList("notifylist");
      }
      if (!listDocId.contains(docId)) {
        listDocId.add(docId);
      }
      localStore.setStringList("notifylist", listDocId);
    }
  }

  static Widget getNewMessageCount(SharedPreferences localStore) {
    List notifiCntList = new List();
    if (localStore != null && localStore.containsKey("notifylist")) {
      notifiCntList = localStore.getStringList("notifylist");
    }
    if (notifiCntList != null && notifiCntList.length > 0) {
      return Text("Messages (" + notifiCntList.length.toString() + ")");
    } else {
      return Text("Messages");
    }
  }

  static void showLoadingPop(BuildContext context) {
    showLoadingPopText(context, "Uploading file");
  }

  static void showLoadingPopText(BuildContext context, String text) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext bCont) {
          return new Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(95)),
              child: AlertDialog(
                  title: Text(
                    text,
                    textAlign: TextAlign.center,
                  ),
                  content: SizedBox(
                    child: new LinearProgressIndicator(),
                    width: 10,
                    height: 10,
                  )));
        });
  }

  static Widget buildGalleryFileItem(
      BuildContext context, String url, String name, String type) {
    if (getImageFormats(type)) {
      return Container(
        child: FlatButton(
          child: Column(
            children: [
              Material(
                child: CachedNetworkImage(
                  width: 100,
                  height: 86,
                  fit: BoxFit.fill,
                  progressIndicatorBuilder: (context, url, progress) =>
                      Image.asset(
                    "assets/imagethumbnail.png",
                    width: 120,
                    height: 86,
                  ),
                  imageUrl: url,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
                clipBehavior: Clip.hardEdge,
              ),
              Padding(
                  padding: EdgeInsets.only(left: 15, right: 5),
                  child: Text(name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontSize: 13),
                      textAlign: TextAlign.center))
            ],
          ),

          onPressed: () {
            Navigator.pushNamed(context, "/photoview",
                arguments: {"url": url, "name": name});
          },
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0)),
          //  borderSide: BorderSide(color: Colors.grey),
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        ),
      );
    } else if (getVideoFormats(type)) {
      return Container(
        child: FlatButton(
          child: Column(
            children: [
              Material(
                child: Image.asset(
                  "assets/videothumbnail.png",
                  width: 120,
                  height: 86,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
                clipBehavior: Clip.hardEdge,
              ),
              Padding(
                  padding: EdgeInsets.only(left: 15, right: 5),
                  child: Text(name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13),
                      maxLines: 2,
                      textAlign: TextAlign.center))
            ],
          ),

          onPressed: () {
            openFile(url, name, context);
          },
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0)),
          //  borderSide: BorderSide(color: Colors.grey),
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        ),
      );
    } else if ("pdf".contains(type)) {
      return Container(
        child: FlatButton(
          child: Column(
            children: [
              Material(
                child: Image.asset(
                  "assets/pdfthumbnail.png",
                  width: 120,
                  height: 86,
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
                clipBehavior: Clip.hardEdge,
              ),
              Padding(
                  padding: EdgeInsets.only(left: 15, right: 5),
                  child: Text(name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontSize: 13),
                      textAlign: TextAlign.center))
            ],
          ),

          onPressed: () {
            openFile(url, name, context);
          },
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0)),
          //  borderSide: BorderSide(color: Colors.grey),
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        ),
      );
    } else if ("youtube".contains(type)) {
      return Container(
        child: FlatButton(
          child: Column(
            children: [
              Material(
                child: Image.asset(
                  "assets/youtubethumbnail.png",
                  width: 120,
                  height: 86,
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
                clipBehavior: Clip.hardEdge,
              ),
              Padding(
                  padding: EdgeInsets.only(left: 15, right: 5),
                  child: Text(name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontSize: 13),
                      textAlign: TextAlign.center))
            ],
          ),
          onPressed: () {
            _launchInBrowser(url);
          },
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0)),
          //  borderSide: BorderSide(color: Colors.grey),
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        ),
      );
    }
  }

  static Future<File> fileAsset(String url, String filename) async {
    Directory tempDir = await getTemporaryDirectory();
    http.Client client = new http.Client();
    var req = await client.get(Uri.parse(url));
    var bytes = req.bodyBytes;
    File tempFile = File('${tempDir.path}/' + filename);
    await tempFile.writeAsBytes(bytes, flush: true);
    return tempFile;
  }

  static Future<void> openFile(
      String filePath, String filename, BuildContext context) async {
    showLoadingPopText(context, "Loading File ");
    try {
      fileAsset(filePath, filename).then((file) {
        OpenFile.open(file.path);
        Navigator.pop(context);
      });
    } catch (e) {
      Navigator.pop(context);
    }
  }

  static Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  static void getAllComments() async {
    threadCount=new Map();
    List<DocumentSnapshot> commentsDoc = null;
    final QuerySnapshot userDetails =
        await Firestore.instance.collection('comments').getDocuments();
    commentsDoc = userDetails.documents;

    if (commentsDoc != null && commentsDoc.length > 0) {
      for (int i = 0; i < commentsDoc.length; i++) {
        String threadId = commentsDoc[i]["thread_id"];
        if (threadCount != null && threadCount.containsKey(threadId)) {
          var cnt = threadCount[threadId];
          threadCount[threadId] = cnt + 1;
        } else {
          threadCount[threadId] = 1;
        }
      }
    }
  }

  static void updateCommentCount(String threadId, bool increase) {
    if (threadCount != null && threadCount.containsKey(threadId)) {
      var cnt = threadCount[threadId];
      if (increase) {
        threadCount[threadId] = cnt + 1;
      } else {
        threadCount[threadId] = cnt - 1;
      }
    } else {
      threadCount[threadId] = 1;
    }
  }
}
