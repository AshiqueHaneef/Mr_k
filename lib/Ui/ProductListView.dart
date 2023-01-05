import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:Mr_k/Models/ProductModel.dart';

import 'ProductAddScreen.dart';

class ProductListScreen extends StatefulWidget {
  ProductListScreen();

  @override
  ProductListScreenState createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  ProductListScreenState();
  List<ProductModel> filteredProductModelList = [];
  List<ProductModel> productModelList = [];
  bool isSearchMode = false;

  @override
  void initState() {
    getProductList();
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
        title: Stack(
          children: [
            Visibility(
              visible: !isSearchMode,
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "All Products",
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            ),
            Visibility(
              visible: isSearchMode,
              child: Align(
                  alignment: Alignment.topLeft,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      suffixIcon: IconButton(
                        onPressed: () {
                          isSearchMode = !isSearchMode;
                          updateSearchQuery("");
                          setState(() {});
                        },
                        icon: Icon(Icons.clear),
                      ),
                    ),
                    onChanged: (query) => updateSearchQuery(query),
                  )),
            ),
            Visibility(
              visible: !isSearchMode,
              child: GestureDetector(
                child: Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      Icons.search,
                      color: Colors.blueGrey,
                    )),
                onTap: () {
                  isSearchMode = !isSearchMode;
                  updateSearchQuery("");
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: productView(),
      ),
    );
  }

  Widget productView() {
    if (null != filteredProductModelList &&
        filteredProductModelList.length > 0) {
      return ListView.builder(
        itemCount: filteredProductModelList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: new ListTile(
              title: Text(
                filteredProductModelList[index].productName,
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => ProductAddScreen(
                            filteredProductModelList[index], false)))
                    .then((value) {
                  if (value == true) {
                    filteredProductModelList = [];
                    productModelList = [];
                    updateSearchQuery("");
                    getProductList();
                  }
                });
              },
            ),
          );
        },
      );
    } else {
      return Center(
        child: isSearchMode
            ? Text("No Products Found")
            : CircularProgressIndicator(),
      );
    }
  }

  Future getProductList() async {
    setState(() {});
    String url = ApiInterFace.BASE_URL + ApiInterFace.GET_ALL_PRODUCTS_API;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);
      String responseString = response.body;

      if (responseModel[0]["error"] == 0) {
        productModelList = responseModel
            .map((userData) => new ProductModel.fromJson(userData))
            .toList();
        updateSearchQuery("");

        setState(() {});
      } else {
        Fluttertoast.showToast(
            msg: "No Product Found",
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

  void updateSearchQuery(String newQuery) {
    //   searchQuery = newQuery;
    if (null != productModelList && productModelList.length > 0) {
      if (null != newQuery && newQuery.isNotEmpty) {
        filteredProductModelList = productModelList
            .where((product) => ((product.productName +" "+product.productId).toLowerCase()
                .contains(newQuery.toLowerCase())))
            .toList();
      } else {
        filteredProductModelList = productModelList;
      }
    } else {
      filteredProductModelList = [];
    }

    productView();
    setState(() {});
    // productView(context);
  }
}
