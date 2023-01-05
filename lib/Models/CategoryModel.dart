

import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class CategoryModel{

  String? categoryName;
  String? categoryId;
  String? imageName;

  CategoryModel({this.categoryId,this.categoryName,this.imageName});

  factory CategoryModel.fromJson(dynamic json){

    return new CategoryModel(
      categoryId: json['categoryId']??"",
      categoryName : json ['name']??"" ,
      imageName : json ['imageName']??"" ,

    );

  }
}