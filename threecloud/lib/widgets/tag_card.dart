import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:threecloud/screens/upload_file_screen.dart';

class TagCard extends StatelessWidget {
  final String keyTag;
  final String valueTag;
  const TagCard({super.key,required this.keyTag,required this.valueTag});

  @override
  Widget build(BuildContext context) {
    String value=keyTag+":"+valueTag;
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
             ListTile(
              title: Text(value),
            ),
          ],
        ),
      ),
    );
  }

}