

import 'dart:convert';


import 'package:Mr_k/Models/CategoryModel.dart';
import 'package:Mr_k/Models/ProductModel.dart';
import 'package:Mr_k/Models/SubCategoryModel.dart';
import 'package:Mr_k/Models/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preference {


  setUserData(String userJson) async {
    SharedPreferences prefs=await SharedPreferences.getInstance();

    prefs.setString('userJson', userJson);
  }
  Future getUserData() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? jsonSting=prefs.getString('userJson');
    List<UserModel> userModelList=[];

    if(null!=jsonSting && jsonSting.isNotEmpty) {
      List responseModel = json.decode(jsonSting);
      userModelList = responseModel
          .map((spacecraft) => new UserModel.fromJson(spacecraft))
          .toList();
    }

    return userModelList;
  }

  setSubCategoryList(String categoryJson) async {
    SharedPreferences prefs=await SharedPreferences.getInstance();

    prefs.setString('subCategoryList', categoryJson);
  }
  Future getSubCategoryList() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? jsonSting=prefs.getString('subCategoryList');
    List responseModel = json.decode(jsonSting!);
    List<SubCategoryModel> subCategoryModelList = [];
    if (responseModel[0]["error"] == 0) {

      subCategoryModelList = responseModel
          .map((userData) => new SubCategoryModel.fromJson(userData))
          .toList();
    }

    return subCategoryModelList;
  }
  setCategoryList(String categoryJson) async {
    SharedPreferences prefs=await SharedPreferences.getInstance();

    prefs.setString('categoryList', categoryJson);
  }
  Future getCategoryList() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? jsonSting=prefs.getString('categoryList');

    List<CategoryModel> categoryModelList = [];

    if(null!=jsonSting && jsonSting.isNotEmpty) {
      List responseModel = json.decode(jsonSting);
      if (responseModel[0]["error"] == 0) {
        categoryModelList = responseModel
            .map((userData) =>  CategoryModel.fromJson(userData))
            .toList();
      }
    }

    return categoryModelList;
  }
  setFavoriteList(String favoriteProductListJson) async {
    SharedPreferences prefs=await SharedPreferences.getInstance();

    prefs.setString('favoriteProductListJson', favoriteProductListJson);
  }
  Future getFavoriteList() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? jsonSting=prefs.getString('favoriteProductListJson');

    List<ProductModel> favoriteProductList = [];

    if(null!=jsonSting && jsonSting.isNotEmpty) {
      List responseModel = json.decode(jsonSting);
      favoriteProductList = responseModel
          .map((productModel) =>  ProductModel.fromJson(productModel))
          .toList();
    }

    return favoriteProductList;
  }

  // setAllFavorite(String favoriteIdsJson) async {
  //   SharedPreferences prefs=await SharedPreferences.getInstance();
  //
  //   prefs.setString('favoriteIdsJson', favoriteIdsJson);
  // }
  // Future getAllFavoriteIds() async{
  //   SharedPreferences prefs=await SharedPreferences.getInstance();
  //   String jsonSting=prefs.getString('favoriteIdsJson');
  //
  //   List<String> favoriteIdList=[];
  //   if(null!=jsonSting && jsonSting.isNotEmpty) {
  //     var favoriteIdsJson = jsonDecode(jsonSting);
  //     favoriteIdList = favoriteIdsJson != null ? List.from(favoriteIdsJson) : null;
  //   }
  //
  //   return favoriteIdList;
  // }
}