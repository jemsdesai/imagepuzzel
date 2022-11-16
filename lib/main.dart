import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as imglib;

main() {
  runApp(MaterialApp(
    home: splsh(),
  ));
}

class splsh extends StatefulWidget {
  @override
  State<splsh> createState() => _splshState();
}

class _splshState extends State<splsh> {
  String folderPath = "";
  GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermison();
  }

  navigate() async {
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) {
        return homepage(folderPath);
      },
    ));
  }

  Future getPermison() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      await [Permission.storage].request();
    }
    makeDir();
    navigate();
  }

  makeDir() async {
    var path = await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOADS) +
        "/ImagePuzzel";

    Directory dir = Directory(path);
    if (await dir.exists()) {
      print("Directory is Exist");
    } else {
      dir.create();
      print("Directory Created");
    }
    folderPath = dir.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [Colors.purple, Colors.pinkAccent])),
        child: Text(
          "Image Puzzel",
          style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.white),
        ),
      ),
    );
  }

// captureWidget()async{
//   // final boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
//   // final image = await boundary?.toImage();
//   // final byteData = await image?.toByteData(format: ImageByteFormat.png);
//
//   final imageBytes = byteData?.buffer.asUint8List();
//
//   //create
//   if (imageBytes != null) {
//     final imagePath = await File('${folderPath}/container_image.png').create();
//     await imagePath.writeAsBytes(imageBytes);
//     print("image created");
//   }
// }
}

class homepage extends StatefulWidget {
  String folderPath;

  homepage(this.folderPath);

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  double border = 5;
  int valueslider = 2;
  bool isPicked = false;
  ImagePicker _picker = ImagePicker();
  XFile? fullimageBytes;
  List<Image> imgList = [];
  List<Image> checkimgList = [];
  double lenth = 3;
  List<String> numb=["1","2","3","4","5","6","7","8","9"];
  List<int> intList=[];

  //int pos=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    numb.shuffle();
  }

  Draggable<int> numDrag(index){

    return Draggable(
        data:index,
        child: Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.white54,
          borderRadius: BorderRadius.all(Radius.circular(15))
      ),
      child: Text("${numb[index]}",style: TextStyle(color: Colors.white,fontSize: 30,fontWeight: FontWeight.bold),),),
        feedback: Container(
          height: MediaQuery.of(context).size.height*0.15,
          width: MediaQuery.of(context).size.width*0.3,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.white70,
          borderRadius: BorderRadius.all(Radius.circular(15))
      ),
      child: Text("${numb[index]}",style: TextStyle(color: Colors.black,fontSize: 30,fontWeight: FontWeight.bold),),),
        childWhenDragging: Container(
          height: MediaQuery.of(context).size.height*0.15,
          width: MediaQuery.of(context).size.width*0.3,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white70,
              borderRadius: BorderRadius.all(Radius.circular(15))
          ),

        ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.maxFinite,
        width: double.maxFinite,
        color: Colors.lightGreen,
        alignment: Alignment.center,
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                "Slide Puzzel ${valueslider}X$valueslider",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.all(10),
                      child: isPicked
                          ? Container(
                              alignment: Alignment.center,
                              height: MediaQuery.of(context).size.height * 0.60,
                              width: MediaQuery.of(context).size.width * 0.9,
                              decoration: BoxDecoration(
                                color: Colors.white60,
                                border: Border.all(
                                    width: border, color: Colors.black),
                              ),
                              child: GridView.builder(
                                itemCount: lenth.toInt() * lenth.toInt(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                        crossAxisCount: lenth.toInt()),
                                itemBuilder: (context, index) {

                                  return DragTarget(
                                    onAccept: (data) {
                                      setState(() {
                                        Image temp;
                                        temp=imgList[index];
                                        imgList[index]=imgList[data as int];
                                        imgList[data as int]=temp;
                                        if(listEquals(checkimgList,imgList))
                                          {
                                            showDialog(context: context, builder: (context) {
                                              return AlertDialog(
                                                content: Text("You are Win",style: TextStyle(color: Colors.green,fontSize: 30),),
                                              );
                                            },);
                                          }
                                      });
                                    },
                                    builder: (context, candidateData, rejectedData) {
                                    return  Draggable(
                                        data:index,
                                        childWhenDragging: Container(
                                      child: Stack(children: [
                                        imgList[index],
                                        Container(

                                            color: Colors.white12)
                                      ],),
                                    ) ,
                                        child: Container(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.16,
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.33,
                                          child: imgList[index],
                                        ),
                                        feedback: Container(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.16,
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.33,
                                          child: imgList[index],
                                        )
                                    );
                                  },);
                                },
                              ),
                            )
                          : Container(
                        alignment: Alignment.center,
                              height: MediaQuery.of(context).size.height * 0.60,
                              width: MediaQuery.of(context).size.width * 0.9,
                              decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  border: Border.all(
                                      width: border, color: Colors.black)),
                        child:  GridView.builder(
                          itemCount: 9,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3),
                          itemBuilder: (context, index) {
                            return DragTarget(
                              onAccept: (indx){
                                setState(() {
                                  print("accept== ${indx}");
                                  String temp;
                                  temp= numb[indx as int];
                                  numb[indx as int]=numb[index];
                                  numb[index]=temp;
                                  print(index);
                                });
                              },
                              builder: (context, Data, rejectedData) {
                                return numDrag(index);
                              },
                            );
                          },),
                            )),

                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    child: Row(children: [
                      StatefulBuilder(builder: (context, set) => Slider(
                        onChanged: (double value) {
                          set(() {
                            valueslider = value.toInt();
                          });
                        },
                        value: valueslider.toDouble(),
                        divisions: 13,
                        label: "${valueslider.toString()}",
                        min: 2,
                        max: 15,
                      ),),
                      ElevatedButton(onPressed: (){
                       if(isPicked)
                         {
                           setState(() {
                             lenth=valueslider.toDouble();
                             imgList = splitImage(intList);

                             isPicked=false;
                           });

                         }
                      }, child: Text("Change"))
                    ],),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        fullimageBytes = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (fullimageBytes != null) {
                          File file = File(
                              widget.folderPath + "/img${DateTime.now()}.jpg");
                          file.writeAsBytes(
                              await fullimageBytes!.readAsBytes());
                          file.create();
                          intList = await file.readAsBytes();
                          imgList = splitImage(intList);
                          // imgList=await

                          setState(() {});
                        }


                      },
                      child: Text("Choose An Image")),
                ],
              ),
            )));
  }
  List<Image> splitImage(List<int> input) {
    // convert image to image from image package
    imglib.Image? image = imglib.decodeImage(input);

    int x = 0, y = 0;
    int width = (image!.width / lenth).round();
    int height = (image.height / lenth).round();

    // split image to parts
    List<imglib.Image> parts = [];
    for (int i = 0; i <lenth; i++) {
      for (int j = 0; j <lenth ; j++) {
        parts.add(imglib.copyCrop(image, x, y, width, height));
        x += width;
      }
      x = 0;
      y += height;
    }

    // convert image from image package to Image Widget to display
    List<Image> output = [];
    for (var img in parts) {
      output.add(Image.memory(Uint8List.fromList(imglib.encodeJpg(img))));
    }
    checkimgList=output;
    output.shuffle();
    isPicked = true;
    return output;
  }
}
//
// class slideObject{
//   Offset? posDeffaul;
//   Offset? posCurrent;
//   int? indexDefault;
//   int? indexCurrent;
//   bool? empty;
//   Size? size;
//   Image? image;
//
//   slideObject({
//     this.posDeffaul,
//     this.posCurrent,
//     this.indexDefault,
//     this.indexCurrent,
//     this.empty=false,
//     this.size,
//     this.image
// });
// }
