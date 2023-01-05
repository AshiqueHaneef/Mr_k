import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:Mr_k/Models/CategoryModel.dart';
import 'package:Mr_k/Models/SubCategoryModel.dart';
import 'package:Mr_k/Preference/Preference.dart';


import 'CategoryScreen.dart';

class SubCategoryScreen extends StatefulWidget {
  SubCategoryScreen(this.isAddSubCategory, this.subCategoryModelList);
  bool isAddSubCategory = false;
  List<SubCategoryModel> subCategoryModelList = [];

  @override
  SubCategoryViewState createState() =>
      SubCategoryViewState(isAddSubCategory, subCategoryModelList);
}

class SubCategoryViewState extends State<SubCategoryScreen> {
  SubCategoryViewState(this.isAddSubCategory, this.subCategoryModelList);
  bool isAddSubCategory = false;
  List<CategoryModel> categoryModelList = [];
  // List<CategoryModel> filteredCategoryList = [];
  List<SubCategoryModel> filteredSubCategoryList = [];
  List<SubCategoryModel> subCategoryModelList = [];
  List<SubCategoryModel> categoryBasedList = [];
  TextEditingController subCategoryNameController = new TextEditingController();
  bool isCategoryAddLoading = false;
  CategoryModel selectedCategory =  CategoryModel();
  bool isLoading = false;
  bool isDeleting = false;

  @override
  void initState() {
    selectedCategory.categoryName = "Select Category";
    //
    // getAllCategories();
    Preference().getCategoryList().then((value) {
      categoryModelList = value;
    });
    if (null == subCategoryModelList || subCategoryModelList.isEmpty) {
      getAllSubCategories();
    } else {
      categoryBasedList = subCategoryModelList;
      updateSearchQuery("");
    }
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
                selectedCategory = new CategoryModel();
                Navigator.of(context).pop();
              }),
        ),
        Text(
          "Select Sub Category",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        Padding(
          padding: EdgeInsets.all(15.0),
          child: Container(
              width: double.infinity,
              child: TextField(
                maxLines: null,
                controller: subCategoryNameController,
                style: TextStyle(fontSize: 15.0),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  hintMaxLines: 1,
                  labelText: "Enter Sub Category name",
                  prefixStyle: TextStyle(fontSize: 16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (query) => updateSearchQuery(query),
              )),
        ),
        Visibility(
          visible: isAddSubCategory,
          child: ListTile(
            title: Text(
              null != selectedCategory.categoryName!
                  ? selectedCategory.categoryName!
                  : "Select Category",
              textAlign: TextAlign.center,
            ),
            onTap: () {
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
                  isLoading = false;
                  selectedCategory = new CategoryModel();
                  selectedCategory = value;
                  categoryBasedList = subCategoryModelList
                      .where((product) =>
                          (product.categoryId == (selectedCategory.categoryId)))
                      .toList();
                  updateSearchQuery("");
                  setState(() {});
                }
              });
            },
          ),
        ),

        Expanded(
          child: subCategoryView(),
        ),
        // Expanded(
        //   child: categoryView(filteredCategoryList),
        // ),
        Visibility(
            visible: isCategoryAddLoading,
            child: Center(child: CircularProgressIndicator())),
        Visibility(
          visible: isAddSubCategory,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
            child: Text(
              "Add Sub Category",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            onPressed: () {
              if (subCategoryNameController.text.isEmpty ||
                  null == subCategoryNameController.text) {
                Fluttertoast.showToast(
                    msg: "Enter Valid Sub Category",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.blueGrey,
                    textColor: Colors.white,
                    fontSize: 16.0);
              } else if (null == selectedCategory.categoryId ||
                  selectedCategory.categoryId!.isEmpty) {
                Fluttertoast.showToast(
                    msg: "Select Category",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.blueGrey,
                    textColor: Colors.white,
                    fontSize: 16.0);
              } else {
                isCategoryAddLoading = true;
                setState(() {});
                addSubCategory(subCategoryNameController.text,
                    selectedCategory.categoryId!, context);
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

  Widget subCategoryView() {
    if (null != filteredSubCategoryList && filteredSubCategoryList.length > 0) {
      return ListView.builder(
        itemCount: filteredSubCategoryList.length > 0
            ? filteredSubCategoryList.length
            : 0,
        itemBuilder: (BuildContext context, int index) {
          return new ListTile(
              title: Text(
                filteredSubCategoryList[index].subCategoryName!,
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                SubCategoryModel subCategoryModel = new SubCategoryModel();
                subCategoryModel.subCategoryName =
                    filteredSubCategoryList[index].subCategoryName;
                subCategoryModel.categoryId =
                    filteredSubCategoryList[index].categoryId;
                subCategoryModel.subCategoryId =
                    filteredSubCategoryList[index].subCategoryId;

                Navigator.of(context).pop(subCategoryModel);
              },
              trailing: Visibility(
                visible: isAddSubCategory,
                child: GestureDetector(
                  child: Icon(Icons.delete),
                  onTap: () {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => ConfirmDialogScreen(
                            filteredSubCategoryList[index])).then((value) {
                      if (null != value) {
                        subCategoryModelList = value;
                        filteredSubCategoryList = subCategoryModelList
                            .where((product) => (product.categoryId ==
                                (selectedCategory.categoryId)))
                            .toList();
                        setState(() {});
                      }
                    });
                  },
                ),
              ));
        },
      );
    } else {
      return Center(
          child: isLoading
              ? CircularProgressIndicator()
              : Text("No Sub Category Found"));
    }
  }

  // Widget subCategoryDeleteConfirmDialog(
  //     SubCategoryModel subCategory, BuildContext context) {
  //   bool isDeleteLoading=false;
  //   return StatefulBuilder(builder: (context, setStates) {
  //     return
  //   });
  // }

  void updateSearchQuery(String newQuery) {
    //   searchQuery = newQuery;
    if (null != newQuery && newQuery.isNotEmpty) {
      filteredSubCategoryList = categoryBasedList
          .where((product) => (product.subCategoryName!
              .toLowerCase()
              .contains(newQuery.toLowerCase())))
          .toList();
    } else {
      filteredSubCategoryList = categoryBasedList;
    }

    // categoryView(filteredCategoryList);
    setState(() {});
    // productView(context);
  }

  Future addSubCategory(
      String subCategoryName, String categoryId, BuildContext context) async {
    String url = ApiInterFace.BASE_URL +
        ApiInterFace.ADD_SUB_CATEGORY_API +
        "&subCategoryName=" +
        subCategoryName +
        "&categoryId=" +
        categoryId;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      isCategoryAddLoading = false;

      setState(() {});

      List responseModel = json.decode(response.body);
      if (responseModel[0]["error"] == 0) {
        setState(() {
          subCategoryModelList = responseModel
              .map((userData) => new SubCategoryModel.fromJson(userData))
              .toList();
          subCategoryNameController.text = "";
          // filteredSubCategoryList = subCategoryModelList;
          categoryBasedList = subCategoryModelList
              .where((product) =>
                  (product.categoryId == (selectedCategory.categoryId)))
              .toList();
          Preference().setSubCategoryList(response.body);

          updateSearchQuery("");
          setState(() {});
        });
        Fluttertoast.showToast(
            msg: "Sub Category Added Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Sub Category Add Failed",
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

  Future getAllSubCategories() async {
    isLoading = true;
    setState(() {});
    String url = ApiInterFace.BASE_URL + ApiInterFace.GET_ALL_SUB_CATEGORY_API;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      isLoading = false;
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        subCategoryModelList = responseModel
            .map((userData) => new SubCategoryModel.fromJson(userData))
            .toList();

        filteredSubCategoryList = subCategoryModelList
            .where((product) =>
                (product.categoryId == (selectedCategory.categoryId)))
            .toList();
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

class ConfirmDialogScreen extends StatefulWidget {
  ConfirmDialogScreen(this.subCategoryModel);
  SubCategoryModel subCategoryModel;

  @override
  ConfirmDialogViewState createState() =>
      ConfirmDialogViewState(subCategoryModel);
}

class ConfirmDialogViewState extends State<ConfirmDialogScreen> {
  ConfirmDialogViewState(this.subCategoryModel);
  SubCategoryModel subCategoryModel;
  bool isDeleteLoading = false;
  List<SubCategoryModel> subCategoryModelList = [];
  @override
  Widget build(BuildContext context) {
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
                    Navigator.of(context).pop(null);
                  }),
            ),
            Visibility(
              visible: isDeleteLoading,
              child: CircularProgressIndicator(),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  isDeleteLoading
                      ? "Please Wait While Deleting"
                      : "Are You Sure To Delete " +
                          subCategoryModel.subCategoryName! +
                          " Sub Category? ",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
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
                        isDeleteLoading = true;
                        setState(() {});

                        deleteSubCategory(
                                subCategoryModel.subCategoryId!, context)
                            .then((value) {
                          Navigator.of(context).pop(value);
                        });
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
                          Navigator.of(context).pop(null);
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

  Future deleteSubCategory(String subCategoryId, BuildContext context) async {
    String url = ApiInterFace.BASE_URL +
        ApiInterFace.DELETE_SUB_CATEGORY_API +
        "&subCategoryId=" +
        subCategoryId;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      isDeleteLoading = false;
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        subCategoryModelList = responseModel
            .map((userData) => new SubCategoryModel.fromJson(userData))
            .toList();
        Preference().setSubCategoryList(response.body);

        Fluttertoast.showToast(
            msg: responseModel[0]["message"],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        return subCategoryModelList;
      } else {
        isDeleteLoading = false;
        setState(() {});
        Fluttertoast.showToast(
            msg: responseModel[0]["message"],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        return null;
      }
    } else {
      isDeleteLoading = false;
      setState(() {});

      Fluttertoast.showToast(
          msg: "Something went wrong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
      return null;
    }
  }
}
