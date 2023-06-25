import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_icon/file_icon.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:threecloud/screens/edit_file_screen.dart';
import '../models/directory.dart';
import 'package:threecloud/screens/file_details_screen.dart';
import '../models/resource.dart';
import '../widgets/floating_button.dart';
import 'content_sharing_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class HomeScreen extends StatefulWidget {
  final String currentPath;

  HomeScreen({super.key, required String this.currentPath});

  @override
  _HomeScreenState createState() => _HomeScreenState(currentPath);
}

class _HomeScreenState extends State<HomeScreen> {
  Future<dynamic>? elements;
  bool isOpening = false;
  var lifecycleEventHandler;
  String currentPath;

  _HomeScreenState(this.currentPath) {
    getResources();
  }

  getResources() async {
    elements = Resource.getMyResources(currentPath);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: elements, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.connectionState == ConnectionState.waiting || isOpening) {
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
                        color: Colors.blueAccent,semanticsLabel: "Loading",
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:8.0),
                        child: Text("Loading",style: Theme.of(context).textTheme.labelMedium,),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                          currentPath: i,
                                        )),
                              );
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
                              String dir = (await getTemporaryDirectory()).path;
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
                                                      builder: (context) =>
                                                          EditFileScreen(
                                                            current_path: "",
                                                          )),
                                                ).then((value) =>
                                                    Navigator.pop(context));
                                              },
                                              child: const Text('Edit'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Resource.delete(i, currentPath)
                                                    .whenComplete(
                                                        () => getResources());
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
                                                          FileDetailsScreen(
                                                            filePath: i,
                                                          )),
                                                );
                                              },
                                              child: const Text('Details'),
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
                                                                    "RESOURCE",
                                                                path: i)),
                                                  ).then((value) => this);
                                                },
                                                child: const Text('Share')),
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
                                                                  Colors.white,
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
      },
    );
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
}
