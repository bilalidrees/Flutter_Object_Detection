import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:object_detection/main.dart';
import 'package:path_provider/path_provider.dart';

class Download extends StatefulWidget {
  @override
  _DownloadState createState() => _DownloadState();
}

class _DownloadState extends State<Download> {
  // final imageSrc = 'https://picsum.photos/250?image=9';
  final imageSrc =
      'https://drive.google.com/uc?id=1FRlq6oLKITUGzju7Q3Yz8fhQeNJzfb0R';

  var downloadPath = '';
  var downloadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Expanded(flex: 5, child: Image.network(imageSrc)),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    // Download displayed image from imageSrc
                    onPressed: () {
                      downloadFile().catchError((onError) {
                        debugPrint('Error downloading: $onError');
                      }).then((imagePath) {
                        debugPrint('Download successful, path: $imagePath');
                        print('$imagePath');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                            settings: RouteSettings(
                              arguments: imagePath,
                            ),
                          ),
                        );
                        //displayDownloadImage(imagePath);
                      });
                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: downloadProgress,
            ),
            Expanded(
                flex: 5,
                child: downloadPath == ''
                    // Display a different image while downloadPath is empty
                    // downloadPath will contain an image file path on successful image download
                    ? Icon(Icons.image)
                    : Image.file(File(downloadPath))),
          ],
        ),
      ),
    );
  }

  displayDownloadImage(String path) {
    setState(() {
      downloadPath = path;
    });
  }

  Future downloadFile() async {
    Dio dio = Dio();
    var dir = await getApplicationDocumentsDirectory();
    var imageDownloadPath = '${dir.path}/mobilenet_v1_1.0_224.tflite';
    await dio.download(imageSrc, imageDownloadPath,
        onReceiveProgress: (received, total) {
      var progress = (received / total) * 100;
      debugPrint('Rec: $received , Total: $total, $progress%');
      setState(() {
        downloadProgress = received.toDouble() / total.toDouble();
      });
    });
    // downloadFile function returns path where image has been downloaded
    return imageDownloadPath;
  }
}

// class Download extends StatefulWidget {
//   final String title;
//
//   Download({this.title = ''});
//
//   @override
//   _DownloadState createState() => _DownloadState();
// }
//
// class _DownloadState extends State<Download> {
//   String message = "Press the download button to start the download";
//   bool downloaded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     DownloadAssetsController.init();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(message),
//             // if (downloaded)
//             //   Container(
//             //     width: 150,
//             //     height: 150,
//             //     decoration: BoxDecoration(
//             //       image: DecorationImage(
//             //         image: FileImage(File("${DownloadAssetsController.assetsDir}/dart.jpeg")),
//             //         fit: BoxFit.fitWidth,
//             //       ),
//             //     ),
//             //   ),
//             // if (downloaded)
//             //   Container(
//             //     width: 150,
//             //     height: 150,
//             //     decoration: BoxDecoration(
//             //       image: DecorationImage(
//             //         image: FileImage(File("${DownloadAssetsController.assetsDir}/flutter.png")),
//             //         fit: BoxFit.fitWidth,
//             //       ),
//             //     ),
//             //   )
//           ],
//         ),
//       ),
//       floatingActionButton: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           FloatingActionButton(
//             onPressed: _downloadAssets,
//             tooltip: 'Increment',
//             child: Icon(Icons.arrow_downward),
//           ),
//           SizedBox(
//             width: 25,
//           ),
//           FloatingActionButton(
//             onPressed: _refresh,
//             tooltip: 'Refresh',
//             child: Icon(Icons.refresh),
//           ),
//         ],
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
//
//   Future _refresh() async {
//     await DownloadAssetsController.clearAssets();
//     await _downloadAssets();
//   }
//
//   Future _downloadAssets() async {
//     bool assetsDownloaded =
//         await DownloadAssetsController.assetsDirAlreadyExists();
//
//     if (assetsDownloaded) {
//       setState(() {
//         message = "Click in refresh button to force download";
//         print(message);
//       });
//       return;
//     }
//
//     try {
//       await DownloadAssetsController.startDownload(
//           assetsUrl:
//               "https://drive.google.com/uc?id=1FRlq6oLKITUGzju7Q3Yz8fhQeNJzfb0R",
//           onProgress: (progressValue) {
//             downloaded = false;
//             setState(() {
//               message = "Downloading - ${progressValue.toStringAsFixed(2)}";
//               print(message);
//             });
//           },
//           onComplete: () {
//             setState(() {
//               message =
//                   "Download compeleted\nClick in refresh button to force download";
//               downloaded = true;
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) =>
//                         HomePage( )),
//               );
//             });
//           },
//           onError: (exception) {
//             setState(() {
//               downloaded = false;
//               message = "Error: ${exception.toString()}";
//             });
//           });
//     } on DownloadAssetsException catch (e) {
//       print(e.toString());
//     }
//   }
// }
