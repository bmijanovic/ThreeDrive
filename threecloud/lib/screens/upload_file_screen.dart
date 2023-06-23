import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:threecloud/widgets/tag_card.dart';

import '../models/resource.dart';
import '../widgets/big_text_field.dart';
class UploadFileScreen extends StatefulWidget{
  final File file;
  final String current_path;
  UploadFileScreen({Key? key, required this.file, required String this.current_path}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>UploadFileScreenState(file,this.current_path);
}

class UploadFileScreenState extends State<UploadFileScreen>{
  final List<Widget> _cardList = [];
  final List<String> _keyList = [];
  final List<String> _valueList = [];
  final File file;
  String current_path;
  UploadFileScreenState(this.file,this.current_path);
  List<String> reservedWords=["extension","mime","name","id","owner","share","size","timeModified","timeUploaded","resource_id"];
  DateTime selectedDate = DateTime.now();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController tagKeyController = TextEditingController();
  final TextEditingController tagValueController = TextEditingController();
  String keyError="";
  String valueError="";
  String nameError="";


  @override
  Widget build(BuildContext context) {
    nameController.text= file.path.split('/').last.split('.')[0];
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Add your file",
                style: Theme.of(context).textTheme.titleMedium,
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
                          if(value){
                          }else{
                            if (nameController.text == ""){
                              nameError="Value is empty";
                              setState(() {});
                            }
                            else{
                              nameError="";
                              setState(() {
                              });
                            }
                          }
                        }),
                        child:TextField(
                          controller: nameController,
                          keyboardType: TextInputType.text,
                          obscureText: false,
                          style: Theme.of(context).textTheme.bodyText1,
                          decoration: InputDecoration(
                            labelText: "Name*",
                            errorText: (nameError=="")?null:nameError,
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                          ),
                        )

                    ),

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
                    if(value){
                    }else{
                      if (tagKeyController.text == ""|| reservedWords.contains(tagKeyController.text) ){
                        keyError="Value is empty or use reserved word";
                        setState(() {});
                      }
                      else if (_keyList.contains(tagKeyController.text)) {
                        keyError="Key already exists";
                        setState(() {});
                      }
                      else{
                        keyError="";
                        setState(() {
                        });
                      }
                    }
                  }),
                  child:TextField(
                      controller: tagKeyController,
                      keyboardType: TextInputType.text,
                      obscureText: false,
                      style: Theme.of(context).textTheme.bodyText1,
                      decoration: InputDecoration(
                        labelText: "Tag key*",
                        errorText: (keyError=="")?null:keyError,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                      ),
                  )

                    ),
                    SizedBox(height: 20),
                    Focus(
                        onFocusChange: ((value) {
                          if(value){
                          }else{
                            if (tagValueController.text == ""){
                              valueError="Value is empty or use reserved word";
                              setState(() {});
                            }
                            else{
                              valueError="";
                              setState(() {
                              });
                            }
                          }
                        }),
                        child:TextField(
                          controller: tagValueController,
                          keyboardType: TextInputType.text,
                          obscureText: false,
                          style: Theme.of(context).textTheme.bodyText1,
                          decoration: InputDecoration(
                            labelText: "Tag value*",
                            errorText: (valueError=="")?null:valueError,
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                          ),
                        )

                    ),
                    SizedBox(height: 20),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {addDynamic();}),
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
                        itemBuilder: (context,index){

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
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 15),
                                alignment: Alignment.centerRight,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),

                              // Display item's title, price...
                              child: _cardList[index]
                          );
                        }),
                    const SizedBox(
                      height: 20.0,
                    ),
                    ElevatedButton(
                      onPressed: (() => upload()),
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

  upload() async {
    if (nameController.text=="")
      return;
    List<int> fileBytes = await file.readAsBytes();
    String base64File = base64Encode(fileBytes);
    List<Map<String,String>> tags=[];
    for (int i=0;i<_keyList.length;i++){
      tags.add({"key":_keyList[i],"value":_valueList[i]});
    }
    await Resource.upload(nameController.text,base64File,tags,current_path);
    Navigator.pop(context);
    Fluttertoast.showToast(
        msg: "File Uploaded Successfully!",
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