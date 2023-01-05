

import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class SubCategoryModel{

  String? subCategoryName;
  String? categoryId,subCategoryId;

  SubCategoryModel({this.categoryId,this.subCategoryId,this.subCategoryName});

  factory SubCategoryModel.fromJson(dynamic json){

    return  SubCategoryModel(
      subCategoryId: json['subCategoryId']??"",
      subCategoryName : json ['subCategoryName']??"" ,
      categoryId : json ['categoryId']??"" ,

    );

  }
}