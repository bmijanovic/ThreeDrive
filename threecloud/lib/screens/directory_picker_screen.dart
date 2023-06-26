
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/resource.dart';

class DirectoryPickerScreen extends StatefulWidget {
  final String currentPath;
  final String content;

  DirectoryPickerScreen({super.key, required String this.currentPath, required String this.content});

  @override
  _DirectoryPickerScreen createState() {
    return _DirectoryPickerScreen(currentPath, content);
  }

}

class _DirectoryPickerScreen extends State<DirectoryPickerScreen> {

  Future<dynamic>? elements;
  bool isOpening = false;
  String currentPath;
  String content;

  _DirectoryPickerScreen(this.currentPath, this.content) {
    getResources(currentPath);
  }

  getResources(String path) async {
    if(path == "")
      {
        var pref = await SharedPreferences.getInstance();
        path = pref.getString("username")!;
      }
    elements = Resource.getMyResources(path);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: elements,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                      const CircularProgressIndicator(
                        color: Colors.blueAccent, semanticsLabel: "Loading",
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("Loading", style: Theme
                            .of(context)
                            .textTheme
                            .labelMedium,),
                      )
                    ],
                  )),
            ),
          );
        }
        else {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          else {
            return Scaffold(
              body: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Choose folder...",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      padding: const EdgeInsets.all(8.0),
                      children: [
                        if (snapshot.hasData)
                          for (var i in (snapshot.data!).directories)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DirectoryPickerScreen(
                                      currentPath: i,
                                      content: content,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  const Expanded(
                                    child: Icon(
                                      IconData(
                                        0xE02F,
                                        fontFamily: 'Seti',
                                        fontPackage: 'file_icon',
                                      ),
                                      color: Colors.amber,
                                      size: 70,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    i.toString().split("/").last,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        print(currentPath);
                        print(content);
                        // Resource.move(content, currentPath);
                      },
                      child: const Text("Move"),
                    ),
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }

}