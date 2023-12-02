import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Utils.dart';

class FeedPage extends StatefulWidget {
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  MediaQueryData medQry = null;
  int _selectedIndex = 0;
  String currentSort = "1";
  void _onItemTapped(int index) {
    Utils.bottomNavAction(index, context);
  }

  @override
  void initState() {
    super.initState();
    Utils.isNewResourceAdded();
    Utils.getAllFeedComments(setSt);
  }

  void setSt() {
    setState(() {});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFeedStream() {
    DateTime currentDate = new DateTime.now();
    if ("1" == currentSort) {
      return FirebaseFirestore.instance
          .collection('feed')
          .orderBy("created_time", descending: true)
          .limit(300)
          .snapshots();
    } else if ("2" == currentSort) {
      currentDate = currentDate.subtract(const Duration(days: 7));
      return FirebaseFirestore.instance
          .collection('feed')
          .where("created_time",
              isLessThanOrEqualTo: currentDate.millisecondsSinceEpoch)
          .orderBy("created_time", descending: true)
          .limit(300)
          .snapshots();
    } else if ("3" == currentSort) {
      currentDate = currentDate.subtract(const Duration(days: 31));
      return FirebaseFirestore.instance
          .collection('feed')
          .where("created_time",
              isLessThanOrEqualTo: currentDate.millisecondsSinceEpoch)
          .orderBy("created_time", descending: true)
          .limit(300)
          .snapshots();
    } else if ("4" == currentSort) {
      currentDate = currentDate.subtract(const Duration(days: 92));
      return FirebaseFirestore.instance
          .collection('feed')
          .where("created_time",
              isLessThanOrEqualTo: currentDate.millisecondsSinceEpoch)
          .orderBy("created_time", descending: true)
          .limit(300)
          .snapshots();
    } else if ("5" == currentSort) {
      currentDate = currentDate.subtract(const Duration(days: 92));
      return FirebaseFirestore.instance
          .collection('feed')
          .orderBy("created_time", descending: false)
          .limit(300)
          .snapshots();
    }
  }

  List<Widget> getFeeds(QuerySnapshot snapshot) {
    List<Widget> result = List<Widget>.empty();

    snapshot.docs.forEach((document) {
      //result.add();
    });

    return result;
  }

  Widget build(BuildContext context) {
    medQry = MediaQuery.of(context);
    return WillPopScope(
        onWillPop: () async => false,
        child: SafeArea(
            child: Scaffold(
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
            actions: [
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
              )
            ],
            title: Text('Feed'),
          ),
          body: new StreamBuilder<QuerySnapshot>(
            stream: getFeedStream(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return SizedBox(
                    child: new LinearProgressIndicator(), height: 5);
              return new ListView(
                children: snapshot.data.docs.map((document) {
                  if (document.id == null || document["ownername"] == null) {
                    return SizedBox();
                  } else {
                    return GestureDetector(
                        onTap: () => {
                              Navigator.pushNamed(context, "/feeddetails",
                                  arguments: document.id)
                            },
                        child: new Padding(
                          padding: EdgeInsets.all(10),
                          child: new Card(
                              elevation: 9,
                              child: new Container(
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
                                        width: 4.0,
                                        style: BorderStyle.solid), //Border.all
                                    /*** The BorderRadius widget  is here ***/
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      document["feedtype"] == 1
                                          ? new Container(
                                              child: RichText(
                                                text: TextSpan(
                                                  text: document["ownername"],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                      fontSize: 16),
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            document["content"],
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color:
                                                                Colors.black)),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : new Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              5, 0, 0, 0),
                                                      child: Row(children: [
                                                        Utils.userProfilePic(
                                                            document["owner"],
                                                            12),
                                                        SizedBox(
                                                          width: 7,
                                                        ),
                                                        Text(
                                                            document[
                                                                "ownername"],
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 18))
                                                      ])),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              5, 0, 0, 0),
                                                      child: Text(
                                                          Utils.getMessageTimerFrmt(
                                                              document[
                                                                  "created_time"]),
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black45,
                                                              fontSize: 12))),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              5, 0, 0, 0),
                                                      child: Utils.constructText(
                                                          document["content"],
                                                          TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.black))
                                                      /*Text(
                                                          document["content"],
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black))*/
                                                      ),
                                                  document[
                                                                  "attachments"]
                                                              .length >
                                                          0
                                                      ? new Container(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 5, 0, 5),
                                                          height: 100,
                                                          width: medQry
                                                                  .size.width *
                                                              .88,
                                                          child: Utils
                                                              .attachmentPreviewSlider(
                                                                  context,
                                                                  document,
                                                                  null))
                                                      : SizedBox()
                                                ],
                                              ),
                                            ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(children: [
                                        document["attachments"].length > 0
                                            ? Text(
                                                document["attachments"]
                                                        .length
                                                        .toString() +
                                                    " Attachment",
                                                style: TextStyle(fontSize: 14),
                                              )
                                            : SizedBox(),
                                        Spacer(),
                                        Utils.feedCommentCount
                                                .containsKey(document.id)
                                            ? Text(
                                                Utils.feedCommentCount[
                                                            document.id]
                                                        .toString() +
                                                    " "
                                                        "Comment",
                                                style: TextStyle(fontSize: 14),
                                              )
                                            : SizedBox(),
                                      ]),
                                    ],
                                  ))),
                        ));
                  }
                }).toList(),
              );
            },
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
          floatingActionButton: new Visibility(
              visible: Utils.userRole == 1,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/feededitor");
                },
                child: Icon(Icons.add, color: Theme.of(context).primaryColor),
                backgroundColor: Theme.of(context).secondaryHeaderColor,
              )),
        )));
  }
}
