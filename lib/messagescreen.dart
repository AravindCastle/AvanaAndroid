import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'Utils.dart';

class MessagePage extends StatefulWidget {
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  MediaQueryData medQry = null;
  SharedPreferences prefs;
  String userName = "";
  int userRole = 1;
  bool showSearchBar = false;
  TextEditingController searchBarController = new TextEditingController();
  String searchText = null;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Utils.getAllComments();
  }

  void getUserName() async {
    prefs = await SharedPreferences.getInstance();
    if (this.mounted) {
      setState(() {
        userName = prefs.getString("name");
        userRole = prefs.getInt("role");
      });
    }
  }

  Widget messageItem(DocumentSnapshot messageDoc, BuildContext context) {
    if (searchText == null ||
        searchText.trim() == "" ||
        (messageDoc["ownername"]
                .toString()
                .toLowerCase()
                .contains(searchText.trim()) ||
            messageDoc["subject"]
                .toString()
                .toLowerCase()
                .contains(searchText.trim()))) {
      var children2 = <Widget>[
        SizedBox(width: 15),
        messageDoc["attachments"].length > 0
            ? Text(
                messageDoc["attachments"].length.toString() + " Attachment",
                style: TextStyle(fontSize: 14),
              )
            : SizedBox(),
        Spacer(),
        Utils.threadCount.containsKey(messageDoc.id)
            ? Text(
                Utils.threadCount[messageDoc.id].toString() +
                    " "
                        "Comment",
                style: TextStyle(fontSize: 14),
              )
            : SizedBox(),
      ];
      return new GestureDetector(
          child: Card(
              elevation: 1,
              child: new Container(
                height: 190,
                child: new Padding(
                    padding:
                        EdgeInsets.only(top: 10, bottom: 10, left: 8, right: 8),
                    child: new Column(children: [
                      Row(children: [
                        Utils.isNewMessage(messageDoc.id, prefs),
                        SizedBox(
                          width: 30,
                          child: Icon(
                            Icons.check_circle,
                            size: 16,
                            color: messageDoc["ownerrole"] == 1
                                ? Colors.redAccent
                                : Colors.blueAccent,
                          ),
                        ),
                        SizedBox(
                          width: medQry.size.width * .62,
                          child: Text(messageDoc["ownername"],
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style:
                                  TextStyle(fontSize: 19, color: Colors.black)),
                        ),
                        SizedBox(
                          width: medQry.size.width * .19,
                          child: Text(
                            Utils.getTimeFrmt(messageDoc["created_time"]),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(height: medQry.size.height * .01),
                      Row(
                        children: <Widget>[
                          SizedBox(width: 15),
                          SizedBox(
                            width: medQry.size.width * .89,
                            child: Text(
                              messageDoc["subject"],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(6, 8, 0, 5),
                            child: Utils.attachmentPreviewSlider(
                                context,
                                messageDoc["attachments"].length > 0
                                    ? messageDoc
                                    : null,
                                messageDoc["subject"]),
                            height: 100,
                            width: 120,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                              width: 200,
                              height: 70,
                              child: Text(
                                messageDoc["content"],
                                maxLines: 3,
                              ))
                        ],
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children2,
                      )
                    ])),
              )),
          onTap: () {
            setState(() {
              searchBarController.clear();
              searchText = null;
              showSearchBar = false;
            });
            Navigator.pushNamed(context, "/messageview",
                arguments: messageDoc.id);
          });
    } else {
      return SizedBox();
    }
  }

  int _selectedIndex = 1;
  void _onItemTapped(int index) {
    Utils.bottomNavAction(index, context);
  }

  Widget build(BuildContext context) {
    getUserName();
    medQry = MediaQuery.of(context);
    return WillPopScope(
        onWillPop: () async => false,
        child: SafeArea(
            child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            actions: [
              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => {
                        setState(() {
                          showSearchBar = true;
                          _scrollController.jumpTo(0);
                        })
                      })
            ],
            leading: IconButton(
              icon: Utils.userProfilePic(Utils.userId, 14),
              onPressed: () {
                Utils.showUserPop(context);
              },
            ),
            title: Utils.getNewMessageCount(prefs, context),
          ),
          body: Column(
            children: [
              Visibility(
                  visible: showSearchBar,
                  child: Padding(
                    padding: EdgeInsets.all(7),
                    child: Row(children: [
                      SizedBox(
                          height: 45,
                          width: medQry.size.width * .80,
                          child: new TextField(
                            maxLines: 1,
                            autofocus: true,
                            controller: searchBarController,
                            onChanged: (newval) => {
                              setState(() {
                                searchText = newval;
                              })
                            },
                            decoration: new InputDecoration(
                              border: new OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(10.0),
                                ),
                              ),
                              hintText: "Search",
                            ),
                          )),
                      Spacer(),
                      IconButton(
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.black,
                          ),
                          onPressed: () => {
                                setState(() {
                                  searchBarController.clear();
                                  searchText = null;
                                  showSearchBar = false;
                                })
                              })
                    ]),
                  )),
              Expanded(
                  child: new StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Threads')
                    .orderBy("created_time", descending: true)
                    .limit(showSearchBar ? 1000 : 200)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData)
                    return SizedBox(
                        child: Text(
                          "Loading ....",
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        height: 5);
                  return new ListView(
                    controller: _scrollController,
                    children: snapshot.data.docs.map((document) {
                      return messageItem(document, context);
                    }).toList(),
                  );
                },
              )),
            ],
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
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, "/messageeditor");
            },
            child: Icon(Icons.add, color: Theme.of(context).primaryColor),
            backgroundColor: Theme.of(context).secondaryHeaderColor,
          ),
        )));
  }
}
