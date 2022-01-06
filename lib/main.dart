import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:download_assets/download_assets.dart';
import 'package:object_detection/Download.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   cameras = await availableCameras();
//   runApp(MyApp());
// }
//
// late List<CameraDescription> cameras;
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData.dark(),
//       home: HomePage(),
//     );
//   }
// }
//
// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   late CameraController cameraController;
//   late CameraImage cameraImage;
//   late List recognitionsList;
//
//   initCamera() {
//     cameraController = CameraController(cameras[0], ResolutionPreset.medium);
//     cameraController.initialize().then((value) {
//       setState(() {
//         cameraController.startImageStream((image) => {
//           cameraImage = image,
//           runModel(),
//         });
//       });
//     });
//   }
//
//   runModel() async {
//     recognitionsList = (await Tflite.detectObjectOnFrame(
//       bytesList: cameraImage.planes.map((plane) {
//         return plane.bytes;
//       }).toList(),
//       imageHeight: cameraImage.height,
//       imageWidth: cameraImage.width,
//       imageMean: 127.5,
//       imageStd: 127.5,
//       numResultsPerClass: 1,
//       threshold: 0.4,
//     ))!;
//
//     setState(() {
//       cameraImage;
//     });
//   }
//
//   Future loadModel() async {
//     Tflite.close();
//     await Tflite.loadModel(
//         model: "assets/ssd_mobilenet.tflite",
//         labels: "assets/ssd_mobilenet.txt");
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//
//     cameraController.stopImageStream();
//     Tflite.close();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     loadModel();
//     initCamera();
//   }
//
//   List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
//     if (recognitionsList == null) return [];
//
//     double factorX = screen.width;
//     double factorY = screen.height;
//
//     Color colorPick = Colors.pink;
//
//     return recognitionsList.map((result) {
//       return Positioned(
//         left: result["rect"]["x"] * factorX,
//         top: result["rect"]["y"] * factorY,
//         width: result["rect"]["w"] * factorX,
//         height: result["rect"]["h"] * factorY,
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.all(Radius.circular(10.0)),
//             border: Border.all(color: Colors.pink, width: 2.0),
//           ),
//           child: Text(
//             "${result['detectedClass']} ${(result['confidenceInClass'] * 100).toStringAsFixed(0)}%",
//             style: TextStyle(
//               background: Paint()..color = colorPick,
//               color: Colors.black,
//               fontSize: 18.0,
//             ),
//           ),
//         ),
//       );
//     }).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     List<Widget> list = [];
//
//     list.add(
//       Positioned(
//         top: 0.0,
//         left: 0.0,
//         width: size.width,
//         height: size.height - 100,
//         child: Container(
//           height: size.height - 100,
//           child: (!cameraController.value.isInitialized)
//               ? new Container()
//               : AspectRatio(
//             aspectRatio: cameraController.value.aspectRatio,
//             child: CameraPreview(cameraController),
//           ),
//         ),
//       ),
//     );
//
//     if (cameraImage != null) {
//       list.addAll(displayBoxesAroundRecognizedObjects(size));
//     }
//
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Container(
//           margin: EdgeInsets.only(top: 50),
//           color: Colors.black,
//           child: Stack(
//             children: list,
//           ),
//         ),
//       ),
//     );
//   }
// }

//new tutorial

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Download(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isWorking = false;
  String result = "";
  String? path;
  late CameraController cameraController;
  late CameraImage imgCamera;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      path = ModalRoute.of(context)!.settings.arguments as String;
      loadModel();
      initCamera();
    });
  }

  @override
  void dispose() async {
    super.dispose();
    cameraController.stopImageStream();
    await Tflite.close();
    cameraController.dispose();
  }

  Future loadModel() async {
    Tflite.close();
    print(" path :: $path");
    File file = File("$path");

    await Tflite.loadModel(
      model: "${file.absolute}",
      //  model: "assets/mobilenet_v1_1.0_224.tflite",
      labels: "assets/mobilenet_v1_1.0_224.txt",
      isAsset: false,
    );
  }

  initCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController.startImageStream((image) => {
              if (!isWorking)
                {
                  isWorking = true,
                  imgCamera = image,
                  runModelOnStreamFrames(),
                }
            });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: SafeArea(
            child: Scaffold(
                body: Container(
      child: Column(
        children: [
          if (imgCamera != null)
            Center(
              child: Container(
                  margin: EdgeInsets.only(top: 35),
                  height: 270,
                  width: 360,
                  child: AspectRatio(
                      aspectRatio: cameraController.value.aspectRatio,
                      child: CameraPreview(cameraController))),
            ),
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 55.0),
              child: SingleChildScrollView(
                  child: Text(
                result,
                style: TextStyle(
                    backgroundColor: Colors.black87,
                    fontSize: 30.0,
                    color: Colors.white),
                textAlign: TextAlign.center,
              )),
            ),
          )
        ],
      ),
    ))));
  }

  runModelOnStreamFrames() async {
    if (imgCamera != null) {
      var recognitions = await Tflite.runModelOnFrame(
          bytesList: imgCamera.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: imgCamera.height,
          imageWidth: imgCamera.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 2,
          threshold: 0.1,
          asynch: true);

      result = "";
      recognitions!.forEach((response) {
        result += response["label"] +
            " " +
            (response["confidence"] as double).toStringAsFixed(2) +
            "\n\n";
      });

      setState(() {
        result;
      });

      isWorking = false;
    }
  }
}
