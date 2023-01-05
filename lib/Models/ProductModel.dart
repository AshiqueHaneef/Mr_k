import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:Mr_k/Models/ImageModel.dart';

@JsonSerializable()
class ProductModel {
  String productId;
  String productName;
  String description;
  String categoryId, subCategoryId, iconImageName;
  String? iconImageId;

  List<ImageModel>? imageList = [];

  ProductModel(
      {required this.productId,
      this.imageList,
      required this.description,
      required this.categoryId,
      required this.subCategoryId,
      required this.productName,
      required this.iconImageName});

  factory ProductModel.fromJson(dynamic json) {
    return  ProductModel(
      productId: json['productId'],
      productName: json['productName'],
      description: json['description'],
      categoryId: json['categoryId'],
      subCategoryId: json['subCategoryId'],
      iconImageName: json['iconImageName'],
    );
  }
  static String toJson(ProductModel productModel) {
    Map<String, dynamic> map() => {
          'productId': productModel.productId,
          'productName': productModel.productName,
          'description': productModel.description,
          'categoryId': productModel.categoryId,
          'subCategoryId': productModel.subCategoryId,
          'iconImageName': productModel.iconImageName,
        };

    String result = jsonEncode(map());
    return result;
  }

  static Map<String, dynamic> preferenceToJson(ProductModel productModel) => {
        'productId': productModel.productId,
        'productName': productModel.productName,
        'description': productModel.description,
        'categoryId': productModel.categoryId,
        'subCategoryId': productModel.subCategoryId,
        'iconImageName': productModel.iconImageName,
      };
  static String encode(List<ProductModel> productModelList) => json.encode(
        productModelList
            .map<Map<String, dynamic>>(
                (data) => ProductModel.preferenceToJson(data))
            .toList(),
      );

  static List<ProductModel> decode(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<ProductModel>((item) => ProductModel.fromJson(item))
          .toList();
}
