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

  String formatFileSize(String bytes) {
    int fileSize = int.tryParse(bytes) ?? 0;
    const int KB = 1024;
    const int MB = 1024 * KB;
    const int GB = 1024 * MB;

    if (fileSize < KB) {
      return '$fileSize bytes';
    } else if (fileSize < MB) {
      double kilobytes = fileSize / KB;
      return '${kilobytes.toStringAsFixed(2)} KB';
    } else if (fileSize < GB) {
      double megabytes = fileSize / MB;
      return '${megabytes.toStringAsFixed(2)} MB';
    } else {
      double gigabytes = fileSize / GB;
      return '${gigabytes.toStringAsFixed(2)} GB';
    }
  }
  String convertDateFormat(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}. ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return formattedDate;
  }
  List<String> keysToRemove = [
    'owner',
    'path',
    'size',
    'timeUploaded',
    'timeModified',
    'mime',
    'share',
    'name',
    'extension',
    'resource_id'
  ];


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: element, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {  // AsyncSnapshot<Your object type>
        if( snapshot.connectionState == ConnectionState.waiting){
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
        }else{
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return  Scaffold(
              appBar: AppBar(
                  title: Text(''),
                  backgroundColor: Colors.white10,
                elevation: 0.0,
                iconTheme: IconThemeData(
                  color: Colors.black,
                  size: 30
                ),),
                body:Padding(
                padding: EdgeInsets.only(top:0.0,left: 30,right: 30),

                  child:SingleChildScrollView(child:Container(width: double.infinity, child:Column(
                      mainAxisAlignment: MainAxisAlignment.start, // Aligns text to the left
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:  [
                        if (snapshot.hasData)
                      Center(child:Text("Details",style: TextStyle(color: Colors.black,fontSize: 30,fontWeight: FontWeight.w300,))),
                        Padding(
                            padding: EdgeInsets.only(top:15.0),

                            child:Center(child:Text("${snapshot.data!['name']}",style: TextStyle(color: Colors.black,fontSize: 30,fontWeight: FontWeight.w500,)))),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.start, // Aligns text to the left
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:[
                                  Padding(padding: EdgeInsets.only(top:15.0),child:Text("Type",style: TextStyle(color: Colors.black38,fontSize: 18,fontWeight: FontWeight.w400,))),
                                  Text("${snapshot.data!['mime']}",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w400,)),

                                  Padding(padding: EdgeInsets.only(top:15.0),child:Text("Size",style: TextStyle(color: Colors.black38,fontSize: 18,fontWeight: FontWeight.w400,))),
                                  Text("${formatFileSize(snapshot.data!['size'])}",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w400,)),

                                  Padding(padding: EdgeInsets.only(top:15.0),child:Text("Path",style: TextStyle(color: Colors.black38,fontSize: 18,fontWeight: FontWeight.w400,))),
                                  Text("${snapshot.data!['path']}",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w400,)),

                                  Padding(padding: EdgeInsets.only(top:15.0),child:Text("Created",style: TextStyle(color: Colors.black38,fontSize: 18,fontWeight: FontWeight.w400,))),
                                  Text("${convertDateFormat(snapshot.data!['timeUploaded'])}",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w400,)),

                                  Padding(padding: EdgeInsets.only(top:15.0),child:Text("Modified",style: TextStyle(color: Colors.black38,fontSize: 18,fontWeight: FontWeight.w400,))),
                                  Text("${convertDateFormat(snapshot.data!['timeModified'])}",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w400,)),

                                  Padding(padding: EdgeInsets.only(top:15.0),child:Text("Owner",style: TextStyle(color: Colors.black38,fontSize: 18,fontWeight: FontWeight.w400,))),
                                  Text("${snapshot.data!['owner']}",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w400,)),

                                  for (var entry in snapshot.data!.entries)
                                      if (!keysToRemove.contains(entry.key))
                                      Column(
                                            mainAxisAlignment: MainAxisAlignment.start, // Aligns text to the left
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                    children:[
                                      Padding(padding: EdgeInsets.only(top:15.0),child:Text("${entry.key}",style: TextStyle(color: Colors.black38,fontSize: 18,fontWeight: FontWeight.w400,))),
                                      Text("${entry.value}",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w400,)),
                                    ]
                              )])
                        ]
                  ),
            ))));
          }
        }
      },
    );


  }
}