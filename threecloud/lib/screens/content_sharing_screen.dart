import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/resource.dart';


class ContentSharingScreen extends StatefulWidget {
  final String action;
  final String path;

  ContentSharingScreen({required this.action, required this.path});

  @override
  _ContentSharingScreen createState() => _ContentSharingScreen(action: action, path: path);
}

class _ContentSharingScreen extends State<ContentSharingScreen> {
  final TextEditingController _usernameController = TextEditingController();
  List<dynamic> elements = [];
  final String action;
  final String path;

  _ContentSharingScreen({required this.action, required this.path})
  {
    getUsers();
  }

  getUsers() async{
    try
    {
      elements = await Resource.getSharedUsernames(action, path);
    }
    catch (e)
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
    setState(() {
    });
  }

  Future<void> _addUsername() async {
    String username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      try
      {
        await Resource.addPermission(action, path, username, "GIVE");
        setState(() {
          if (username.isNotEmpty) {
            elements.add(username);
          }
        });
      }
      catch (e)
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
      _usernameController.clear();
    }

  }

  Future<void> _removeUsername(String username) async {
    try
    {
      await Resource.addPermission(action, path, username, "REVOKE");
      setState(() {
        elements.remove(username);
      });
    }
    catch (e)
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

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('User List'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 40),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Enter a username to add permission',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addUsername,
              child: Text('Add Username'),
            ),
            const SizedBox(height: 40),
            const Text(
              'Usernames who can access this content:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: elements.length,
                itemBuilder: (context, index) {
                  final username = elements[index];
                  return ListTile(
                    title: Text(username),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeUsername(username),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
