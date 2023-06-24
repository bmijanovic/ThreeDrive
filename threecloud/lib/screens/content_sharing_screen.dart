import 'package:flutter/material.dart';

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
  List<String> _usernames = [];
  final String action;
  final String path;

  _ContentSharingScreen({required this.action, required this.path})
  {
    getUsers();
  }

  getUsers() async{
    // _usernames = await Resource.getSharedUsernames(action, path) ;
    setState(() {
    });
  }

  void _addUsername() {
    setState(() async {
      String username = _usernameController.text.trim();
      if (username.isNotEmpty) {
        _usernames.add(username);
        await Resource.addPermission(action, path, username, "GIVE");
        _usernameController.clear();
      }
    });
  }

  void _removeUsername(String username) {
    setState(() {
      _usernames.remove(username);
    });
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
                labelText: 'Enter a username',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addUsername,
              child: Text('Add Username'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Usernames:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _usernames.length,
                itemBuilder: (context, index) {
                  final username = _usernames[index];
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
