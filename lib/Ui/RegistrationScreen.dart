import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:Mr_k/Models/UserModel.dart';
import 'package:Mr_k/Ui/LoginScreen.dart';


class RegistrationPage extends StatefulWidget {
  RegistrationPage(this.isUser);
  bool isUser = false;

  @override
  RegistrationPageState createState() => RegistrationPageState(isUser);
}

class RegistrationPageState extends State<RegistrationPage> {
  RegistrationPageState(this.isUser);
  bool isUser = false;

  TextEditingController nameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController mobileController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();
  bool isNameError = false;
  bool isEmailError = false;
  bool isMobileError = false;
  bool isConfirmPasswordError = false;
  bool isPasswordError = false;
  bool isLoading = false;
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
            Widget>[
          SizedBox(
            height: 100,
          ),
          Text(
            "User Registration",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.only(left: 50, right: 50),
            child: Container(
                width: double.infinity,
                child: TextField(
                  controller: nameController,
                  style: TextStyle(fontSize: 15.0),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    errorText: isNameError ? "Enter valid name" : null,
                    hintMaxLines: 1,
                    labelText: "Name",
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
                  controller: emailController,
                  style: TextStyle(fontSize: 15.0),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    errorText: isNameError ? "Enter valid email" : null,
                    hintMaxLines: 1,
                    labelText: "Email",
                    prefixStyle: TextStyle(fontSize: 16.0),
                    prefixIcon: Icon(Icons.email),
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
                  keyboardType: TextInputType.number,
                  controller: mobileController,
                  style: TextStyle(fontSize: 15.0),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    errorText:
                        isPasswordError ? "Enter valid mobile number" : null,
                    hintMaxLines: 1,
                    labelText: "Mobile no",
                    prefixStyle: TextStyle(fontSize: 16.0),
                    prefixIcon: Icon(Icons.phone),
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
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    errorText: isPasswordError ? "Enter valid password" : null,
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
          Padding(
            padding: EdgeInsets.only(left: 50, right: 50),
            child: Container(
                width: double.infinity,
                child: TextField(
                  obscureText: !isPasswordVisible,
                  controller: confirmPasswordController,
                  style: TextStyle(fontSize: 15.0),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    errorText: isConfirmPasswordError
                        ? "Enter valid confirm password"
                        : null,
                    hintMaxLines: 1,
                    labelText: "Confirm password",
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
            height: 10,
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
                  primary: Colors.lightBlue,
                ),
                child: Text(
                  "Sign up",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                onPressed: () {
                  if (nameController.text.isEmpty) {
                    setState(() {
                      isNameError = true;
                    });
                  } else {
                    setState(() {
                      isNameError = false;
                    });
                  }
                  if (emailController.text.isEmpty) {
                    setState(() {
                      isEmailError = true;
                    });
                  } else {
                    setState(() {
                      isEmailError = false;
                    });
                  }

                  if (mobileController.text.isEmpty) {
                    setState(() {
                      isMobileError = true;
                    });
                  } else {
                    setState(() {
                      isMobileError = false;
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
                  if (confirmPasswordController.text.isEmpty) {
                    setState(() {
                      isConfirmPasswordError = true;
                    });
                  } else {
                    setState(() {
                      isConfirmPasswordError = false;
                    });
                  }

                  if (!isNameError &&
                      !isEmailError &&
                      !isMobileError &&
                      !isPasswordError &&
                      !isConfirmPasswordError) {
                    if (passwordController.text !=
                        confirmPasswordController.text) {
                      Fluttertoast.showToast(
                          msg: "Password and confirm password are different",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.blueGrey,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    } else {
                      isLoading = true;
                      createUser(nameController.text, passwordController.text,
                          mobileController.text, emailController.text, context);
                    }
                  } else {
                    isLoading = false;
                  }
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Future createUser(String name, String password, String mobileNo, String email,
      BuildContext context) async {
    String url = ApiInterFace.BASE_URL + ApiInterFace.REGISTRATION_API;
    UserModel userModel = new UserModel();
    userModel.name = name;
    userModel.password = password;
    userModel.mobileNo = mobileNo;
    userModel.email = email;
    String userJson = UserModel.toJson(userModel);

    final response = await http.post(Uri.parse(url),
        headers: ApiInterFace.headers, body: userJson);

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });

      List responseModel = json.decode(response.body);
      if (responseModel[0]["error"] == 0) {
        Fluttertoast.showToast(
            msg: "Your data send for verification",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false);
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
