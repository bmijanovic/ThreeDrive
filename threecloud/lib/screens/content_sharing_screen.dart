import 'package:flutter/material.dart';


class ContentSharingScreen extends StatefulWidget {
  final String action;

  ContentSharingScreen({required this.action});

  @override
  _ContentSharingScreen createState() => _ContentSharingScreen();
}

class _ContentSharingScreen extends State<ContentSharingScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final List<String> _usernames = [];


  void _addUsername() {
    setState(() {
      String username = _usernameController.text.trim();
      if (username.isNotEmpty) {
        _usernames.add(username);
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
