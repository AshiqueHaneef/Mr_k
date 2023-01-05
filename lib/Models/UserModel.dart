import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class UserModel {
  String? userId;
  String? name;
  String? mobileNo;
  String? email;
  String? password;
  String? status;
  bool? isAdmin;

  UserModel(
      {this.userId,
      this.name,
      this.email,
      this.password,
      this.status,
      this.mobileNo,
      this.isAdmin});

  static String toJson(UserModel userModel) {
    Map<String, dynamic> map() => {
          'userId': userModel.userId,
          'name': userModel.name,
          'mobileNo': userModel.mobileNo,
          'email': userModel.email,
          'password': userModel.password,
          'status': userModel.password,
          'isAdmin': userModel.password,
        };

    String result = jsonEncode(map());
    return result;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? "",
      name: json['name'] ?? "",
      mobileNo: json['mobileNo'] ?? "",
      email: json['email'] ?? "",
      password: json['password'] ?? "",
      status: json['status'] ?? "",
      isAdmin: json['isAdmin'] == "1" ? true : false,
    );
  }
}
