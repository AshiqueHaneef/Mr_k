


import 'package:json_annotation/json_annotation.dart';
import 'package:Mr_k/Models/SubCategoryModel.dart';

import 'CategoryModel.dart';
import 'CategoryModel.dart';

@JsonSerializable()
class SelectedCategoryModel{

  CategoryModel? categoryModel;
  SubCategoryModel? subCategoryModel;

  SelectedCategoryModel({this.categoryModel,this.subCategoryModel});

}