import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:threecloud/models/directory.dart';

class FolderNamePopup extends StatefulWidget {
  final String currentPath;

  FolderNamePopup({required this.currentPath});

  @override
  _FolderNamePopupState createState() => _FolderNamePopupState();
}

class _FolderNamePopupState extends State<FolderNamePopup> {
  TextEditingController _folderNameController = TextEditingController();

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  void _handleButtonPress() async {
    String folderName = _folderNameController.text;
    String currentPath = widget.currentPath; // Accessing currentPath from HomeScreen
    // Perform your desired action with the folder name and currentPath here
    print('Folder Name: $folderName');
    print('Current Path: $currentPath');
    try
    {
      await Directory.create(folderName, currentPath);
      Fluttertoast.showToast(
        msg: 'Directory created successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    catch(e)
    {
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


    // Close the popup
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Folder Name'),
      content: TextField(
        controller: _folderNameController,
        decoration: InputDecoration(
          hintText: 'Folder Name',
        ),
      ),
      actions: [
        TextButton(
          onPressed: _handleButtonPress,
          child: Text('Submit'),
        ),
      ],
    );
  }
}
