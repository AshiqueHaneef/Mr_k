import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:Mr_k/Models/ProductModel.dart';
import 'package:Mr_k/Preference/Preference.dart';
import 'package:Mr_k/Ui/LoginScreen.dart';
import 'package:Mr_k/Ui/OfferAddScreen.dart';
import 'package:Mr_k/Ui/ProductListView.dart';
import 'package:Mr_k/Ui/StatusAddScreen.dart';
import 'package:Mr_k/Ui/StatusManageScreen.dart';
import 'package:Mr_k/Ui/SubCategoryScreen.dart';



import '../Models/CategoryModel.dart';
import 'CategoryScreen.dart';
import 'ProductAddScreen.dart';
import 'UploadBillScreen.dart';
import 'UserVerifyScreen.dart';

class AdminDashBoardScreen extends StatefulWidget {
  AdminDashBoardScreen();

  @override
  AdminDashBoardPageState createState() => AdminDashBoardPageState();
}

class AdminDashBoardPageState extends State<AdminDashBoardScreen> {
  AdminDashBoardPageState();
  TextEditingController productNameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController categoryNameController = new TextEditingController();

  String subcategoryName = "Select sub category";
  List<TextAlign> textAlignList = [];
  bool isLoading = false;
  bool isCategoryAddLoading = false;
  List<CategoryModel> categoryModelList = [];
  List<CategoryModel> filteredCategoryList = [];
  num width = 0;
  num height = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading:false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Stack(
          children: [
            GestureDetector(
              child: (Icon(
                Icons.arrow_back,
                color: Colors.blueGrey,
              )),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),

            Align(
              alignment: Alignment.center,
              child: Image(
                image: AssetImage('assets/icon.jpeg'),
                width: 50,
                fit: BoxFit.fill,
                height: 40,
              ),
            ),
            GestureDetector(
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.power_settings_new_outlined,
                    color: Colors.blueGrey,
                  )),
              onTap: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => logOutDialog());
              },
            ),
          ],
        ),

        // Text(
        //   "Admin Dashboard",
        //   style: TextStyle(
        //       color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        // ),
      ),
      body: SafeArea(
        child:
           SingleChildScrollView(
            child: Column
              (children: <Widget>[
              SizedBox(
                height: 25,
              ),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child:Text("Manage products",
                    //       textAlign: TextAlign.start,
                    //       style: TextStyle(
                    //           fontWeight: FontWeight.bold,
                    //         fontSize: 20
                    //       ),),
                    //
                    //
                    //   ),
                    // ),
                    Row(
                      children: [
                       Flexible(
                              child: GestureDetector(
                                child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width / 4,
                                      height: MediaQuery.of(context).size.width / 5,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Icon(Icons.add_box_outlined,
                                            color: Colors.blueGrey),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Center(
                                        child: Text(
                                          " Add Product",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.blueGrey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: width * 0.045),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) =>
                                          productCreateDialog());
                                },
                              ),
                            ),


                        Flexible(
                            child: GestureDetector(
                              child: Column(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width / 4,
                                    height: MediaQuery.of(context).size.width / 5,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Icon(Icons.upload_file,
                                          color: Colors.blueGrey),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Center(
                                      child: Text(
                                        " Update Product",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: width * 0.045),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ProductListScreen()));
                              },
                            ),
                          ),



                      ],
                    ),
                  ],
                ),
              ),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child:Text("Manage category",
                    //       textAlign: TextAlign.start,
                    //       style: TextStyle(
                    //           fontWeight: FontWeight.bold,
                    //           fontSize: 20
                    //       ),),
                    //
                    //
                    //   ),
                    // ),
                    Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: MediaQuery.of(context).size.width / 5,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(Icons.category_outlined,
                                        color: Colors.blueGrey),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      " Add Category",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * 0.045),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) => Dialog(
                                    insetPadding: EdgeInsets.all(20),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12.0)),
                                    child: categoryScreen(true, []),
                                  ));
                            },
                          ),
                        ),


                        Flexible(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: MediaQuery.of(context).size.width / 5,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(Icons.category,
                                        color: Colors.blueGrey),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      " Add Sub Category",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * 0.045),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) => Dialog(
                                    insetPadding: EdgeInsets.all(20),
                                    child: SubCategoryScreen(true, []),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12.0)),
                                  ));
                            },
                          ),
                        ),



                      ],
                    ),
                  ],
                ),
              ),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Center(
                    //     child: Text("Manage user",
                    //       style: TextStyle(
                    //           fontWeight: FontWeight.bold
                    //       ),),
                    //   ),
                    // ),
                    Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: MediaQuery.of(context).size.width / 5,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(Icons.verified_outlined,
                                        color: Colors.blueGrey),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      " Verify User",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * 0.045),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      UserVerificationScreen(false)));
                            },
                          ),
                        ),


                        Flexible(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: MediaQuery.of(context).size.width / 5,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(Icons.settings,
                                        color: Colors.blueGrey),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      " Manage users",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * 0.045),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      UserVerificationScreen(true)));
                            },
                          ),
                        ),



                      ],
                    ),
                  ],
                ),
              ),


              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text("Others",
                    //     style: TextStyle(
                    //         fontWeight: FontWeight.bold
                    //     ),),
                    //
                    // ),
                    Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: MediaQuery.of(context).size.width / 5,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(Icons.local_offer_outlined,
                                        color: Colors.blueGrey),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      " Add offers",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * 0.045),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => OfferAddScreen()));
                            },
                          ),
                        ),


                        Flexible(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: MediaQuery.of(context).size.width / 5,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(Icons.receipt_long,
                                        color: Colors.blueGrey),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      " Upload bills",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * 0.045),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => UploadBillScreen()));
                            },
                          ),
                        ),



                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: MediaQuery.of(context).size.width / 5,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(Icons.slow_motion_video_outlined,
                                        color: Colors.blueGrey),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      " Add Status",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * 0.045),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => StatusAddScreen()));
                            },
                          ),
                        ),

                        Flexible(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: MediaQuery.of(context).size.width / 5,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(Icons.video_settings_outlined,
                                        color: Colors.blueGrey),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      " Manage Status",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * 0.045),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => StatusManageScreen()));
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),

        ),
      ),
    );
  }

  Widget logOutDialog() {
    return StatefulBuilder(builder: (context, setState) {
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
                    "Are You Sure To Log Out ? ",
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
                            "Log Out ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.lightBlue),
                          ),
                        ),
                        onTap: () {
                          Preference().setUserData("");
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                              (Route<dynamic> route) => false);
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
                                "Exit App ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          onTap: () {
                            exit(1);
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
    });
  }

  Widget productCreateDialog() {
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
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
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Container(
                  width: double.infinity,
                  child: TextField(
                    maxLines: null,
                    controller: productNameController,
                    style: TextStyle(fontSize: 15.0),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      hintMaxLines: 1,
                      labelText: "Product name",
                      prefixStyle: TextStyle(fontSize: 16.0),
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  )),
            ),
            Padding(padding: EdgeInsets.only(top: 50.0)),
            Visibility(
              visible: isLoading,
              child: CircularProgressIndicator(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlue,
              ),
              child: Text(
                "Create product",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              onPressed: () {
                if (productNameController.text.isEmpty) {
                  Fluttertoast.showToast(
                      msg: "Enter valid product name",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.blueGrey,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else {
                  isLoading = true;
                  setState(() {});
                  addProduct(productNameController.text, context);
                }
              },
            ),
            Padding(padding: EdgeInsets.only(top: 50.0)),
          ],
        ),
      );
    });
  }

  Future addProduct(String productName, BuildContext context) async {
    String url = ApiInterFace.BASE_URL +
        ApiInterFace.ADD_PRODUCT_API +
        "&productName=" +
        productName;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });

      List<ProductModel> productModelList = [];
      List responseModel = json.decode(response.body);
      productModelList = responseModel
          .map((userData) =>  ProductModel.fromJson(userData))
          .toList();
      if (responseModel[0]["error"] == 0) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: "Product created successful",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        productNameController.text = "";
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProductAddScreen(productModelList[0], true)));
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
    } else {
      setState(() {
        isLoading = false;
      });

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
