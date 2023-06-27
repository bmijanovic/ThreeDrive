import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_icon/file_icon.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:threecloud/models/invitation.dart';
import 'package:threecloud/screens/edit_file_screen.dart';
import 'package:threecloud/screens/family_adding_dialog.dart';
import '../models/directory.dart';
import 'package:threecloud/screens/file_details_screen.dart';
import '../models/resource.dart';
import '../widgets/floating_button.dart';
import 'content_sharing_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import 'directory_picker_screen.dart';

class HomeScreen extends StatefulWidget {
  final String currentPath;

  HomeScreen({super.key, required String this.currentPath});

  @override
  _HomeScreenState createState() => _HomeScreenState(currentPath);
}

class _HomeScreenState extends State<HomeScreen> {
  Future<dynamic>? elements;
  Future<dynamic>? elementsShared;
  Future<dynamic>? verificationRequests;
  bool isOpening = false;
  var lifecycleEventHandler;
  String currentPath;
  String title = "";
  List<String> currentPathShared = ["shared"];
  final List<Tab> myTabs = <Tab>[
    const Tab(
      text: "Home",
      icon: Icon(Icons.home_filled),
    ),
    const Tab(
      text: "Shared",
      icon: Icon(Icons.share),
    ),
    const Tab(
      text: "Family",
      icon: Icon(Icons.group),
    ),
    const Tab(
      text: "Logout",
      icon: Icon(Icons.logout),
    ),
  ];
  int _activeIndex = 0;

  _HomeScreenState(this.currentPath) {
    title = currentPath;
  }

  @override
  void initState() {
    super.initState();

    getResources();
    getSharedResources();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getResources() async {
    elements = Resource.getMyResources(currentPath);
    setState(() {});
  }

  getSharedResources() async {
    if (currentPathShared.length == 1) {
      elementsShared = Resource.getSharedResource();
    } else {
      elementsShared = Resource.getMyResources(currentPathShared.last);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: MaterialApp(
            home: DefaultTabController(
                length: 4,
                child: Scaffold(
                    appBar: AppBar(
                        title: Text(title),
                        elevation: 0.0,
                        iconTheme: IconThemeData(color: Colors.white, size: 30),
                        leading: shouldShowBack(),
                        actions: <Widget>[
                          if(_activeIndex==0)
                        IconButton(onPressed: ((){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ContentSharingScreen(
                                      action:
                                      "DIRECTORY",
                                      path: currentPath,
                                    )),
                          ).then((value) => this);
                        }), icon: Icon(Icons.group_add)),

                      ],
                        ),
                    bottomNavigationBar: menu(),
                    body: TabBarView(children: [
                      Container(child: home()),
                      Container(child: shared()),
                      Container(child: family()),
                      Container(child: Icon(Icons.directions_bike)),
                    ])))));
  }

  Future<void> deleteFolder(String s) async {
    try {
      await Directory.delete(s);
      Fluttertoast.showToast(
        msg: 'Directory created deleted',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_activeIndex == 0) {
      if (currentPath.contains("/")) {
        setState(() {
          List<String> folders = currentPath.split('/');
          folders.removeLast();
          currentPath = folders.join('/');
          updateTitle(0);
          getResources();
        });
        return false;
      } else {
        return (await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Are you sure?'),
                content: const Text('Do you want to exit an App'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => exit(0),
                    child: const Text('Yes'),
                  ),
                ],
              ),
            )) ??
            false;
      }
    } else if (_activeIndex == 1) {
      if (currentPathShared.length > 1) {
        setState(() {
          currentPathShared.removeLast();
          updateTitle(1);
          getSharedResources();
        });
        return false;
      } else {
        return (await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Are you sure?'),
                content: const Text('Do you want to exit an App'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => exit(0),
                    child: const Text('Yes'),
                  ),
                ],
              ),
            )) ??
            false;
      }
    } else {
      return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Do you want to exit an App'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => exit(0),
                  child: const Text('Yes'),
                ),
              ],
            ),
          )) ??
          false;
    }
  }

  Widget home() {
    return FutureBuilder<dynamic>(
        future: elements, // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          // AsyncSnapshot<Your object type>
          if (snapshot.connectionState == ConnectionState.waiting ||
              isOpening) {
            return Scaffold(
              body: Center(
                child: Container(
                    width: 200,
                    height: 200,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.blueAccent,
                          semanticsLabel: "Loading",
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Loading",
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        )
                      ],
                    )),
              ),
            );
          } else {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Scaffold(
                  body: Scaffold(
                body: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(8.0),
                    children: [
                      if (snapshot.hasData)
                        for (var i in (snapshot.data!).directories)
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  currentPath = i;
                                  updateTitle(_activeIndex);
                                  elements =
                                      Resource.getMyResources(currentPath);
                                });
                              },
                              onLongPress: () => showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => Dialog(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              const Text('Actions'),
                                              const SizedBox(height: 15),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Edit'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  deleteFolder(i).whenComplete(
                                                      () => getResources());
                                                  ;
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Delete'),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ContentSharingScreen(
                                                                action:
                                                                    "DIRECTORY",
                                                                path: i,
                                                              )),
                                                    ).then((value) => this);
                                                  },
                                                  child: const Text('Share')),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                              child: Column(children: [
                                const Expanded(
                                    child: Icon(
                                  IconData(
                                    0xE02F,
                                    fontFamily: 'Seti',
                                    fontPackage: 'file_icon',
                                  ),
                                  color: Colors.amber,
                                  size: 70,
                                )),
                                const SizedBox(height: 10),
                                Text("${i.toString().split("/").last}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ))
                              ])),
                      if (snapshot.hasData)
                        for (var i in (snapshot.data!).files)
                          GestureDetector(
                              onTap: () async {
                                setState(() {
                                  isOpening = true;
                                });
                                String dir =
                                    (await getTemporaryDirectory()).path;
                                Resource.downloadResource(i, downloadPath: dir)
                                    .whenComplete(() {
                                  setState(() {
                                    isOpening = false;
                                  });
                                  OpenFilex.open(dir +
                                      "/" +
                                      (i.split("/")[i.split("/").length - 1]));
                                });
                              },
                              onLongPress: () => showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => Dialog(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: <Widget>[
                                                  const Text('Actions'),
                                                  const SizedBox(height: 15),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (
                                                                context) =>
                                                                EditFileScreen(
                                                                  current_path: i,
                                                                )),
                                                      ).then((value) =>
                                                          Navigator.pop(
                                                              context));
                                                    },
                                                    child: const Text('Edit'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Resource.delete(
                                                          i, currentPath)
                                                          .whenComplete(
                                                              () =>
                                                              getResources());
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Delete'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => DirectoryPickerScreen(
                                                            currentPath: "",
                                                            content: i,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: const Text('Move'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (
                                                                context) =>
                                                                FileDetailsScreen(
                                                                  filePath: i,
                                                                )),
                                                      );
                                                    },
                                                    child: const Text(
                                                        'Details'),
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (
                                                                  context) =>
                                                                  ContentSharingScreen(
                                                                      action:
                                                                      "RESOURCE",
                                                                      path: i)),
                                                        ).then((value) => this);
                                                      },
                                                      child: const Text(
                                                          'Share')),
                                                  TextButton(
                                                    onPressed: () {
                                                      Resource.downloadResource(
                                                          i)
                                                          .whenComplete(() =>
                                                      {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                            "File downloaded successfully!",
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                            ToastGravity
                                                                .CENTER,
                                                            timeInSecForIosWeb:
                                                            1,
                                                            backgroundColor:
                                                            Colors.red,
                                                            textColor:
                                                            Colors.white,
                                                            fontSize: 16.0)
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                        'Download'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Close'),
                                                  ),
                                                ],
                                              ),

                                        ),
                                      )),
                              child: Column(children: [
                                Expanded(
                                    child: FileIcon(
                                  i,
                                  size: 70,
                                )),
                                const SizedBox(height: 10),
                                Text("${i.toString().split("/").last}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ))
                              ]))
                    ]),
                floatingActionButton: FloatingButton(
                    currentPath: currentPath + "/", homeScreen: getResources),
              ));
            }
          }
        });
  }

  Widget shared() {
    return FutureBuilder<dynamic>(
        future: elementsShared, // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          // AsyncSnapshot<Your object type>
          if (snapshot.connectionState == ConnectionState.waiting ||
              isOpening) {
            return Scaffold(
              body: Center(
                child: Container(
                    width: 200,
                    height: 200,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.blueAccent,
                          semanticsLabel: "Loading",
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Loading",
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        )
                      ],
                    )),
              ),
            );
          } else {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Scaffold(
                  body: Scaffold(
                body: GridView.count(
                    // Create a grid with 2 columns. If you change the scrollDirection to
                    // horizontal, this produces 2 rows.
                    crossAxisCount: 2,
                    // Generate 100 widgets that display their index in the List.
                    padding: const EdgeInsets.all(8.0),
                    children: [
                      if (snapshot.hasData)
                        for (var i in (snapshot.data!).directories)
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  currentPathShared.add(i);
                                  updateTitle(1);
                                  getSharedResources();
                                });
                              },
                              onLongPress: () => showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => Dialog(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              const Text('Actions'),
                                              const SizedBox(height: 15),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Edit'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  deleteFolder(i).whenComplete(
                                                      () => getResources());
                                                  ;
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Delete'),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ContentSharingScreen(
                                                                action:
                                                                    "DIRECTORY",
                                                                path: i,
                                                              )),
                                                    ).then((value) => this);
                                                  },
                                                  child: const Text('Share')),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                              child: Column(children: [
                                const Expanded(
                                    child: Icon(
                                  IconData(
                                    0xE02F,
                                    fontFamily: 'Seti',
                                    fontPackage: 'file_icon',
                                  ),
                                  color: Colors.amber,
                                  size: 70,
                                )),
                                const SizedBox(height: 10),
                                Text("${i.toString().split("/").last}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ))
                              ])),
                      if (snapshot.hasData)
                        for (var i in (snapshot.data!).files)
                          GestureDetector(
                              onTap: () async {
                                setState(() {
                                  isOpening = true;
                                });
                                String dir =
                                    (await getTemporaryDirectory()).path;
                                Resource.downloadResource(i, downloadPath: dir)
                                    .whenComplete(() {
                                  setState(() {
                                    isOpening = false;
                                  });
                                  OpenFilex.open(dir +
                                      "/" +
                                      (i.split("/")[i.split("/").length - 1]));
                                });
                              },
                              onLongPress: () => showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => Dialog(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              const Text('Actions'),
                                              const SizedBox(height: 15),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            FileDetailsScreen(
                                                              filePath: i,
                                                            )),
                                                  );
                                                },
                                                child: const Text('Details'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Resource.downloadResource(i)
                                                      .whenComplete(() => {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "File downloaded successfully!",
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                backgroundColor:
                                                                    Colors.red,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0)
                                                          });
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Download'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                              child: Column(children: [
                                Expanded(
                                    child: FileIcon(
                                  i,
                                  size: 70,
                                )),
                                const SizedBox(height: 10),
                                Text("${i.toString().split("/").last}",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ))
                              ]))
                    ]),
              ));
            }
          }
        });
  }

  Widget family() {
    return FutureBuilder<dynamic>(
        future: verificationRequests, // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          // AsyncSnapshot<Your object type>
          if (snapshot.connectionState == ConnectionState.waiting ||
              isOpening) {
            return Scaffold(
              body: Center(
                child: Container(
                    width: 200,
                    height: 200,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Colors.blueAccent,
                          semanticsLabel: "Loading",
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Loading",
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        )
                      ],
                    )),
              ),
            );
          } else {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Scaffold(
                  body: Scaffold(
                    body: Center(
                      child: Column(
                        children: [
                          Padding(padding: EdgeInsets.all(8.0),child:Text("Verification Requests",style: TextStyle(color: Colors.black,fontSize: 25,fontWeight: FontWeight.w500,))),

                          Card(
                            child: SizedBox(
                              width: 350,
                              height: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                              Padding(padding: EdgeInsets.all(8.0),child:Text("vukasinb7",style: TextStyle(color: Colors.black,fontSize: 22,fontWeight: FontWeight.w400,))),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Color(0xff94d500),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.done,
                                              color: Colors.black,
                                            ),
                                            onPressed: () {
                                            },
                                          ),
                                        ),),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.red,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.black,
                                            ),
                                            onPressed: () {
                                            },
                                          ),
                                        ),),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),

                    floatingActionButton: FloatingActionButton( onPressed: (){
                      showDialog<String>(
                          context: context,
                          builder: (BuildContext context) =>FamilyEmailPopup(context));}, child: const Icon(Icons.add)),
                  ));
            }
          }
        });
  }

  Widget menu() {
    return Container(
      color: Color(0xFF3F5AA6),
      child: TabBar(
        onTap: (index) {
          if (index == 0 && _activeIndex == 0) {
            if (currentPath.contains("/")) {
              setState(() {
                currentPath = currentPath.split("/")[0];
                updateTitle(0);
                getResources();
              });
            }
          }
          if (index == 1 && _activeIndex == 1) {
            if (currentPathShared.length > 1) {
              setState(() {
                currentPathShared = ["shared"];
                updateTitle(0);
                getSharedResources();
              });
            }
          }
          _activeIndex = index;
          setState(() {
            updateTitle(index);
          });
        },
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.all(5.0),
        indicatorColor: Colors.blue,
        tabs: const [
          Tab(
            text: "Home",
            icon: Icon(Icons.home_filled),
          ),
          Tab(
            text: "Shared",
            icon: Icon(Icons.share),
          ),
          Tab(
            text: "Family",
            icon: Icon(Icons.group),
          ),
          Tab(
            text: "Logout",
            icon: Icon(Icons.logout),
          ),
        ],
      ),
    );
  }

  void updateTitle(int index) {
    switch (_activeIndex) {
      case 0:
        {
          title = currentPath;
        }
        break;
      case 1:
        {
          List<String> name = [];
          for (var item in currentPathShared) {
            name.add(item.split("/").last);
          }
          title = name.join('/');
        }
        break;
      case 2:
        {
          title = "Invite Family Member";
        }
        break;
    }
  }

  shouldShowBack() {
    if ((_activeIndex == 0 && currentPath.contains("/")) ||
        (_activeIndex == 1 && currentPathShared.length > 1)) {
      return InkWell(
        onTap: () async {
          if (await _onWillPop()) {
            Navigator.of(context).pop(true);
          }
        },
        child: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
      );
    } else {
      return InkWell();
    }
  }
}
