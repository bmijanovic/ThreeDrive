import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:threecloud/widgets/tag_card.dart';

import '../models/resource.dart';
import '../widgets/big_text_field.dart';
class EditFileScreen extends StatefulWidget{
  final String current_path;
  EditFileScreen({Key? key, required String this.current_path}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>EditFileScreenState(this.current_path);
}

class EditFileScreenState extends State<EditFileScreen>{
  final List<Widget> _cardList = [];
  final List<String> _keyList = [];
  final List<String> _valueList = [];
  File? file;
  String current_path;
  EditFileScreenState(this.current_path){
    getData();
  }
  List<String> reservedWords=["extension","mime","name","id","owner","share","size","timeModified","timeUploaded","resource_id"];
  DateTime selectedDate = DateTime.now();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController tagKeyController = TextEditingController();
  final TextEditingController tagValueController = TextEditingController();
  String keyError="";
  String valueError="";
  String nameError="";
  bool isOpening=true;
  Future<dynamic> getData() async {
    return Resource.getResource(this.current_path).whenComplete(() {isOpening=false;});
    }

  List<String> keysToRemove = [
    'owner',
    'path',
    'size',
    'timeUploaded',
    'timeModified',
    'mime',
    'share',
    'name',
    'extension',
    'resource_id'
  ];

  Future<void> _selectFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      this.file = File(file.path!);
    } else {
    }
  }
  @override
  void initState() {
    getData().then((value){
      print(value['name']);
      nameController.text=value['name'];
      for (var entry in value.entries) {
        if (!keysToRemove.contains(entry.key)) {
          setState(() {
            _keyList.add(entry.key);
            _valueList.add(entry.key);
            _cardList.add(TagCard(
              keyTag: entry.key, valueTag: entry.value,));
          });
        }
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    if(isOpening){
      return Scaffold(
        body: Center(
          child: Container(
              width: 200,
              height: 200,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.blueAccent,semanticsLabel: "Loading",
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:8.0),
                    child: Text("Loading",style: Theme.of(context).textTheme.labelMedium,),
                  )
                ],
              )),
        ),
      );
    }else {
      return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Add your file",
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium,
                ),
                const SizedBox(
                  height: 50.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                  child: Column(
                    children: [
                      Focus(
                          onFocusChange: ((value) {
                            if (value) {} else {
                              if (nameController.text == "") {
                                nameError = "Value is empty";
                                setState(() {});
                              } else {
                                nameError = "";
                                setState(() {});
                              }
                            }
                          }),
                          child: TextField(
                            controller: nameController,
                            keyboardType: TextInputType.text,
                            obscureText: false,
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyText1,
                            decoration: InputDecoration(
                              labelText: "Name*",
                              errorText: (nameError == "") ? null : nameError,
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                            ),
                          )),
                      SizedBox(height: 10),
                      const Divider(
                        height: 20,
                        thickness: 3,
                        indent: 0,
                        endIndent: 0,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(height: 30),
                      Focus(
                          onFocusChange: ((value) {
                            if (value) {} else {
                              if (tagKeyController.text == "" ||
                                  reservedWords.contains(
                                      tagKeyController.text)) {
                                keyError =
                                "Value is empty or use reserved word";
                                setState(() {});
                              } else if (_keyList
                                  .contains(tagKeyController.text)) {
                                keyError = "Key already exists";
                                setState(() {});
                              } else {
                                keyError = "";
                                setState(() {});
                              }
                            }
                          }),
                          child: TextField(
                            controller: tagKeyController,
                            keyboardType: TextInputType.text,
                            obscureText: false,
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyText1,
                            decoration: InputDecoration(
                              labelText: "Tag key*",
                              errorText: (keyError == "") ? null : keyError,
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                            ),
                          )),
                      SizedBox(height: 20),
                      Focus(
                          onFocusChange: ((value) {
                            if (value) {} else {
                              if (tagValueController.text == "") {
                                valueError =
                                "Value is empty or use reserved word";
                                setState(() {});
                              } else {
                                valueError = "";
                                setState(() {});
                              }
                            }
                          }),
                          child: TextField(
                            controller: tagValueController,
                            keyboardType: TextInputType.text,
                            obscureText: false,
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyText1,
                            decoration: InputDecoration(
                              labelText: "Tag value*",
                              errorText: (valueError == "") ? null : valueError,
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                            ),
                          )),
                      SizedBox(height: 20),
                      IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            addDynamic();
                          }),
                      Row(
                        children: const [
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              width: 10.0,
                            ),
                          ),
                        ],
                      ),
                      ListView.builder(
                          itemCount: _cardList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Dismissible(
                                key: UniqueKey(),

                                // only allows the user swipe from right to left
                                direction: DismissDirection.endToStart,

                                // Remove this product from the list
                                // In production enviroment, you may want to send some request to delete it on server side
                                onDismissed: (_) {
                                  setState(() {
                                    _cardList.removeAt(index);
                                    _keyList.removeAt(index);
                                    _valueList.removeAt(index);
                                  });
                                },

                                // This will show up when the user performs dismissal action
                                // It is a red background and a trash icon
                                background: Container(
                                  color: Colors.red,
                                  margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                                  alignment: Alignment.centerRight,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),

                                // Display item's title, price...
                                child: _cardList[index]);
                          }),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: (() => {_selectFile(context)}),
                          child: const Text("Change file"),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: (() => edit()),
                        child: const Text("Upload"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  edit() async {
    if (nameController.text=="")
      return;
    String image="";
    if (this.file!=null){
      List<int> fileBytes = await file!.readAsBytes();
      image=base64Encode(fileBytes);
    }
    List<Map<String,String>> tags=[];
    for (int i=0;i<_keyList.length;i++){
      tags.add({_keyList[i]:_valueList[i]});
    }
    await Resource.edit(nameController.text,image,tags,current_path);
    Navigator.pop(context);
    Fluttertoast.showToast(
        msg: "File Edit Successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }



  addDynamic(){
    setState(() {
      if (tagValueController.text != ""&& tagKeyController.text != ""&& !reservedWords.contains(tagKeyController.text) && !_keyList.contains(tagKeyController.text)) {
        _cardList.add(new TagCard(
          keyTag: tagKeyController.text, valueTag: tagValueController.text,));
        _keyList.add(tagKeyController.text);
        _valueList.add(tagValueController.text);
        tagValueController.text = "";
        tagKeyController.text = "";
      }
    });
  }
  bool areInputsValid(BuildContext context) {
    if (nameController.text == ""){
      showError(context, "Invalide input values");
      return false;
    }
    return true;
  }
  bool areTagsValid(BuildContext context) {
    if (tagKeyController.text == "" || tagValueController.text == ""){
      showError(context, "Invalide input values");
      return false;
    }
    return true;
  }

  showError(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Error"),
          content: Text(message),
        );
      },
      barrierDismissible: true,
    );
  }
}