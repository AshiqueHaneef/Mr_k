import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Mr_k/Models/CategoryModel.dart';
import 'package:Mr_k/Preference/Preference.dart';

import '../../Models/SubCategoryModel.dart';

class UserSubCategoryScreen extends StatefulWidget {
  UserSubCategoryScreen(this.isFromMenuScreen, this.categoryModel);
  bool isFromMenuScreen = false;
  CategoryModel categoryModel = new CategoryModel();

  @override
  UserSubCategoryViewState createState() =>
      UserSubCategoryViewState(isFromMenuScreen, categoryModel);
}

class UserSubCategoryViewState extends State<UserSubCategoryScreen> {
  UserSubCategoryViewState(this.isFromMenuScreen, this.categoryModel);
  bool isFromMenuScreen = false;
  List<CategoryModel> categoryModelList = [];
  List<SubCategoryModel> subCategoryModelList = [];
  List<SubCategoryModel> filteredSubCategoryModelList = [];
  bool isFirstClick = true;

  CategoryModel categoryModel = new CategoryModel();

  @override
  void initState() {
    Preference().getCategoryList().then((value) {
      categoryModelList = value;
      Preference().getSubCategoryList().then((value) {
        subCategoryModelList = value;

        if (null != categoryModel.categoryId) {
          filteredSubCategoryModelList = subCategoryModelList
              .where((product) =>
                  (product.categoryId == (categoryModel.categoryId)))
              .toList();
        } else {
          filteredSubCategoryModelList = subCategoryModelList
              .where((product) =>
                  (product.categoryId == (categoryModelList[0].categoryId)))
              .toList();
          categoryModel = categoryModelList[0];
        }
        setState(() {});
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (isFromMenuScreen) {
          Navigator.of(context).pop(null);
          Navigator.of(context).pop(null);
        } else {
          Navigator.of(context).pop(null);
        }
        exit(0);
      },
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              "Select Sub Category",
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            leading: GestureDetector(
              child: (Icon(
                Icons.arrow_back,
                color: Colors.blueGrey,
              )),
              onTap: () {
                if (isFromMenuScreen) {
                  Navigator.of(context).pop(null);
                  Navigator.of(context).pop(null);
                } else {
                  Navigator.of(context).pop(null);
                }
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Container(height:70,child: categoryView(categoryModelList)),

                Expanded(
                  flex: 2,
                  child:
                      Container(color: Colors.white, child: subCategoryView()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget subCategoryView() {
    if (null != filteredSubCategoryModelList &&
        filteredSubCategoryModelList.length > 0) {
      return GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2,
        ),
        itemCount: filteredSubCategoryModelList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: Text(
                      filteredSubCategoryModelList[index].subCategoryName!)),
            ),
            onTap: () {
              Navigator.of(context).pop(filteredSubCategoryModelList[index]);
              setState(() {});
            },
          );
        },
      );
    } else {
      return Center(child: Text("No Sub Category Found"));
    }
  }
}
