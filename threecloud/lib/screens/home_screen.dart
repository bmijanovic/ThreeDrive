import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/floating_button.dart';


class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentPath = "vukasinb7/";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FloatingButton(currentPath: currentPath),
    );
  }
}
