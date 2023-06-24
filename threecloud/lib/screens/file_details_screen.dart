import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_icon/file_icon.dart';
import 'package:flutter/services.dart';
import '../models/resource.dart';
import '../widgets/floating_button.dart';

class FileDetailsScreen extends StatefulWidget {
  final String filePath;
  FileDetailsScreen({super.key, required String this.filePath});

  @override
  _FileDetailsScreenState createState() => _FileDetailsScreenState(filePath);
}

class _FileDetailsScreenState extends State<FileDetailsScreen>{
  Future<dynamic>? element;
  var lifecycleEventHandler;
  String filePath;
  _FileDetailsScreenState(this.filePath){
    element = Resource.getResource(filePath) ;
  }

  getResource() async{
    element = Resource.getResource(filePath) ;
    setState(() {
    });
  }


  @override
  Widget build(BuildContext context) {
    List data=[1,2,3,4];
    return FutureBuilder<dynamic>(
      future: element, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {  // AsyncSnapshot<Your object type>
        if( snapshot.connectionState == ConnectionState.waiting){
          return  const Center(child: Text('Please wait its loading...'));
        }else{
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return  Scaffold(
                body: Scaffold(
                  body: GridView.count(
                      crossAxisCount: 1,
                      padding: const EdgeInsets.all(8.0),
                      children:  [
                        if (snapshot.hasData)
                          for (var entry in snapshot.data.entries)
                              Column(
                                  children:[
                                    const SizedBox(height: 10),
                                    Text("${entry.key}-${entry.value}",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.w600,))]
                              )
                        ]
                  ),

                )
            );
          }
        }
      },
    );


  }
}