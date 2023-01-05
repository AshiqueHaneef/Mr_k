import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:Mr_k/Models/ImageModel.dart';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class UploadBillScreen extends StatefulWidget {
  UploadBillScreen();

  @override
  UploadBillPageState createState() => UploadBillPageState();
}

class UploadBillPageState extends State<UploadBillScreen> {
  UploadBillPageState();
  // PermissionHandler permissionHandler = PermissionHandler();
  Directory? destinationDirectory;
  List<ImageModel> imageModelList = [];
  int totalNewImages = 0;
  int uploadingCompletedIndex = 0;
  String uploadBtnText = "Upload Bills";
  bool isUploadDisabled = false;
  var uuid = Uuid();
  List<Asset> resultList = <Asset>[];
  String error = 'No Error Detected';
  bool isNewBill = true;
  bool isLoading = false;
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.grey,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isNewBill ? "Bill Upload" : "All Bill",
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            GestureDetector(
              child: Card(
                elevation: 0,
                color: Colors.grey[350],
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: isNewBill ? "New Bill" : "All Bill ",
                          style: TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold)),
                      WidgetSpan(
                          child: Icon(Icons.receipt_long_outlined,
                              color: Colors.blueGrey))
                    ]),
                  ),
                ),
              ),
              onTap: () {
                isNewBill = !isNewBill;
                imageModelList = [];
                setState(() {});
                if (!isNewBill) {
                  getAllBills();
                }
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: isNewBill
            ? Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlue,
                          ),
                          child: Text(
                            "Select Bill",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          onPressed: () {
                            isUploadDisabled = false;
                            setState(() {});
                            // _requestPermission(PermissionGroup.storage);
                            selectImage(context);
                          }),
                    ),
                  ),
                  billImageView(),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: isUploadDisabled
                                ? Colors.grey
                                : Colors.lightBlueAccent,
                          ),
                          child: Text(
                            uploadBtnText,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          onPressed: () {
                            if (!isUploadDisabled) {
                              totalNewImages = 0;
                              if (null != imageModelList &&
                                  imageModelList.length > 0) {
                                for (ImageModel imageModel in imageModelList) {
                                  if (null == imageModel.imageId ||
                                      imageModel.imageId!.isEmpty) {
                                    //upload only new image
                                    totalNewImages = totalNewImages + 1;
                                  }
                                }
                              }
                              if (totalNewImages > 0) {
                                uploadBtnText = "Uploading " +
                                    uploadingCompletedIndex.toString() +
                                    " of " +
                                    totalNewImages.toString();
                                setState(() {});
                                for (ImageModel imageModel in imageModelList) {
                                  uploadingCompletedIndex = 0;
                                  setState(() {});
                                  if (null == imageModel.imageId ||
                                      imageModel.imageId!.isEmpty) {
                                    //upload only new image
                                    uploadImages(imageModel, context);
                                  }
                                }
                              } else {
                                uploadBtnText = "Data Update Successful";
                                isUploadDisabled = true;
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Data already updated",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Colors.blueGrey,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            }
                          }),
                    ),
                  ),
                ],
              )
            : Container(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : billImageView(),
              ),
      ),
    );
  }

  Future getAllBills() async {
    isLoading = true;
    setState(() {});
    String url = ApiInterFace.BASE_URL + ApiInterFace.GET_ALL_BILL_API;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      isLoading = false;
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        imageModelList = responseModel
            .map((userData) => new ImageModel.fromJson(userData))
            .toList();

        setState(() {});
      } else {
        Fluttertoast.showToast(
            msg: "No Bill Found",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      isLoading = false;

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

  Future uploadImages(ImageModel imageModel, BuildContext context) async {
    String url = ApiInterFace.BASE_URL + ApiInterFace.UPLOAD_BILL_API;

    File imageFile =
        File("${destinationDirectory?.path}/${imageModel.imageName}");
    String fileName = imageFile.path.split("/").last;
    var stream = new http.ByteStream(imageFile.openRead());
    var length = await imageFile.length();

    var request = new http.MultipartRequest("POST", Uri.parse(url));
    var multipartFile = new http.MultipartFile("file", stream, length,
        filename: basename(imageFile.path));

    request.files.add(multipartFile);
    request.fields['imageFileName'] = fileName;

    final respond = await request.send();

    if (respond.statusCode == 200) {
      uploadingCompletedIndex = uploadingCompletedIndex + 1;
      if (uploadingCompletedIndex < totalNewImages) {
        uploadBtnText = "Uploading " +
            uploadingCompletedIndex.toString() +
            " of " +
            totalNewImages.toString();
      } else {
        Fluttertoast.showToast(
            msg: "All bills uploaded",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        uploadingCompletedIndex = 0;
        imageModelList = [];
        uploadBtnText = "Data Update Successful";
        isUploadDisabled = true;
      }
      setState(() {});
      print("Image Uploaded");
    } else {
      print("Upload Failed");
    }
  }

  selectImage(BuildContext context) async {
    try {
      await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,

        // selectedAssets: images,
      ).then((value) {
        resultList = value;
        prepareImage(context);
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
    //   if(null!=files && files.length>1) {
    //     for (File file in files) {
    //       String name =
    //           uuid.v4().substring(1, 10) +
    //               ".jpeg";
    //       testCompressAndGetFile(file, destinationDirectory.path + "/" + name)
    //           .then((value) {
    //         File compressedFile = value;
    //         ImageModel imageModel = new ImageModel();
    //         imageModel.imageName = name;
    //         // if(!productModel.imageList.contains(imageModel)){
    //         imageModelList.insert(0, imageModel);
    //         setState(() {});
    //       });
    //     }
    //   }else{
    //     if(null!=files && files.length==1) {
    //       _cropImage(files[0], context);
    //     }

    // }
    // });

    setState(() {});
  }

  prepareImage(BuildContext context) async {
    if (resultList != null) {
      // List<File> files = result.paths.map((path) => File(path)).toList();
      if (null != resultList && resultList.length > 1) {
        for (Asset file in resultList) {
          String name = uuid.v4().substring(1, 10) + ".jpeg";
          var path = await FlutterAbsolutePath.getAbsolutePath(file.identifier!);

          testCompressAndGetFile(
                  File(path!), "${destinationDirectory?.path}/$name")
              .then((value) {
            File? compressedFile = value;
            ImageModel imageModel = new ImageModel();
            imageModel.imageName = name;
            // if(!productModel.imageList.contains(imageModel)){
            imageModelList.insert(0, imageModel);
            setState(() {});
          });
        }
      } else {
        if (null != resultList && resultList.length == 1) {
          var path = await FlutterAbsolutePath.getAbsolutePath(
              resultList[0].identifier!);

          _cropImage(new File(path!), context);
        }
      }
    } else {
      // User canceled the picker
    }
  }

  Widget billImageView() {
    if (null != imageModelList && imageModelList.length > 0) {
      return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, crossAxisSpacing: 0, mainAxisSpacing: 0),
        shrinkWrap: true,
        itemCount: imageModelList.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              GestureDetector(
                child: Card(
                  child: (null == imageModelList[index].imageId ||
                          imageModelList[index].imageId!.isEmpty && (isNewBill))
                      ? Image.file(
                          new File("${destinationDirectory?.path}/${imageModelList[index].imageName}"),
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          ApiInterFace.BILL_IMAGE_URL +
                              imageModelList[index].imageName!,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                ),
                onTap: () {},
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: imageModelList[index].deletingStatus == null
                      ? GestureDetector(
                          child: Icon(
                            Icons.delete,
                            color: Colors.orange,
                          ),
                          onTap: () {
                            if (null == imageModelList[index].imageId ||
                                imageModelList[index].imageId!.isEmpty) {
                              imageModelList.removeAt(index);
                            } else {
                              showAlertDialog(context, index);
                            }
                            setState(() {});
                          },
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator()),
                        )),
            ],
          );
        },
      );
    } else {
      return Container(
        height: 0,
        width: 0,
      );
    }
  }

  showAlertDialog(BuildContext context, int index) {
    Widget okButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
          onPrimary: Colors.white, primary: Colors.red),
      child: Text("Delete"),
      onPressed: () {
        Navigator.of(context).pop();
        deleteImage(imageModelList[index].imageName!,
            imageModelList[index].imageId!, index);
      },
    );
    Widget cancelButton = ElevatedButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete"),
      content: Text("Are you sure to delete this bill?"),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future deleteImage(String fileName, String imageId, int index) async {
    imageModelList[index].deletingStatus = 1;

    setState(() {});
    String url = ApiInterFace.BASE_URL +
        ApiInterFace.DELETE_BILL_API +
        "&imageFileName=" +
        fileName +
        "&billId=" +
        imageId;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        imageModelList.removeAt(index);
        setState(() {});
        Fluttertoast.showToast(
            msg: "Image Deleted Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Image Delete Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
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
      String name = uuid.v4().substring(1, 10) + ".jpeg";
      testCompressAndGetFile(imageFile, "${destinationDirectory?.path}/$name")
          .then((value) {
        File? compressedFile = value;
        ImageModel imageModel = new ImageModel();
        imageModel.imageName = name;
        // if(!productModel.imageList.contains(imageModel)){
        imageModelList.insert(0, imageModel);
        // Navigator.of(context).pop();
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
}
