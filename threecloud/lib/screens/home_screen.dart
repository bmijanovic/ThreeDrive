
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/floating_button.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FloatingButton(),
    );
  }
}