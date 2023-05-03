
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../models/resource.dart';

class FloatingButton extends StatelessWidget {
  const FloatingButton({super.key});
  SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIconTheme: IconThemeData(size: 28.0),
      backgroundColor: Colors.blueAccent[900],
      visible: true,
      curve: Curves.bounceInOut,
      children: [
        SpeedDialChild(
          child: Icon(Icons.file_upload, color: Colors.white),
          backgroundColor: Colors.blueAccent,
          onTap: () => print('Pressed Read Later'),
          label: 'Upload a file',
          labelStyle:
          TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: Icon(Icons.create_new_folder_outlined, color: Colors.white),
          backgroundColor: Colors.blueAccent,
          onTap: ()=>_selectFile(),
          label: 'Add new folder',
          labelStyle:
          TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
      ],
      child: Icon(Icons.add),
    );
  }
  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      final File fileForFirebase = File(file.path!);
      List<int> fileBytes = await fileForFirebase.readAsBytes();
      String base64File = base64Encode(fileBytes);
      debugPrint(base64File);
      await Resource.upload("ImeIme",base64File);

    } else {
      // User canceled the picker
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: buildSpeedDial(),
      ),
    );
  }
}