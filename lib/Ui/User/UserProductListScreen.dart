import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:Mr_k/Models/CategoryModel.dart';
import 'package:Mr_k/Models/ProductModel.dart';
import 'package:Mr_k/Models/SubCategoryModel.dart';
import 'package:Mr_k/Preference/Preference.dart';
import 'package:Mr_k/Ui/User/UserProductView.dart';

import '../../Api/ApiInterFace.dart';
import 'UserSubCategoryView.dart';

class UserProductListScreen extends StatefulWidget {
  UserProductListScreen(this.categoryModel, this.isFavorite);
  bool isFavorite = false;
  CategoryModel categoryModel = CategoryModel();

  @override
  UserProductListScreenState createState() =>
      UserProductListScreenState(categoryModel, isFavorite);
}

class UserProductListScreenState extends State<UserProductListScreen> {
  UserProductListScreenState(this.categoryModel, this.isFavorite);
  List<ProductModel> productModelList = [];
  List<CategoryModel> categoryModelList = [];
  CategoryModel categoryModel = new CategoryModel();
  SubCategoryModel subCategoryModel = new SubCategoryModel();

  bool isFavorite = false;
  bool isLoading = true;

  List<String> categoryIds = [];
  @override
  void initState() {
    if (isFavorite) {
      Preference().getFavoriteList().then((value) {
        productModelList = value;
        isLoading = false;
        setState(() {});
      });
    } else {
      Preference().getCategoryList().then((value) {
        categoryModelList = value;
      });
      subCategoryModel.categoryId = categoryModel.categoryId;
      subCategoryModel.subCategoryId = "";
      getAllProductsInCategory();
    }
    // Timer.run(() => selectCategory(true));

    super.initState();
  }

  selectCategory(bool isFromMenuScreen) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => Dialog(
              insetPadding: EdgeInsets.all(10),
              child: UserSubCategoryScreen(isFromMenuScreen, categoryModel),
            )).then((value) {
      if (null != value) {
        productModelList = [];
        subCategoryModel = value;
        setState(() {});

        getAllProductsInCategory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (categoryIds.isEmpty) {
          Navigator.of(context).pop();
          // Navigator.of(context).pop();
        } else {
          Fluttertoast.showToast(msg: "");
        }
        exit(0);
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              isFavorite ? "Favorites" : "",
              style: TextStyle(color: Colors.grey),
            ),
            leading: GestureDetector(
              child: (Icon(
                Icons.arrow_back,
                color: Colors.blueGrey,
              )),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(child: productView()),
                    ],
                  ),
                ),
                !isFavorite
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10, bottom: 20),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: GestureDetector(
                                  child: ElevatedButton(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        child: Icon(
                                          Icons.menu,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: null !=
                                                subCategoryModel.subCategoryName
                                            ? "  " +
                                                subCategoryModel
                                                    .subCategoryName!
                                            : "  ${categoryModel.categoryName ?? ""}",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                onPressed: () {
                                  selectCategory(false);
                                },
                              )),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 0,
                        width: 0,
                      ),
              ],
            ),
          )),
    );
  }

  Widget productView() {
    if (null != productModelList && productModelList.length > 0) {
      return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
        ),
        shrinkWrap: true,
        itemCount: productModelList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Wrap(
                  children: [
                    null != productModelList[index].iconImageName &&
                            productModelList[index].iconImageName.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: ApiInterFace.PRODUCT_IMAGE_URL +
                                productModelList[index].iconImageName,
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.width * 0.35,
                            httpHeaders: ApiInterFace.headers,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                              backgroundColor: Colors.blueGrey,
                            )),
                            errorWidget: (context, url, error) => Icon(
                              Icons.image,
                              size: 90,
                            ),
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.width * 0.35,
                            child: Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 90,
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            productModelList[index].productName,
                            style: TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04
                                // backgroundColor: Colors.grey
                                ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) =>
                          UserProductViewScreen(productModelList[index])))
                  .then((value) {
                if (isFavorite) {
                  Preference().getFavoriteList().then((value) {
                    productModelList = value;

                    setState(() {});
                  });
                }
              });
            },
          );
        },
      );
    } else {
      if (isLoading) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: Text(
              "No Product Found",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
  }

  Future getAllProductsInCategory() async {
    isLoading = true;
    String subCategoryId = null != subCategoryModel.subCategoryId! &&
            subCategoryModel.subCategoryId!.isNotEmpty
        ? subCategoryModel.subCategoryId!
        : "0";
    setState(() {});
    String url = ApiInterFace.BASE_URL +
        ApiInterFace.GET_ALL_PRODUCTS_BY_CATEGORY_API +
        "&categoryId=" +
        subCategoryModel.categoryId! +
        "&subCategoryId=" +
        subCategoryId;

    http.Client client = new http.Client();

    try {
      final response =
          await client.get(Uri.parse(url), headers: ApiInterFace.headers);

      if (response.statusCode == 200) {
        isLoading = false;
        setState(() {});
        String sss = response.body;
        List responseModel = json.decode(response.body);

        if (responseModel[0]["error"] == 0) {
          productModelList = responseModel
              .map((userData) => new ProductModel.fromJson(userData))
              .toList();

          setState(() {});
        } else {
          isLoading = false;
          Fluttertoast.showToast(
              msg: "No Products Found",
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
    } catch (_) {
      client.close();
    }
  }
}
