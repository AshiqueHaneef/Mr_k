import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:http/http.dart' as http;
import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:Mr_k/Models/CategoryModel.dart';
import 'package:Mr_k/Preference/Preference.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart';

import 'EditCategory.dart';

class categoryScreen extends StatefulWidget {
  categoryScreen(this.isAddCategory, this.categoryModelList);

  bool isAddCategory = false;
  List<CategoryModel> categoryModelList = [];


  @override
  CategoryViewState createState() =>
      CategoryViewState(isAddCategory, categoryModelList);
}

class CategoryViewState extends State<categoryScreen> {
  CategoryViewState(this.isAddCategory, this.categoryModelList);
  var uuid = Uuid();
  bool isAddCategory = false;
  CategoryModel categoryModel = new CategoryModel();
  Directory? destinationDirectory;
  List<CategoryModel> categoryModelList = [];
  List<CategoryModel> filteredCategoryList = [];
  TextEditingController categoryNameController = new TextEditingController();
  bool isCategoryAddLoading = false;
  List<Asset> resultList = <Asset>[];
  String error = 'No Error Detected';

  Widget categoryView(List<CategoryModel> filteredCategoryList) {
    if (null != categoryModelList && categoryModelList.length > 0) {
      return ListView.builder(
        itemCount:
            filteredCategoryList.length > 0 ? filteredCategoryList.length : 0,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      child: Text(
                        filteredCategoryList[index].categoryName!,
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: (){
                        if(isAddCategory){
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => EditCategoryScreen(filteredCategoryList[index]))).then((value){

                              if (value == true) {
                                categoryModelList=[];
                                filteredCategoryList=[];
                                setState(() {

                                });
                                getAllCategories();
                              }


                          });
                        }else {
                          CategoryModel categoryModel = new CategoryModel();
                          categoryModel.categoryName =
                              filteredCategoryList[index].categoryName;
                          categoryModel.categoryId =
                              filteredCategoryList[index].categoryId;

                          Navigator.of(context).pop(categoryModel);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
  Widget categoryIconImage (CategoryModel categoryModel){

    if(null!=categoryModel.imageName  && categoryModel.imageName!.isNotEmpty) {
      return  Image.network(
          ApiInterFace.CATEGORY_IMAGE_URL + categoryModel.imageName!,

          height: 60,width: 60,

      );
    }else{
      return Container(height: 0,width: 0,);
    }
  }

  @override
  void initState() {
    if (null == categoryModelList || categoryModelList.isEmpty) {
      getAllCategories();
    } else {
      filteredCategoryList = categoryModelList;
    }
    getDirectoryPath();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          Text(
            "Select Category",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Container(
                width: double.infinity,
                child: TextField(
                  maxLines: null,
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
                  onChanged: (query) => updateSearchQuery(query),
                )),
          ),
          Visibility(visible: isAddCategory, child: categoryImage(context)),
          Expanded(
            child: categoryView(filteredCategoryList),
          ),
          Visibility(
              visible: isCategoryAddLoading,
              child: Center(child: CircularProgressIndicator())),
          Visibility(
            visible: isAddCategory,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlue,
              ),
              child: Text(
                "Add Category",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              onPressed: () {
                if (categoryNameController.text.isEmpty) {
                  Fluttertoast.showToast(
                      msg: "Enter valid category name",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.blueGrey,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else {
                  isCategoryAddLoading = true;
                  FocusManager.instance.primaryFocus?.unfocus();

                  setState(() {});
                  addCategory(categoryNameController.text,"0", context);
                }
              },
            ),
          ),
          Container(
            height: 10,
          ),
          Container(
            height: 10,
          )
        ],
    );
  }

  Widget categoryImage(BuildContext context) {
    if (null != destinationDirectory && null != categoryModel.imageName) {
      return Image.file(
        File("${destinationDirectory?.path}/${categoryModel.imageName}"),
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      );
    } else {
      return Center(
          child: ElevatedButton(
        child: Text(
          "Select image",
          style: TextStyle(color: Colors.black),
        ),
        onPressed: () {
          selectImage(context);
        },
      ));
    }
  }

  getDirectoryPath() async {
    if(Platform.isIOS) {
      await getLibraryDirectory().then((value) {
        destinationDirectory = value;
        setState(() {});
      });
    }else{
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

        resultList=value;
        if(resultList != null) {
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
    //     String name = "category_" + uuid.v4().substring(1, 8) + ".jpeg";
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
        uiSettings: [AndroidUiSettings(
            toolbarTitle: 'Crop image',
            toolbarColor: Colors.lightBlue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
           IOSUiSettings(
          title: 'Crop image',
        )
            
            ]
        );
    if (croppedFile != null) {
      imageFile = File(croppedFile.path);
      String name = "category_" + uuid.v4().substring(1, 8) + ".jpeg";
      testCompressAndGetFile(imageFile, "${destinationDirectory?.path}/$name")
          .then((value) {
        File compressedFile = value;
        categoryModel.imageName = name;
        setState(() {});
      });
    }
  }

  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 25,
    );

    print(file.lengthSync());
    print(result!.lengthSync());

    return result;
  }

  void updateSearchQuery(String newQuery) {
    //   searchQuery = newQuery;
    if (null != newQuery && newQuery.isNotEmpty) {
      filteredCategoryList = categoryModelList
          .where((product) => (product.categoryName!
              .toLowerCase()
              .contains(newQuery.toLowerCase())))
          .toList();
    } else {
      filteredCategoryList = categoryModelList;
    }

    categoryView(filteredCategoryList);
    setState(() {});
    // productView(context);
  }


  Future addCategory(String categoryName,String categoryId, BuildContext context) async {
    String url = ApiInterFace.BASE_URL +
        ApiInterFace.ADD_CATEGORY_API;
    http.Response response;
    if(null!=categoryModel.imageName && categoryModel.imageName!.isNotEmpty) {
      File imageFile =
      File("${destinationDirectory?.path}/${categoryModel.imageName}");
      String fileName = imageFile.path
          .split("/")
          .last;
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();

      var request = http.MultipartRequest("POST", Uri.parse(url));
      var multipartFile = http.MultipartFile("file", stream, length,
          filename: basename(imageFile.path));

      request.files.add(multipartFile);
      request.fields['imageFileName'] = fileName;
      request.fields['categoryName'] = categoryName;
      request.fields['categoryId'] = categoryId;


      response =
      await http.Response.fromStream(await request.send());
      print("Result: ${response.statusCode}");
    }else {
      url = url +
          "&categoryName=" +
          categoryName +
          "&categoryId=" +
          categoryId;
      response = await http.get(Uri.parse(url), headers: ApiInterFace.headers);
    }

    if (response.statusCode == 200) {
      isCategoryAddLoading = false;
      List responseModel = json.decode(response.body);
      if (responseModel[0]["error"] == 0) {
        categoryModel = new CategoryModel();
        setState(() {
          categoryModelList = responseModel
              .map((userData) => new CategoryModel.fromJson(userData))
              .toList();
          categoryNameController.text = "";
          Preference().setCategoryList(response.body);
          filteredCategoryList = categoryModelList;
          setState(() {});
        });
        Fluttertoast.showToast(
            msg: "Category Added Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Category Add Failed",
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

  Future getAllCategories() async {
    setState(() {});
    String url = ApiInterFace.BASE_URL + ApiInterFace.GET_ALL_CATEGORY_API;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        categoryModelList = responseModel
            .map((userData) => new CategoryModel.fromJson(userData))
            .toList();

        filteredCategoryList = categoryModelList;
        setState(() {});
      } else {
        Fluttertoast.showToast(
            msg: "No Category Found",
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
}
