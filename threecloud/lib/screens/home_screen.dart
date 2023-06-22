import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_icon/file_icon.dart';
import '../models/resource.dart';
import '../widgets/floating_button.dart';

class HomeScreen extends StatefulWidget {
  final String currentPath;
  HomeScreen({super.key, required String this.currentPath});

  @override
  _HomeScreenState createState() => _HomeScreenState(currentPath);
}

class _HomeScreenState extends State<HomeScreen> {
  Future<dynamic>? elements;
  String currentPath;
  _HomeScreenState(this.currentPath){
    elements=Resource.getMyResources(currentPath);
     getResources();
  }

  getResources() async{
    elements = Resource.getMyResources(currentPath) ;
  }
  @override
  Widget build(BuildContext context) {
    var data=[1,2,3,4];
    return FutureBuilder<dynamic>(
      future: elements, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {  // AsyncSnapshot<Your object type>
        if( snapshot.connectionState == ConnectionState.waiting){
          return  const Center(child: Text('Please wait its loading...'));
        }else{
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return  Scaffold(
                body: Scaffold(
                  body: GridView.count(
                    // Create a grid with 2 columns. If you change the scrollDirection to
                    // horizontal, this produces 2 rows.
                    crossAxisCount: 2,
                    // Generate 100 widgets that display their index in the List.
                    children:  [
                            if (snapshot.hasData)
                              for (var i in (snapshot.data!).directories)GestureDetector(
                                  onTap: (){Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => HomeScreen(currentPath: i,)),
                                  );},
                                  onLongPress: ()=> showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) => Dialog(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              const Text('Actions'),
                                              const SizedBox(height: 15),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Edit'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Delete'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                  ),
                                  child:
                                  Column(
                                      children:[ const Expanded(child: Icon(
                                        IconData(
                                          0xE02F,
                                          fontFamily: 'Seti',
                                          fontPackage: 'file_icon',
                                        ),
                                        color: Colors.amber,
                                        size: 70,
                                      )),
                                        const SizedBox(height: 10),
                                        Text("${i}",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.w600,))]
                                  )                               )
                    ,if (snapshot.hasData)
                      for (var i in (snapshot.data!).files)Column(
                          children:[ Expanded(child: FileIcon(i)),
                            const SizedBox(height: 10),
                            Text("${i}",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.w600,))])
                    ]
                  ),
                  floatingActionButton:FloatingButton(currentPath: currentPath+"/",),

                )
            );
          }
        }
      },
    );


  }
}
