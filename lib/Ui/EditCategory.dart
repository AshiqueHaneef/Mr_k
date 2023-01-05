import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:Mr_k/Models/CategoryModel.dart';
import 'package:Mr_k/Models/SubCategoryModel.dart';
import 'package:Mr_k/Preference/Preference.dart';
import 'package:Mr_k/Utils/DisplaySize.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class EditCategoryScreen extends StatefulWidget {
  EditCategoryScreen(this.categoryModel);

  CategoryModel categoryModel =  CategoryModel();

  @override
  EditCategoryViewState createState() => EditCategoryViewState(categoryModel);
}

class EditCategoryViewState extends State<EditCategoryScreen> {
  EditCategoryViewState(this.categoryModel);
  TextEditingController categoryNameController =  TextEditingController();

  List<SubCategoryModel> subCategoryModelList = [];
  CategoryModel categoryModel = new CategoryModel();
  Directory? destinationDirectory;
  String newImageName = "";
  bool isLoading = false;
  var uuid = Uuid();
  bool isCategoryAddLoading = false;

  List<Asset> resultList = <Asset>[];
  String error = 'No Error Detected';
  @override
  void initState() {
    categoryNameController.text = categoryModel.categoryName!;
    Preference().getSubCategoryList().then((value) {
      List<SubCategoryModel> subCategoryList = [];
      subCategoryList = value;

      if (null != value && value.length > 0) {
        subCategoryModelList = subCategoryList
            .where((subCategory) =>
                (subCategory.categoryId == categoryModel.categoryId))
            .toList();
      }
    });
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
        leading: GestureDetector(
          child: (Icon(
            Icons.arrow_back,
            color: Colors.grey,
          )),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        title: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Edit Category",
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            GestureDetector(
              child: Align(
                  alignment: Alignment.centerRight,
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Icon(
                          Icons.delete,
                          color: Colors.blueGrey,
                        )),
              onTap: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) =>
                        categoryDeleteConfirmDialog(
                            categoryModel.categoryName!, context)).then((value) {
                  if (value == true) {
                    isLoading = true;
                    setState(() {});
                    deleteCategory(context).then((value) {
                      if (value == true) {
                        Navigator.of(context).pop(true);
                      }
                    });
                  }
                });
              },
            ),
          ],
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
                  controller: categoryNameController,
                  style: TextStyle(fontSize: 15.0),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    hintMaxLines: 1,
                    labelText: "Category name",
                    prefixStyle: TextStyle(fontSize: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                )),
          ),
          categoryImage(
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
            visible: isCategoryAddLoading,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                child: Text(
                  "Update Category",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (null != newImageName && newImageName.isNotEmpty) {
                    categoryModel.imageName = newImageName;
                  }
                  isCategoryAddLoading = true;
                  setState(() {});
                  updateCategory(categoryNameController.text,
                      categoryModel.categoryId!, context);
                },
              )),
        ],
      )),
    );
  }

  Future deleteCategory(BuildContext context) async {
    String url = ApiInterFace.BASE_URL +
        ApiInterFace.DELETE_CATEGORY_API +
        "&imageName=" +
        categoryModel.imageName! +
        "&categoryId=" +
        categoryModel.categoryId!;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      isLoading = false;
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        Preference().setCategoryList(response.body);
        Fluttertoast.showToast(
            msg: responseModel[0]["message"],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        return true;
      } else {
        setState(() {});
        Fluttertoast.showToast(
            msg: responseModel[0]["message"],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        return false;
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
      return false;
    }
  }

  Future updateCategory(
      String categoryName, String categoryId, BuildContext context) async {
    String url = ApiInterFace.BASE_URL + ApiInterFace.ADD_CATEGORY_API;
    http.Response response;

    if (null != newImageName && newImageName.isNotEmpty) {
      File imageFile =
          File("${destinationDirectory?.path}/${categoryModel.imageName}");
      String fileName = imageFile.path.split("/").last;
      var stream = new http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();

      var request = new http.MultipartRequest("POST", Uri.parse(url));
      var multipartFile = new http.MultipartFile("file", stream, length,
          filename: basename(imageFile.path));

      request.files.add(multipartFile);
      request.fields['imageFileName'] = fileName;
      request.fields['categoryName'] = categoryName;
      request.fields['categoryId'] = categoryId;

      response = await http.Response.fromStream(await request.send());
      print("Result: ${response.statusCode}");
    } else {
      url = url + "&categoryName=" + categoryName + "&categoryId=" + categoryId;

      response = await http.get(Uri.parse(url), headers: ApiInterFace.headers);
    }

    // final response = await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      isCategoryAddLoading = false;
      List responseModel = json.decode(response.body);
      if (responseModel[0]["error"] == 0) {
        // categoryModel = new CategoryModel();

        Preference().setCategoryList(response.body);
        setState(() {});

        Fluttertoast.showToast(
            msg: "Category Updated Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        isCategoryAddLoading = false;
        setState(() {});
        Fluttertoast.showToast(
            msg: "Category Update Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      isCategoryAddLoading = false;
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

  Widget categoryImage(BuildContext context) {
    if (null != destinationDirectory && newImageName.isNotEmpty) {
      //

      return Image.file(
        File("${destinationDirectory?.path}/$newImageName"),
        width: displayWidth(context),
        height: displayWidth(context) * 0.6,
      );
    } else if (null != categoryModel.imageName &&
        categoryModel.imageName!.isNotEmpty) {
      return Image.network(
        ApiInterFace.CATEGORY_IMAGE_URL + categoryModel.imageName!,
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

  Widget categoryDeleteConfirmDialog(
      String categoryName, BuildContext context) {
    return Dialog(
        insetPadding: EdgeInsets.all(40),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        //this right here
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  icon: Icon(
                    Icons.close_fullscreen,
                    color: Colors.lightBlue,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "Are You Sure To Delete " + categoryName + " Category? ",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              height: 40,
              padding: const EdgeInsets.all(0.0),
              child: Center(
                child: Text(
                  "Below Sub Category Also Deleted",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            Container(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: subCategoryModelList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(subCategoryModelList[index].subCategoryName!),
                  );
                },
              ),
            ),
            Container(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                      child: Center(
                        child: Text(
                          "Delete",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.lightBlue),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop(true);
                      }),
                ),
                Expanded(
                  flex: 1,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.lightBlue,
                    child: GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "Cancel ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop(false);
                        }),
                  ),
                ),
              ],
            ),
            Container(
              height: 10,
            )
          ],
        ));
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

            _cropImage(CroppedFile(path!), context);
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
    //     String name = "category_" + uuid.v4().substring(1, 8) + ".jpeg";
    //     _cropImage(files[0], context);
    //   }
    // });

    setState(() {});
  }

  Future<Null> _cropImage(CroppedFile imageFile, BuildContext context) async {
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
      imageFile = croppedFile;
      String name = "category_" + uuid.v4().substring(1, 8) + ".jpeg";
      testCompressAndGetFile(
              File(imageFile.path), "${destinationDirectory?.path}/$name")
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
