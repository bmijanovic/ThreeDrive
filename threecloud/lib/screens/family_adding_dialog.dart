import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:threecloud/models/directory.dart';

import '../models/invitation.dart';

class FamilyEmailPopup extends StatefulWidget {

  FamilyEmailPopup(BuildContext context);

  @override
  FamilyEmailPopupState createState() => FamilyEmailPopupState();
}

class FamilyEmailPopupState extends State<FamilyEmailPopup> {
  TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter Family Member's email"),
      content: TextField(
        controller: _emailController,
        decoration: const InputDecoration(
          hintText: 'Email',
        ),
      ),
      actions: [
        TextButton(
          onPressed: (() {
            // Invitation.create(_emailController.text);
            Navigator.pop(context);
          }),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
