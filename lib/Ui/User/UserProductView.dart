import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:Mr_k/Models/ImageModel.dart';
import 'package:Mr_k/Models/ProductModel.dart';
import 'package:Mr_k/Preference/Preference.dart';
import 'package:Mr_k/Ui/User/ImageScreen.dart';
import 'package:Mr_k/Utils/DisplaySize.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProductViewScreen extends StatefulWidget {
  UserProductViewScreen(this.productModel);
  ProductModel productModel = ProductModel(
      productId: "",
      description: "",
      categoryId: "",
      subCategoryId: "",
      productName: "",
      iconImageName: "");

  @override
  UserProductViewScreenState createState() =>
      UserProductViewScreenState(productModel);
}

class UserProductViewScreenState extends State<UserProductViewScreen> {
  UserProductViewScreenState(this.productModel);
  bool isLoading = true;
  ProductModel productModel =  ProductModel(
      productId: "",
      description: "",
      categoryId: "",
      subCategoryId: "",
      productName: "",
      iconImageName: "");
  ScrollController scrollController = new ScrollController();
  List<File> _mulitpleFiles = [];
  List<File> files = [];
  List<String> imagePaths = [];
  Directory? destinationDirectory;
  int downloadedCount = 0;
  bool isDescriptionView = false;
  List<ProductModel> favoriteProductList = [];
  List<String> favoriteIdList = [];
  // String size="32,36,40";
  // String color="Red,Black,Green";
  // List sizeList=["30","32","34","36","38","40","42","44","46","48"];

  @override
  void initState() {
    // String lastNo=productModel.productId.substring(productModel.productId.length-1,productModel.productId.length);
    //
    // if(lastNo=="1"){
    //   size="31 , 39 , 40";
    //   color="Red,Black,Green";
    //
    // }else if(lastNo=="2"){
    //   size="32 , 35 , 37";
    //   color="Yellow,Black,Blue";
    //
    // }else if(lastNo=="3"){
    //   size="33 , 35 , 38";
    //   color="White";
    // }else if(lastNo=="4"){
    //   size="33 , 34 , 35";
    //   color="Violet,Yellow,Green";
    // }else if(lastNo=="5"){
    //   size="34 , 36 , 40";
    //   color="Red,White,Green";
    // }else if(lastNo=="6"){
    //   size="34 , 36 , 39";
    //   color="Blue,White,Black";
    // }else if(lastNo=="7"){
    //   size="36 , 37 , 38";
    //   color="All Color ";
    // }else if(lastNo=="3"){
    //   size="32 , 38 , 42";
    //   color="Green,Red,Black";
    //
    // }else if(lastNo=="9"){
    //   size="31 , 39, 40";
    //   color="Blue,White,Yellow";
    //
    // }
    Preference().getFavoriteList().then((value) {
      favoriteProductList = value;
      for (ProductModel productModel in favoriteProductList) {
        favoriteIdList.add(productModel.productId);
      }
      setState(() {});
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
          child: (const Icon(
            Icons.arrow_back,
            color: Colors.blueGrey,
          )),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Padding(
              padding: const EdgeInsets.all(15.0),
              child: downloadedCount > 0
                  ? Center(
                      child: Text(
                        "Downloading " +
                            downloadedCount.toString() +
                            " Of " +
                            productModel.imageList!.length.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        if (kIsWeb) {
                          _launchInBrowser("https://wa.me/971557117184?text=" +
                              productModel.productName +
                              " " +
                              productModel.productId);
                        } else {
                          downloadedCount = 0;
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return imageDownloadDialog();
                              });
                          downloadImages();
                        }
                      },
                    ))
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(children: [
            GestureDetector(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: null != productModel.iconImageName &&
                                productModel.iconImageName.isNotEmpty
                            ? Image.network(
                                ApiInterFace.PRODUCT_IMAGE_URL +
                                    productModel.iconImageName,
                                width: displayWidth(context),
                                height: displayWidth(context) * 0.6,
                                fit: BoxFit.cover,
                                // errorBuilder: (BuildContext context,
                                //     Object exception, StackTrace stackTrace) {
                                //   return SizedBox(
                                //     width: MediaQuery.of(context).size.width * 0.5,
                                //     height: MediaQuery.of(context).size.width * 0.35,
                                //     child: const Icon(
                                //       Icons.image,
                                //       color: Colors.grey,
                                //       size: 90,
                                //     ),
                                //   );
                                // },
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height:
                                    MediaQuery.of(context).size.width * 0.35,
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 90,
                                ),
                              ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CircleAvatar(
                            backgroundColor:
                                favoriteIdList.contains(productModel.productId)
                                    ? Colors.red[50]
                                    : Colors.grey[400],
                            child: GestureDetector(
                              child: Icon(
                                  favoriteIdList
                                          .contains(productModel.productId)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: favoriteIdList
                                          .contains(productModel.productId)
                                      ? Colors.red
                                      : Colors.black),
                              onTap: () {
                                if (favoriteIdList
                                    .contains(productModel.productId)) {
                                  favoriteIdList.remove(productModel.productId);
                                  favoriteProductList.removeWhere((item) =>
                                      item.productId == productModel.productId);
                                } else {
                                  favoriteIdList.add(productModel.productId);
                                  favoriteProductList.add(productModel);
                                }
                                // String jsonIds = jsonEncode(favoriteProductIdList);
                                final String encodedData =
                                    ProductModel.encode(favoriteProductList);

                                Preference().setFavoriteList(encodedData);
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                          padding: const EdgeInsets.only(left: 0, right: 10),
                          child: Container(
                            child: Text(
                              productModel.productName,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          )),
                    ),
                  ),
                  // Card(
                  //   elevation: 0,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(8)
                  //   ),
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Align(
                  //       alignment: Alignment.centerLeft,
                  //       child: Padding(
                  //           padding: EdgeInsets.all(10),
                  //           child: Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               Text("Size available",
                  //               style: TextStyle(
                  //                  fontWeight: FontWeight.bold
                  //               ),),
                  //               Text(size,
                  //                 style: TextStyle(
                  //                     fontWeight: FontWeight.bold
                  //                 ),),
                  //             ],
                  //           )),
                  //     ),
                  //   ),
                  // ),
                  // Card(
                  //   elevation: 0,
                  //   shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8)
                  //   ),
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Align(
                  //       alignment: Alignment.centerLeft,
                  //       child: Padding(
                  //           padding: EdgeInsets.all(10),
                  //           child: Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               Text("Color available",
                  //                 style: TextStyle(
                  //                     fontWeight: FontWeight.bold
                  //                 ),),
                  //               Text(color,
                  //                 style: TextStyle(
                  //                     fontWeight: FontWeight.bold
                  //                 ),),
                  //             ],
                  //           )),
                  //     ),
                  //   ),
                  // ),
                  Visibility(
                    visible: null != productModel.description &&
                        productModel.description.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                            padding: const EdgeInsets.only(left: 0, right: 10),
                            child: Container(
                              height: isDescriptionView ? null : 50,
                              child: Text(
                                productModel.description,
                                overflow: TextOverflow.fade,
                                textAlign: TextAlign.left,
                              ),
                            )),
                      ),
                    ),
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
                  productImageView(),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {}
  }

  shareImages(BuildContext context) async {
    final RenderBox box = context.findRenderObject() as RenderBox;

    if (imagePaths.isNotEmpty) {
      await Share.shareFiles(imagePaths,
          text: productModel.productName,
          subject: productModel.productName,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else {
      await Share.share(productModel.productName,
          subject: productModel.description,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }

  getDirectoryPath() async {
    await getApplicationSupportDirectory().then((value) {
      destinationDirectory = value;
      setState(() {});
    });
  }

  downloadImages() async {
    files = [];
    downloadedCount = 1;
    imagePaths = [];

    setState(() {});

    for (ImageModel imageModel in productModel.imageList!) {
      try {
        var imageId = await ImageDownloader.downloadImage(
          ApiInterFace.PRODUCT_IMAGE_URL + imageModel.imageName!,
          destination: AndroidDestinationType.custom(directory: 'files')
            ..inExternalFilesDir()
            ..subDirectory(imageModel.imageName),
        );
        var path = await ImageDownloader.findPath(imageId!);
        files.add(File(path!));
        imagePaths.add(path);
        downloadedCount = files.length;
        setState(() {});

        if (files.length == productModel.imageList!.length) {
          downloadedCount = 0;
          setState(() {});
          //close downloading dialog
          Navigator.of(context).pop();
          shareImages(context);
        }
      } catch (error) {
        print(error);
      }
    }
    setState(() {
      _mulitpleFiles.addAll(files);
    });
  }

  Widget imageDownloadDialog() {
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        //this right here
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Align(
            //   alignment: Alignment.topRight,
            //   child: IconButton(
            //       icon: Icon(
            //         Icons.close_fullscreen,
            //         color: Colors.lightBlue,
            //       ),
            //       onPressed: () {
            //         Navigator.of(context).pop();
            //       }),
            // ),
            const Padding(
                padding: EdgeInsets.all(15.0),
                child: Center(
                  child: CircularProgressIndicator(),
                )),
            const Text("Please wait ..downloading.."),

            const Padding(padding: EdgeInsets.only(top: 50.0)),
          ],
        ),
      );
    });
  }

  Widget productImageView() {
    if (null != productModel &&
        null != productModel.imageList &&
        productModel.imageList!.length > 0) {
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        shrinkWrap: true,
        itemCount: productModel.imageList!.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            // child: Card(
            //
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(10)),
            // child: Image.network(
            //   ApiInterFace.PRODUCT_IMAGE_URL +
            //       productModel.imageList[index].imageName,
            //   fit: BoxFit.cover,
            //   width: 90,
            //   height: 90,
            // ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: displayHeight(context) * 0.2,
                width: displayHeight(context) * 0.2,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(ApiInterFace.PRODUCT_IMAGE_URL +
                          productModel.imageList![index].imageName!)),
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  color: Colors.redAccent,
                ),
              ),
            ),
            onTap: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => ImageScreen(
                      productModel.imageList!,
                      false,
                      productModel.productName,
                      productModel.productId));
            },
          );
        },
      );
    } else {
      return Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : const Text("No Image Found"),
      );
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
      isLoading = false;
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        productModel.imageList = responseModel
            .map((userData) => new ImageModel.fromJson(userData))
            .toList();

        setState(() {});
      } else {
        isLoading = false;
        setState(() {});
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
}
