import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:Mr_k/Models/CategoryModel.dart';
import 'package:Mr_k/Models/ImageModel.dart';
import 'package:Mr_k/Models/ProductModel.dart';
import 'package:Mr_k/Models/SubCategoryModel.dart';
import 'package:Mr_k/Preference/Preference.dart';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:async/async.dart";

import 'package:path/path.dart';

import 'CategoryScreen.dart';
import 'SubCategoryScreen.dart';

class ProductAddScreen extends StatefulWidget {
  ProductAddScreen(this.productModel, this.isAddProduct);
  ProductModel productModel;
  bool isAddProduct = false;

  @override
  ProductAddPageState createState() =>
      ProductAddPageState(productModel, isAddProduct);
}

class ProductAddPageState extends State<ProductAddScreen> {
  ProductAddPageState(this.productModel, this.isAddProduct);
  bool isAddProduct = false;
  TextEditingController productNameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  ProductModel productModel =  ProductModel(productId: "", description: "", categoryId: "", subCategoryId: "", productName: "", iconImageName: "");
  CategoryModel selectedCategoryModel = new CategoryModel();
  SubCategoryModel selectedSubCategoryModel = new SubCategoryModel();
  var uuid = Uuid();
  bool isDescriptionView = false;
  double? _progressValue;
  Directory? destinationDirectory;
  bool isNameError = false;
  bool isLoading = false;
  String uploadBtnText = "Save Product Details";
  bool isUploadDisabled = false;
  int uploadingCompletedIndex = 0;
  List<CategoryModel> categoryModelList = [];
  List<SubCategoryModel> subCategoryModelList = [];
  List<SubCategoryModel> filteredSubCategoryModelList = [];
  int totalNewImages = 0;
  File? _file;
  File? imageFile;
  bool isLocalIconImageSelected = false;
  List<Asset> resultList = <Asset>[];
  String error = 'No Error Detected';
  List<Asset> images = <Asset>[];
  @override
  void initState() {
    productModel.imageList = [];
    productNameController.text = productModel.productName;
    descriptionController.text = productModel.description;
    setState(() {});
    Preference().getCategoryList().then((value) {
      categoryModelList = value;
      if (null != categoryModelList && categoryModelList.length > 0) {
        for (CategoryModel categoryModel in categoryModelList) {
          if (categoryModel.categoryId == productModel.categoryId) {
            selectedCategoryModel = categoryModel;
            break;
          }
        }
        Preference().getSubCategoryList().then((value) {
          subCategoryModelList = value;

          setState(() {});
          if (null == subCategoryModelList ||
              subCategoryModelList.length <= 0) {
            getAllSubCategories();
          } else {
            for (SubCategoryModel subCategoryModel in subCategoryModelList) {
              if (subCategoryModel.subCategoryId ==
                  productModel.subCategoryId) {
                selectedSubCategoryModel = subCategoryModel;
                filteredSubCategoryModelList = subCategoryModelList
                    .where((category) => (category.categoryId ==
                        (selectedCategoryModel.categoryId)))
                    .toList();
                break;
              }
            }
          }
        });
        setState(() {});
      } else {
        getAllCategories();
      }
    });
    getProductImages();

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
                "Edit Product",
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
                        productDeleteConfirmDialog(
                            productModel.productName, context)).then((value) {
                  if (value == true) {
                    isLoading = true;
                    setState(() {});
                    deleteProduct(context).then((value) {
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

        // Text(
        //   "Edit Product",
        //   style: TextStyle(
        //       color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 20),
        // ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
        children: [
          Container(
            height: 10,
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: iconImageView(),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                      child: TextField(
                    controller: productNameController,
                    style: TextStyle(fontSize: 15.0),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 0),
                      hintMaxLines: 1,
                      labelText: "Product name",
                      prefixStyle: TextStyle(fontSize: 16.0),
                    ),
                  )),
                ),
              ),
            ],
          ),
          Container(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Container(
                width: double.infinity,
                child: TextField(
                  controller: descriptionController,
                  maxLines: isDescriptionView ? null : 3,
                  style: TextStyle(fontSize: 15.0),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 0),
                    hintMaxLines: 1,
                    labelText: "Description",
                    prefixStyle: TextStyle(fontSize: 16.0),
                  ),
                )),
          ),
          GestureDetector(
            child: Icon(isDescriptionView
                ? Icons.arrow_drop_down_outlined
                : Icons.arrow_drop_up_outlined),
            onTap: () {
              isDescriptionView = !isDescriptionView;
              setState(() {});
            },
          ),
          ListTile(
            title: Text(null != selectedCategoryModel.categoryName! &&
                    selectedCategoryModel.categoryName!.isNotEmpty
                ? selectedCategoryModel.categoryName!
                : "Select Category"),
            onTap: () {
              CategoryModel dummyCategory = new CategoryModel();

              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => Dialog(
                        insetPadding: EdgeInsets.all(20),
                        child: categoryScreen(false, categoryModelList),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                      )).then((value) {
                if (null != value) {
                  dummyCategory = value;

                  filteredSubCategoryModelList = subCategoryModelList
                      .where((category) =>
                          (category.categoryId == (dummyCategory.categoryId)))
                      .toList();

                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) => Dialog(
                            insetPadding: EdgeInsets.all(20),
                            child: SubCategoryScreen(
                                false, filteredSubCategoryModelList),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                          )).then((value) {
                    if (null != value) {
                      selectedCategoryModel = new CategoryModel();
                      selectedCategoryModel = dummyCategory;
                      selectedSubCategoryModel = new SubCategoryModel();
                      selectedSubCategoryModel = value;
                      setState(() {});
                    }
                  });

                  setState(() {});
                }
              });
            },
          ),
          ListTile(
            title: Text(null != selectedSubCategoryModel.subCategoryName! &&
                    selectedSubCategoryModel.subCategoryName!.isNotEmpty
                ? selectedSubCategoryModel.subCategoryName!
                : "Select Category Again"),
            // onTap: () {
            //   showDialog(
            //       context: context,
            //       barrierDismissible: false,
            //       builder: (BuildContext context) => Dialog(
            //             child: SubCategoryScreen(
            //                 false, filteredSubCategoryModelList),
            //             shape: RoundedRectangleBorder(
            //                 borderRadius: BorderRadius.circular(12.0)),
            //           )).then((value) {
            //     if (null != value) {
            //       selectedSubCategoryModel = new SubCategoryModel();
            //       selectedSubCategoryModel = value;
            //       setState(() {});
            //     }
            //   });
            // },
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Container(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlue,
                  ),
                  child: Text(
                    "Select image",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  onPressed: () {
                    _requestPermission().then((value) {
                      selectImage(context);
                      // getImage();
                    });
                  }),
            ),
          ),
          Container(
            height: 5,
          ),
          Visibility(
            visible: null != productModel.imageList &&
                productModel.imageList!.length > 0,
            child: Text(
              "Select Any One Image From Below To Select As Thumbnail",
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: productImageView(),
          ),
          Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary:
                      isUploadDisabled ? Colors.grey : Colors.lightBlueAccent,
                ),
                child: Text(
                  uploadBtnText,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  // progress=productModel.imageList.length / 10;

                  productModel.description = descriptionController.text;
                  if (null != selectedSubCategoryModel.subCategoryId &&
                      null != selectedCategoryModel.categoryId) {
                    if (!isUploadDisabled) {
                      if (null != productModel.imageList &&
                          productModel.imageList!.length > 0) {
                        for (ImageModel imageModel in productModel.imageList!) {
                          if (null == imageModel.imageId ||
                              imageModel.imageId!.isEmpty) {
                            //upload only new image
                            totalNewImages = totalNewImages + 1;
                          }
                        }
                      }
                      uploadBtnText = "Uploading " +
                          uploadingCompletedIndex.toString() +
                          " of " +
                          totalNewImages.toString();

                      setState(() {});
                      uploadData(
                          productNameController.text,
                          productModel.productId,
                          descriptionController.text,
                          context);
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
                  } else {
                    Fluttertoast.showToast(
                        msg: "Select category or subcategory",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blueGrey,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
              ),
            ),
          ),
        ],
      ))),
    );
  }

  Widget iconImageView() {
    if (null != productModel.iconImageName &&
        productModel.iconImageName.isNotEmpty &&
        !isLocalIconImageSelected) {
      return Image.network(
        ApiInterFace.PRODUCT_IMAGE_URL + productModel.iconImageName,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      );
    } else if (isLocalIconImageSelected) {
      if (null == productModel.iconImageId ||
          productModel.iconImageId!.isEmpty) {
        return Image.file(
           File(null != destinationDirectory
              ? "${destinationDirectory?.path}/${productModel.iconImageName}"
              : ""),
          width: 90,
          height: 90,
          fit: BoxFit.cover,
        );
      } else {
        return Image.network(
          ApiInterFace.PRODUCT_IMAGE_URL + productModel.iconImageName,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
        );
      }
    } else {
      return Container(
        width: 90,
        height: 90,
        child: Icon(
          Icons.image,
          color: Colors.grey,
          size: 90,
        ),
      );
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

  Widget productImageView() {
    if (null != productModel &&
        null != productModel.imageList &&
        productModel.imageList!.length > 0) {
      return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
        ),
        shrinkWrap: true,
        itemCount: productModel.imageList!.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              GestureDetector(
                child: Card(
                  child: null == productModel.imageList![index].imageId ||
                          productModel.imageList![index].imageId!.isEmpty
                      ? Image.file(
                          new File(destinationDirectory!.path +
                              "/" +
                              productModel.imageList![index].imageName!),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          ApiInterFace.PRODUCT_IMAGE_URL +
                              productModel.imageList![index].imageName!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                ),
                onTap: () {
                  isLocalIconImageSelected = true;

                  productModel.iconImageName =
                      productModel.imageList![index].imageName!;
                  productModel.iconImageId =
                      productModel.imageList![index].imageId;
                  setState(() {});
                },
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: null == productModel.imageList![index].deletingStatus ||
                          productModel.imageList![index].deletingStatus == 0
                      ? GestureDetector(
                          child: Icon(
                            Icons.delete,
                            color: Colors.orange,
                          ),
                          onTap: () {
                            if (null == productModel.imageList![index].imageId ||
                                productModel.imageList![index].imageId!.isEmpty) {
                              productModel.imageList!.removeAt(index);
                            } else {
                              productModel.imageList![index].deletingStatus = 1;
                              deleteImage(
                                  productModel.imageList![index].imageName!,
                                  productModel.imageList![index].imageId!,
                                  index);
                            }
                            setState(() {});
                          },
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(),
                          ),
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

  Widget productDeleteConfirmDialog(String productName, BuildContext context) {
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
                  "Are You Sure To Delete " + productName + "? ",
                  style: TextStyle(fontSize: 15),
                ),
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

  selectImage(BuildContext context) async {
    try {
      await MultiImagePicker.pickImages(
        maxImages: 30,
        enableCamera: false,
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
    //   if (null != files && files.length > 1) {
    //     for (File file in files) {
    //       String name = productModel.productId +
    //           "_" +
    //           uuid.v4().substring(1, 8) +
    //           ".jpeg";
    //       testCompressAndGetFile(file, destinationDirectory.path + "/" + name)
    //           .then((value) {
    //         File compressedFile = value;
    //         ImageModel imageModel = new ImageModel();
    //         imageModel.imageName = name;
    //         // if(!productModel.imageList.contains(imageModel)){
    //         productModel.imageList.insert(0, imageModel);
    //         setState(() {});
    //       });
    //     }
    //   } else {
    //     if (null != files && files.length == 1) {
    //       _cropImage(files[0], context);
    //     }
    //   }
    // });
  }

  prepareImage(BuildContext context) async {
    if (resultList != null) {
      // List<File> files = result.paths.map((path) => File(path)).toList();
      if (null != resultList && resultList.length > 1) {
        for (Asset file in resultList) {
          String name = productModel.productId +
              "_" +
              uuid.v4().substring(1, 8) +
              ".jpeg";
          var path = await FlutterAbsolutePath.getAbsolutePath(file.identifier!);

          testCompressAndGetFile(
                  File(path!), "${destinationDirectory?.path}/$name")
              .then((value) {
            File? compressedFile = value;
            ImageModel imageModel = new ImageModel();
            imageModel.imageName = name;
            // if(!productModel.imageList.contains(imageModel)){
            productModel.imageList?.insert(0, imageModel);
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
      String name =
          productModel.productId + "_" + uuid.v4().substring(1, 8) + ".jpeg";
      testCompressAndGetFile(imageFile, "${destinationDirectory?.path}/$name")
          .then((value) {
        File? compressedFile = value;
        ImageModel imageModel = new ImageModel();
        imageModel.imageName = name;
        // if(!productModel.imageList.contains(imageModel)){
        productModel.imageList!.insert(0, imageModel);
        // Navigator.of(context).pop();
        setState(() {});
      });
    }
  }

  Future deleteProduct(BuildContext context) async {
    String url = ApiInterFace.BASE_URL +
        ApiInterFace.PRODUCT_DELETE_API +
        "&productId=" +
        productModel.productId;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      isLoading = false;
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
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

  Future deleteImage(String fileName, String imageId, int index) async {
    String url = ApiInterFace.BASE_URL +
        ApiInterFace.IMAGE_DELETE_API +
        "&imageFileName=" +
        fileName +
        "&imageId=" +
        imageId;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        productModel.imageList!.removeAt(index);
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
        productModel.imageList![index].deletingStatus = 0;
        setState(() {});
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
      productModel.imageList![index].deletingStatus = 0;
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

  Future getProductImages() async {
    setState(() {});
    String url = ApiInterFace.BASE_URL +
        ApiInterFace.GET_PRODUCT_IMAGE_API +
        "&productId=" +
        productModel.productId;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        productModel.imageList = responseModel
            .map((userData) => new ImageModel.fromJson(userData))
            .toList();

        setState(() {});
      } else {
        Fluttertoast.showToast(
            msg: "No Image Found",
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

  Future getAllSubCategories() async {
    setState(() {});
    String url = ApiInterFace.BASE_URL + ApiInterFace.GET_ALL_SUB_CATEGORY_API;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        subCategoryModelList = responseModel
            .map((userData) => new SubCategoryModel.fromJson(userData))
            .toList();

        for (SubCategoryModel subCategoryModel in subCategoryModelList) {
          if (subCategoryModel.subCategoryId == productModel.subCategoryId) {
            selectedSubCategoryModel = subCategoryModel;
            filteredSubCategoryModelList = subCategoryModelList
                .where((category) =>
                    (category.categoryId == (selectedCategoryModel.categoryId)))
                .toList();
            break;
          }
        }

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

  Future getAllCategories() async {
    setState(() {});
    String url = ApiInterFace.BASE_URL + ApiInterFace.GET_ALL_CATEGORY_API;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        categoryModelList = responseModel
            .map((userData) => new CategoryModel.fromJson(userData))
            .toList();

        for (CategoryModel categoryModel in categoryModelList) {
          if (categoryModel.categoryId == productModel.categoryId) {
            selectedCategoryModel = categoryModel;
            break;
          }
        }
        getAllSubCategories();
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

  Future<bool> _requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      if (statuses[0] == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
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
  // Future<Null> _cropImage() async {
  //   File? croppedFile = await ImageCropper.cropImage(
  //       sourcePath: imageFile!.path,
  //       aspectRatioPresets: Platform.isAndroid
  //           ? [
  //         CropAspectRatioPreset.square,
  //         CropAspectRatioPreset.ratio3x2,
  //         CropAspectRatioPreset.original,
  //         CropAspectRatioPreset.ratio4x3,
  //         CropAspectRatioPreset.ratio16x9
  //       ]
  //           : [
  //         CropAspectRatioPreset.original,
  //         CropAspectRatioPreset.square,
  //         CropAspectRatioPreset.ratio3x2,
  //         CropAspectRatioPreset.ratio4x3,
  //         CropAspectRatioPreset.ratio5x3,
  //         CropAspectRatioPreset.ratio5x4,
  //         CropAspectRatioPreset.ratio7x5,
  //         CropAspectRatioPreset.ratio16x9
  //       ],
  //       androidUiSettings: AndroidUiSettings(
  //           toolbarTitle: 'Cropper',
  //           toolbarColor: Colors.deepOrange,
  //           toolbarWidgetColor: Colors.white,
  //           initAspectRatio: CropAspectRatioPreset.original,
  //           lockAspectRatio: false),
  //       iosUiSettings: IOSUiSettings(
  //         title: 'Cropper',
  //       ));
  // }

  Future<bool> requestStoragePermission() async {
    return _requestPermission();
  }

  Future uploadImages(ImageModel imageModel, BuildContext context) async {
    String url = ApiInterFace.BASE_URL + ApiInterFace.UPLOAD_IMAGE_API;

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
    request.fields['productId'] = productModel.productId;

    final respond = await request.send();

    if (respond.statusCode == 200) {
      uploadingCompletedIndex = uploadingCompletedIndex + 1;
      if (uploadingCompletedIndex < totalNewImages) {
        uploadBtnText = "Uploading " +
            uploadingCompletedIndex.toString() +
            " of " +
            totalNewImages.toString();
      } else {
        uploadBtnText = "Data Update Successful";
        isUploadDisabled = true;
      }
      setState(() {});
      print("Image Uploaded");
    } else {
      print("Upload Failed");
    }
  }

  Future uploadData(String productName, String productId, String description,
      BuildContext context) async {
    String url = ApiInterFace.BASE_URL + ApiInterFace.UPDATE_PRODUCT_API;

    productModel.productId = productId;
    productModel.productName = productName;
    productModel.description = description;
    productModel.categoryId = selectedCategoryModel.categoryId!;
    productModel.subCategoryId = selectedSubCategoryModel.subCategoryId!;

    String userJson = ProductModel.toJson(productModel);

    final response = await http.post(Uri.parse(url),
        headers: ApiInterFace.headers, body: userJson);
    if (response.statusCode == 200) {
      List responseModel = json.decode(response.body);
      if (responseModel[0]["error"] == 0) {
        if (totalNewImages > 0) {
          for (ImageModel imageModel in productModel.imageList!) {
            uploadingCompletedIndex = 0;
            setState(() {});
            if (null == imageModel.imageId || imageModel.imageId!.isEmpty) {
              //upload only new image
              uploadImages(imageModel, context);
            }
          }
        } else {
          uploadBtnText = "Data Update Successful";
          isUploadDisabled = true;
          if (isAddProduct) {
            sendPushMessage(userJson);
          }
        }
        setState(() {});
      } else {
        Fluttertoast.showToast(
            msg: responseModel[0]["message"],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  Future<void> sendPushMessage(String userJson) async {
    setState(() {});
    String url =
        ApiInterFace.BASE_URL + ApiInterFace.SEND_PUSH_NOTIFICATION_API;

    final response = await http.post(Uri.parse(url),
        headers: ApiInterFace.headers, body: userJson);
    if (response.statusCode == 200) {
      String aaa = response.body.toString();
    }
  }
}
