import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:Mr_k/Models/UserModel.dart';

class UserVerificationScreen extends StatefulWidget {
  UserVerificationScreen(this.isVerifiedUsers);

  bool isVerifiedUsers = false;
  @override
  UserVerificationViewState createState() =>
      UserVerificationViewState(isVerifiedUsers);
}

class UserVerificationViewState extends State<UserVerificationScreen> {
  UserVerificationViewState(this.isVerifiedUsers);
  List<UserModel> userModelList = [];
  bool isLoading = true;

  bool isVerifiedUsers = false;

  @override
  void initState() {
    if (isVerifiedUsers) {
      getAllVerifiedUsers("");
    } else {
      getAllUser("", "");
    }
    super.initState();
  }

  Widget userView() {
    if (null != userModelList && userModelList.length > 0) {
      return ListView.builder(
        itemCount: userModelList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: new ListTile(
              title: Text(
                userModelList[index].name!,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              subtitle: Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  userModelList[index].mobileNo! +
                      "\n" +
                      userModelList[index].email!,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              trailing: isVerifiedUsers
                  ? GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            // child: GestureDetector(
                            child: Text(
                              null == userModelList[index].status ||
                                      userModelList[index].status == "3"
                                  ? "Removing"
                                  : "Remove",
                              style: TextStyle(
                                  color: null == userModelList[index].status ||
                                          userModelList[index].status == "3"
                                      ? Colors.red
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold),
                              // ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) => removeDialog(
                                    false, userModelList[index].name!, index))
                            .then((value) {
                          setState(() {});
                        });
                      },
                    )
                  : Wrap(
                      children: [
                        GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 30.0),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                // child: GestureDetector(
                                child: Text(
                                  null == userModelList[index].status ||
                                          userModelList[index].status == "2"
                                      ? "Rejecting"
                                      : "Reject",
                                  style: TextStyle(
                                      color: null ==
                                                  userModelList[index].status ||
                                              userModelList[index].status == "2"
                                          ? Colors.red
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold),
                                  // ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) => verifyDialog(
                                    false,
                                    userModelList[index].name!,
                                    index)).then((value) {
                              setState(() {});
                            });
                          },
                        ),
                        GestureDetector(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                userModelList[index].status == "1"
                                    ? "Verifying"
                                    : "Verify",
                                style: TextStyle(
                                    color: userModelList[index].status == "1"
                                        ? Colors.greenAccent
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          onTap: () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) => verifyDialog(
                                    true,
                                    userModelList[index].name!,
                                    index)).then((value) {
                              setState(() {});
                            });
                          },
                        ),
                      ],
                    ),
            ),
          );
        },
      );
    } else {
      return Visibility(
        visible: isLoading,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
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
        title: Text(
          isVerifiedUsers ? "Manage users" : "Not Verified Users",
          style: TextStyle(
              color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Center(
        child: userView(),
      ),
    );
  }

  Future getAllUser(String userName, String status) async {
    String url = ApiInterFace.BASE_URL + ApiInterFace.GET_NOT_VERIFIED_USER_API;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      isLoading = false;
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        userModelList = responseModel
            .map((userData) => new UserModel.fromJson(userData))
            .toList();
        setState(() {});
        if (null != userName && status == "1") {
          Fluttertoast.showToast(
              msg: userName + " Account Verified Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
        } else if (status == "2") {
          Fluttertoast.showToast(
              msg: userName + " Account Rejected Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        userModelList = [];
        setState(() {});
        Fluttertoast.showToast(
            msg: "No User Found",
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

  Future getAllVerifiedUsers(String userName) async {
    String url = ApiInterFace.BASE_URL + ApiInterFace.GET_VERIFIED_USER_API;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      isLoading = false;
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        userModelList = responseModel
            .map((userData) => new UserModel.fromJson(userData))
            .toList();
        setState(() {});
        if (null != userName) {
          Fluttertoast.showToast(
              msg: userName + " Account Removed Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        userModelList = [];
        setState(() {});
        Fluttertoast.showToast(
            msg: "No User Found",
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

  Widget removeDialog(bool isVerify, String name, int index) {
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
          insetPadding: EdgeInsets.all(40),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          //this right here
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 100,
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "Are You Sure To Remove " + name + " ? ",
                    style: TextStyle(),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.blueGrey),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          }),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                "Remove",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color:
                                        isVerify ? Colors.green : Colors.red),
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          userModelList[index].status = "3";

                          removeUser(userModelList[index].userId!,
                              userModelList[index].name!, index);
                          Navigator.of(context).pop();
                        }),
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

  Widget verifyDialog(bool isVerify, String name, int index) {
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
          insetPadding: EdgeInsets.all(40),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          //this right here
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 100,
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "Are You Sure To " +
                        (isVerify ? "Verify " + name : "Reject " + name),
                    style: TextStyle(),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.blueGrey),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          }),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                isVerify ? "Verify" : "Reject",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color:
                                        isVerify ? Colors.green : Colors.red),
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          if (isVerify) {
                            userModelList[index].status = "1";
                            setState(() {});
                            verifyUser(
                                userModelList[index].userId!, "1", index);
                          } else {
                            userModelList[index].status = "2";
                            setState(() {});
                            verifyUser(
                                userModelList[index].userId!, "2", index);
                          }
                          Navigator.of(context).pop();
                        }),
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

  Future removeUser(String userId, String userName, int index) async {
    String url = ApiInterFace.BASE_URL +
        ApiInterFace.REMOVE_USER_API +
        "&userId=" +
        userId;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        getAllVerifiedUsers(userName);
      } else {
        userModelList[index].status = "0";
        setState(() {});
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
      userModelList[index].status = "0";
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

  Future verifyUser(String userId, String status, int index) async {
    String url = ApiInterFace.BASE_URL +
        ApiInterFace.VERIFY_USER_API +
        "&userId=" +
        userId +
        "&status=" +
        status;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        getAllUser(userModelList[index].name!, status);
      } else {
        userModelList[index].status = "0";
        setState(() {});
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
      userModelList[index].status = "0";
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
