

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:threecloud/screens/upload_file_screen.dart';

import '../models/resource.dart';

class FloatingButton extends StatelessWidget {
  const FloatingButton({super.key});
  SpeedDial buildSpeedDial(BuildContext context) {
    return SpeedDial(
      animatedIconTheme: IconThemeData(size: 28.0),
      backgroundColor: Colors.blueAccent[900],
      visible: true,
      curve: Curves.bounceInOut,
      children: [
        SpeedDialChild(
          child: Icon(Icons.file_upload, color: Colors.white),
          backgroundColor: Colors.blueAccent,
          onTap: () => _selectFile(context),
          label: 'Upload a file',
          labelStyle:
          TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: Icon(Icons.create_new_folder_outlined, color: Colors.white),
          backgroundColor: Colors.blueAccent,
          onTap: ()=>{},
          label: 'Add new folder',
          labelStyle:
          TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
      ],
      child: Icon(Icons.add),
    );
  }
  Future<void> _selectFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      final File fileForUpload = File(file.path!);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UploadFileScreen(file: fileForUpload,)),
      );

    } else {
      // User canceled the picker
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: buildSpeedDial(context),
      ),
    );
  }
}