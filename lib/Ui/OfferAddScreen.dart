import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:Mr_k/Utils/DisplaySize.dart';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class OfferAddScreen extends StatefulWidget {
  OfferAddScreen();

  @override
  OfferAddViewState createState() => OfferAddViewState();
}

class OfferAddViewState extends State<OfferAddScreen> {
  OfferAddViewState();
  TextEditingController offerTitleController = new TextEditingController();

  Directory? destinationDirectory;
  String newImageName = "";
  var uuid = Uuid();
  bool isOfferAddLoading = false;
  List<Asset> resultList = <Asset>[];
  String error = 'No Error Detected';
  @override
  void initState() {
    getDirectoryPath();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Add Offer",
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
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Container(
                width: double.infinity,
                child: TextField(
                  maxLines: 1,
                  controller: offerTitleController,
                  style: TextStyle(fontSize: 15.0),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    hintMaxLines: 1,
                    labelText: "Offer title",
                    prefixStyle: TextStyle(fontSize: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                )),
          ),
          offerImage(
            context,
          ),
          Center(
              child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
            ),
            child: Text(
              "Select image",
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              selectImage(context);
            },
          )),
          Visibility(
            visible: isOfferAddLoading,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                child: Text(
                  "Add Offer",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (null != newImageName && newImageName.isNotEmpty) {
                    isOfferAddLoading = true;
                    setState(() {});
                    updateOffer(offerTitleController.text, context);
                  } else {
                    Fluttertoast.showToast(
                        msg: "Select image",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blueGrey,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
              )),
        ],
      )),
    );
  }

  Future updateOffer(String offerName, BuildContext context) async {
    String url = ApiInterFace.BASE_URL + ApiInterFace.ADD_OFFER_API;
    http.Response response;

    File imageFile = File("${destinationDirectory?.path}/$newImageName");
    String fileName = imageFile.path.split("/").last;
    var stream = new http.ByteStream(imageFile.openRead());
    var length = await imageFile.length();

    var request = new http.MultipartRequest("POST", Uri.parse(url));
    var multipartFile = new http.MultipartFile("file", stream, length,
        filename: basename(imageFile.path));

    request.files.add(multipartFile);
    request.fields['imageFileName'] = newImageName;
    request.fields['offerTitle'] = offerName;

    response = await http.Response.fromStream(await request.send());
    print("Result: ${response.statusCode}");

    // final response = await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      List responseModel = json.decode(response.body);
      if (responseModel[0]["error"] == 0) {
        newImageName = "";
        offerTitleController.text = "";
        isOfferAddLoading = false;

        setState(() {});

        Fluttertoast.showToast(
            msg: "Offer Image Updated Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        isOfferAddLoading = false;
        setState(() {});
        Fluttertoast.showToast(
            msg: "Offer Image Update Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      isOfferAddLoading = false;
      setState(() {});
      Fluttertoast.showToast(
          msg: "Something went wrong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Widget offerImage(BuildContext context) {
    if (null != destinationDirectory && newImageName.isNotEmpty) {
      //

      return Image.file(
        File("${destinationDirectory?.path}/$newImageName"),
        width: displayWidth(context),
        height: displayWidth(context) * 0.6,
      );
    } else {
      return Container(
        height: 0,
        width: 0,
      );
    }
  }

  getDirectoryPath() async {
    if (Platform.isIOS) {
      await getLibraryDirectory().then((value) {
        destinationDirectory = value;
        setState(() {});
      });
    } else {
      await getExternalStorageDirectory().then((value) {
        destinationDirectory = value;
        setState(() {});
      });
    }
  }

  selectImage(BuildContext context) async {
    try {
      await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: false,
        // selectedAssets: images,
      ).then((value) async {
        resultList = value;
        if (resultList != null) {
          // List<File> files = result.paths.map((path) => File(path)).toList();
          if (null != resultList && resultList.length > 0) {
            var path = await FlutterAbsolutePath.getAbsolutePath(
                resultList[0].identifier!);

            _cropImage(new File(path!), context);
          }
        }
      });
    } on Exception catch (e) {
      error = e.toString();
      Fluttertoast.showToast(
          msg: "Something went wrong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    // await FilePicker.getMultiFile(
    //   type: FileType.custom,
    //   allowedExtensions: ['jpg', 'png', 'jpeg'],
    // ).then((value) {
    //   List<File> files = value;
    //   if (null != files && files.length > 0) {
    //     String name = "offer_" + uuid.v4().substring(1, 8) + ".jpeg";
    //     _cropImage(files[0], context);
    //   }
    // });

    setState(() {});
  }

  Future<Null> _cropImage(File imageFile, BuildContext context) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop image',
              toolbarColor: Colors.lightBlue,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Crop image',
          )
        ]);
    if (croppedFile != null) {
      imageFile = File(croppedFile.path);
      String name = "offer_" + uuid.v4().substring(1, 8) + ".jpeg";
      testCompressAndGetFile(imageFile, "${destinationDirectory?.path}/$name")
          .then((value) {
        newImageName = name;
        // File compressedFile = value;
        // categoryModel.imageName = name;
        setState(() {});
      });
    }
  }

  Future<File?> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 25,
    );

    print(file.lengthSync());
    print(result?.lengthSync());

    return result;
  }
}
