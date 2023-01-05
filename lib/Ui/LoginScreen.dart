import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:Mr_k/Models/CategoryModel.dart';
import 'package:Mr_k/Models/SubCategoryModel.dart';
import 'package:Mr_k/Models/UserModel.dart';
import 'package:Mr_k/Preference/Preference.dart';
import 'package:Mr_k/Ui/AdminDashBoardScreen.dart';
import 'package:Mr_k/Ui/RegistrationScreen.dart';
import 'package:Mr_k/Ui/User/HomeScreen.dart';




class LoginScreen extends StatefulWidget {
  LoginScreen();

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  LoginScreenState();
  TextEditingController mobileNoController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  bool isMobileNoError = false;
  bool isPasswordError = false;
  bool isLoading = false;
  List<UserModel> userModelList=[];
  bool isPasswordVisible=false;

  @override
  void initState() {

      Preference().getUserData().then((value) {
        userModelList = value;
        if (null != userModelList && userModelList.length > 0) {
          // mobileNoController.text=userModelList[0].mobileNo;
          if(null!=userModelList[0].status && userModelList[0].status=="1") {
            if (userModelList[0].isAdmin!) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => AdminDashBoardScreen()),
                      (Route<dynamic> route) => false);
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomeScreen(userModelList[0])),
                      (Route<dynamic> route) => false);
            }
          }
        }
      });



    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Center(
            child:null == userModelList ||  userModelList.length<=0 ||
                null==userModelList[0].status || userModelList[0].status !="1"? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Login",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 50, right: 50),
                    child: Container(
                        width: double.infinity,
                        child: TextField(
                          controller: mobileNoController,
                          style: TextStyle(fontSize: 15.0),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            errorText: isMobileNoError
                                ? "Enter valid mobile number"
                                : null,
                            hintMaxLines: 1,
                            labelText: "Mobile number",
                            prefixStyle: TextStyle(fontSize: 16.0),
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 50, right: 50),
                    child: Container(
                        width: double.infinity,
                        child: TextField(
                          obscureText: !isPasswordVisible,
                          controller: passwordController,
                          style: TextStyle(fontSize: 15.0),
                          decoration: InputDecoration(
                            contentPadding:
                            EdgeInsets.fromLTRB(10, 10, 10, 0),
                            errorText: isPasswordError
                                ? "Enter valid password"
                                : null,
                            hintMaxLines: 1,
                            labelText: "Password",
                            prefixStyle: TextStyle(fontSize: 16.0),
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                (isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: isLoading,
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 50, right: 50),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.lightBlue
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        onPressed: () {
                          if (mobileNoController.text.isEmpty) {
                            setState(() {
                              isMobileNoError = true;
                            });
                          } else {
                            setState(() {
                              isMobileNoError = false;
                            });
                          }
                          if (passwordController.text.isEmpty) {
                            setState(() {
                              isPasswordError = true;
                            });
                          } else {
                            setState(() {
                              isPasswordError = false;
                            });
                          }
                          if (!isMobileNoError && !isPasswordError) {
                            isLoading = true;
                            // Navigator.of(context).push(MaterialPageRoute(
                            //     builder: (BuildContext context) =>
                            //         AdminDashBoardScreen()));
                            validateUser(passwordController.text,
                                mobileNoController.text, context);
                          } else {
                            isLoading = false;
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 50, right: 50),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlue,
                          ),
                          child: Text(
                            "Create new account",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    RegistrationPage(true)));
                          }),
                    ),
                  ),
                ]):Center(child: CircularProgressIndicator(),)
          ),
        ));
  }

  Future validateUser(
      String password, String mobileNo, BuildContext context) async {
    String url = ApiInterFace.BASE_URL +
        ApiInterFace.LOGIN_API +
        "&mobileNo=" +
        mobileNo +
        "&password=" +
        password;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      isLoading = false;
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        List<UserModel> userModelList = responseModel
            .map((spacecraft) => new UserModel.fromJson(spacecraft))
            .toList();
        Preference().setUserData(response.body);
        if (null != userModelList && userModelList.length > 0) {
          if (userModelList[0].status=="1") {
            Fluttertoast.showToast(
                msg: "Login successful",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.blueGrey,
                textColor: Colors.white,
                fontSize: 16.0);
            // if (userModelList[0].isAdmin) {
            //
            //   Navigator.of(context).pushAndRemoveUntil(
            //       MaterialPageRoute(
            //           builder: (context) => AdminDashBoardScreen()),
            //           (Route<dynamic> route) => false);
            // } else {

              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomeScreen(userModelList[0])),
                      (Route<dynamic> route) => false);
            // }
            getAllCategories();
            getAllSubCategories();

          } else {
            Fluttertoast.showToast(
                msg: "Admin not verified your account",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.blueGrey,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        } else {
          Fluttertoast.showToast(
              msg: "Invalid username or password",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        Fluttertoast.showToast(
            msg: "Invalid username or password",
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

  Future getAllSubCategories() async {
    String url = ApiInterFace.BASE_URL + ApiInterFace.GET_ALL_SUB_CATEGORY_API;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        List<SubCategoryModel> subCategoryModelList = [];
        subCategoryModelList = responseModel
            .map((userData) => new SubCategoryModel.fromJson(userData))
            .toList();

        Preference().setSubCategoryList(response.body);

      }

    }
  }

  Future getAllCategories() async {
    String url = ApiInterFace.BASE_URL + ApiInterFace.GET_ALL_CATEGORY_API;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      String sss = response.body;
      List responseModel = json.decode(response.body);

      List<CategoryModel> categoryModelList = [];
      if (responseModel[0]["error"] == 0) {
        categoryModelList = responseModel
            .map((userData) =>  CategoryModel.fromJson(userData))
            .toList();

        Preference().setCategoryList(response.body);


      }
    }
  }
}
