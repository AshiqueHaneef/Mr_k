import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:Mr_k/Api/ApiInterFace.dart';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_viewer/domain/bloc/controller.dart';
import 'package:video_viewer/video_viewer.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class StatusAddScreen extends StatefulWidget {
  StatusAddScreen();

  @override
  StatusAddScreenViewState createState() => StatusAddScreenViewState();
}

class StatusAddScreenViewState extends State<StatusAddScreen> {
  File? selectedFile;
  int selectedFileDuration = 0;
  VideoViewerController controller = VideoViewerController();
  late Directory destinationDirectory;
  double uploadProgress = 0;
  var uuid = Uuid();
  bool isImage = true;
  int _radioSelected = 1;
  var dio = Dio();
  CancelToken token = CancelToken();

  @override
  void initState() {
    getDirectoryPath();
    super.initState();
  }

  getDirectoryPath() async {
    if (Platform.isIOS) {
      await getLibraryDirectory().then((value) {
        destinationDirectory = value;
        setState(() {});
      });
    } else {
      await getExternalStorageDirectory().then((value) {
        destinationDirectory = value!.parent.parent.parent.parent;
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    token.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Add Status",
          style: TextStyle(
              color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: GestureDetector(
          child: (Icon(
            Icons.arrow_back,
            color: Colors.grey,
          )),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            null != selectedFile
                ? Card(
                    child: isImage
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width,
                            child: Image.file(selectedFile!),
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width,
                            child: VideoViewer(
                              controller: controller,
                              source: {
                                "Video": VideoSource(
                                  video:
                                      VideoPlayerController.file(selectedFile!),
                                )
                              },
                            ),
                          ),
                  )
                : Card(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isImage ? Icons.image : Icons.play_circle_fill,
                              color: Colors.grey,
                              size: 50,
                            ),
                            Text(isImage
                                ? "No Image Selected"
                                : "No Video Selected")
                          ],
                        ),
                      ),
                    ),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Image'),
                Radio(
                  value: 1,
                  groupValue: _radioSelected,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    if (uploadProgress == 0 || uploadProgress == 1.1) {
                      setState(() {
                        uploadProgress = 0;

                        selectedFile = null;

                        _radioSelected = value!;

                        isImage = true;
                      });
                    }
                  },
                ),
                Text('Video'),
                Radio(
                  value: 2,
                  groupValue: _radioSelected,
                  activeColor: Colors.pink,
                  onChanged: (value) {
                    if (uploadProgress == 0 || uploadProgress == 1.1) {
                      setState(() {
                        uploadProgress = 0;
                        selectedFile = null;
                        _radioSelected = value!;

                        isImage = false;
                      });
                    }
                  },
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (uploadProgress == 0 || uploadProgress == 1.1) {
                        controller = new VideoViewerController();
                        selectedFile = null;
                        uploadProgress = 0;
                        setState(() {});
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                                allowMultiple: false,
                                type:
                                    isImage ? FileType.image : FileType.video);

                        if (result != null) {
                          List<File> files =
                              result.paths.map((path) => File(path!)).toList();
                          PlatformFile file = result.files.first;
                          selectedFile = files[0];
                          setState(() {});
                        } else {
                          // User canceled the picker
                        }
                        /*await AssetPicker.pickAssets(context,
                                maxAssets: 1,
                                requestType: isImage
                                    ? RequestType.image
                                    : RequestType.video,
                                textDelegate: EnglishTextDelegate())
                            .then((value) async {
                          final List<AssetEntity> assets = value;
                          if(Platform.isAndroid) {
                            selectedFile = new File(destinationDirectory.path +
                                "/" +
                                assets[0].relativePath +
                                assets[0].title);
                          }else{
                            var path= await FlutterAbsolutePath.getAbsolutePath(assets[0].id);

                            selectedFile=new File(path);
                          }
                          selectedFileDuration=assets[0].duration;
                          setState(() {});
                        });*/
                      }
                    },
                    child:
                        Text(null != selectedFile && selectedFile!.existsSync()
                            ? isImage
                                ? "Change Image"
                                : "Change Video"
                            : isImage
                                ? "Select Image"
                                : "Select Video")),
              ],
            ),
            Visibility(
              visible: uploadProgress > 0 && uploadProgress < 1.1,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
                child: LinearProgressIndicator(
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  value: uploadProgress,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Visibility(
                    visible: null != selectedFile && selectedFile!.existsSync(),
                    child: ElevatedButton(
                      child: Text(
                        uploadProgress == 1.1
                            ? "Upload completed"
                            : uploadProgress > 0
                                ? "Uploading.."
                                : isImage
                                    ? "Upload image"
                                    : "Upload video",
                      ),
                      onPressed: () async {
                        if (null != selectedFile &&
                            selectedFile!.existsSync()) {
                          if (isImage) {
                            selectedFileDuration = 0;
                          } else {
                            Duration duration = controller.video!.value.duration;
                            selectedFileDuration = duration.inSeconds;
                          }
                          setState(() {});
                          uploadVideo(context);
                        }
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Visibility(
                    visible: uploadProgress > 0 && uploadProgress < 1.1,
                    child: ElevatedButton(
                      child: Text("Cancel"),
                      onPressed: () async {
                        token.cancel();
                        uploadProgress = 0;
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Directory> getAppDirectory() async {
    Directory? path;
    if (Platform.isIOS) {
      await getLibraryDirectory().then((value) {
        path = value;
      });
    } else {
      await getExternalStorageDirectory().then((value) {
        path = value!;
      });
    }
    return path!;
  }

  Future uploadVideo(BuildContext context) async {
    var formatter = new DateFormat('yyyy-MM-dd hh:mm:ss');
    token = CancelToken();
    uploadProgress = 0.1;
    setState(() {});
    String currentDateInString =
        formatter.format(DateTime.now().add(Duration(days: 1)));
    String ext = selectedFile!.path.split(".").last;
    String fileName = DateTime.now().microsecondsSinceEpoch.toString() +
        "_" +
        uuid.v4().substring(1, 5) +
        "." +
        ext;
    String url = ApiInterFace.BASE_URL + ApiInterFace.UPLOAD_STATUS_API;

    var formData = FormData.fromMap({
      'videoFileName': fileName,
      'endDate': currentDateInString,
      'isVideo': isImage ? 0 : 1,
      'duration': selectedFileDuration,
      'file':
          await MultipartFile.fromFile(selectedFile!.path, filename: fileName),
    });
    // var response = await dio.post(url, data: formData);
    var response = await dio.post(
      url,
      cancelToken: token,
      data: formData,
      onSendProgress: (int sent, int total) {
        uploadProgress = ((sent / total))
            .toDouble(); //this is what I want to listen to from my ViewModel class
        setState(() {});
        print('$uploadProgress  $sent $total');
      },
    );
    if (response.statusCode == 200) {
      selectedFile = null;
      uploadProgress = 1.1;
      setState(() {});
      Fluttertoast.showToast(
          msg: "Upload Successful",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Upload Failed",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
      print("Upload Failed");
    }
  }
}
