

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:threecloud/screens/upload_file_screen.dart';

import '../models/resource.dart';
import '../screens/folder_creating_popup.dart';

class FloatingButton extends StatelessWidget {
  final String currentPath;
  var homeScreen;

   FloatingButton({super.key, required String this.currentPath, required var this.homeScreen});


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
          onTap: ()=> _showFolderNamePopup(context, currentPath),
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
        MaterialPageRoute(builder: (context) => UploadFileScreen(file: fileForUpload,current_path:currentPath)),
      ).then((value) =>
        homeScreen());

    } else {
    }
  }

  Future<void> _showFolderNamePopup(BuildContext context, String currentPath) async {
    final folderName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => FolderNamePopup(currentPath: currentPath),
    );

    if (folderName != null) {
      // Handle the folderName
      print('Folder Name: $folderName');
    }
    Navigator.push(context, homeScreen());
  }


  @override
  Widget build(BuildContext context) {
    return buildSpeedDial(context);
  }
}