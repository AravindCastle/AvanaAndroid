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
  String currentSort = "1";
  @override
  void initState() {
    super.initState();
    Utils.getAllComments();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMsgStream() {
    DateTime currentDate = new DateTime.now();
    if ("1" == currentSort) {
      return FirebaseFirestore.instance
          .collection('Threads')
          .orderBy("created_time", descending: true)
          .limit(showSearchBar ? 1000 : 200)
          .snapshots();
    } else if ("2" == currentSort) {
      currentDate = currentDate.subtract(const Duration(days: 7));
      return FirebaseFirestore.instance
          .collection('Threads')
          .where("created_time",
              isLessThanOrEqualTo: currentDate.millisecondsSinceEpoch)
          .orderBy("created_time", descending: true)
          .limit(200)
          .snapshots();
    } else if ("3" == currentSort) {
      currentDate = currentDate.subtract(const Duration(days: 31));
      return FirebaseFirestore.instance
          .collection('Threads')
          .where("created_time",
              isLessThanOrEqualTo: currentDate.millisecondsSinceEpoch)
          .orderBy("created_time", descending: true)
          .limit(200)
          .snapshots();
    } else if ("4" == currentSort) {
      currentDate = currentDate.subtract(const Duration(days: 92));
      return FirebaseFirestore.instance
          .collection('Threads')
          .where("created_time",
              isLessThanOrEqualTo: currentDate.millisecondsSinceEpoch)
          .orderBy("created_time", descending: true)
          .limit(200)
          .snapshots();
    } else if ("5" == currentSort) {
      currentDate = currentDate.subtract(const Duration(days: 92));
      return FirebaseFirestore.instance
          .collection('Threads')
          .orderBy("created_time", descending: false)
          .limit(200)
          .snapshots();
    }
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
          child: new Padding(
              padding: EdgeInsets.all(10),
              child: Card(
                elevation: 7,
                child: new Container(
                    padding: EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 255, 255, 255),
                          Color.fromARGB(255, 222, 222, 222),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [0, 1],
                      ),
                      border: Border.all(
                          color: Colors.transparent,
                          width: 4,
                          style: BorderStyle.none), //Border.all
                      /*** The BorderRadius widget  is here ***/
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    constraints: BoxConstraints(
                        minHeight: 80,
                        maxHeight:
                            messageDoc["attachments"].length > 0 ? 190 : 125),
                    child: new Column(children: [
                      Row(children: [
                        Utils.isNewMessage(messageDoc.id, prefs),
                        Utils.userProfilePic(messageDoc["owner"], 12),
                        SizedBox(
                          width: 7,
                        ),
                        SizedBox(
                          width: medQry.size.width * .59,
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
                          SizedBox(width: 10),
                          SizedBox(
                            width: medQry.size.width * .81,
                            child: Text(
                              messageDoc["subject"],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          messageDoc["attachments"].length > 0
                              ? Container(
                                  padding: EdgeInsets.fromLTRB(6, 8, 0, 5),
                                  child: Utils.attachmentPreviewSlider(
                                      context,
                                      messageDoc["attachments"].length > 0
                                          ? messageDoc
                                          : null,
                                      messageDoc["subject"]),
                                  height: 80,
                                  width: 120,
                                )
                              : SizedBox(
                                  width: 0,
                                ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                              width: 200,
                              height: 35,
                              child: Text(
                                messageDoc["content"],
                                style: TextStyle(color: Colors.black54),
                                maxLines: 2,
                              ))
                        ],
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children2,
                      ),
                      SizedBox(
                        height: 9,
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
            actions: [
              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => {
                        setState(() {
                          showSearchBar = true;
                          _scrollController.jumpTo(0);
                        })
                      }),
              PopupMenuButton(
                initialValue: 1,
                onSelected: (val) => {
                  setState(() {
                    currentSort = val;
                  })
                  //val == "1" ? showEditSheet() : deleteAlert(context)
                },
                itemBuilder: (context) {
                  var list = List<PopupMenuEntry<Object>>();
                  list.add(
                    PopupMenuItem(
                      child: Text("Recent post"),
                      value: "1",
                    ),
                  );
                  list.add(
                    PopupMenuDivider(
                      height: 10,
                    ),
                  );
                  list.add(
                    PopupMenuItem(
                      child: Text("1 Week before"),
                      value: "2",
                    ),
                  );
                  list.add(
                    PopupMenuDivider(
                      height: 10,
                    ),
                  );
                  list.add(
                    PopupMenuItem(
                      child: Text("1 Month before"),
                      value: "3",
                    ),
                  );
                  list.add(
                    PopupMenuDivider(
                      height: 10,
                    ),
                  );
                  list.add(
                    PopupMenuItem(
                      child: Text("3 Months before"),
                      value: "4",
                    ),
                  );
                  list.add(
                    PopupMenuDivider(
                      height: 10,
                    ),
                  );
                  list.add(
                    PopupMenuItem(
                      child: Text("Sort by date"),
                      value: "5",
                    ),
                  );

                  return list;
                },
                icon: Icon(Icons.sort_outlined),
              ),
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
                stream: getMsgStream(),
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
          bottomNavigationBar: Container(
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
            child: BottomNavigationBar(
              items: Utils.bottomNavItem(),
              currentIndex: _selectedIndex,
              backgroundColor: Color.fromARGB(255, 116, 115, 115),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
              //unselectedLabelStyle: TextStyle(color: Colors.grey),
              onTap: _onItemTapped,
            ),
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
