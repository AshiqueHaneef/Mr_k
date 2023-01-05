import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:Mr_k/Utils/DisplaySize.dart';

import '../../Models/CategoryModel.dart';
import 'UserProductListScreen.dart';


// ignore: must_be_immutable
class UserCategoryScreen extends StatefulWidget {
  UserCategoryScreen(this.categoryModelList);
  bool isFromMenuScreen = false;
  List<CategoryModel> categoryModelList = [];

  @override
  UserCategoryViewState createState() =>
      UserCategoryViewState(categoryModelList);
}

class UserCategoryViewState extends State<UserCategoryScreen> {
  UserCategoryViewState(this.categoryModelList);

  List<CategoryModel> categoryModelList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,

          title: Text(
            "Select Category",
            style: TextStyle(
                color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          leading: GestureDetector(
            child: (Icon(
              Icons.arrow_back,
              color: Colors.blueGrey,
            )),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.all(15.0),
                child: ListView.builder(

                    shrinkWrap: true,
                    itemCount: categoryModelList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Container(
                          height:200 ,
                          child: Stack(
                              children: [

                                imageView(categoryModelList[index], context),
                                ClipRRect( // Clip it cleanly.
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX:0.5, sigmaY: 0.5),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(categoryModelList[index].categoryName!,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,

                                      ),),
                                    ),
                                  ),
                                ),
                              ],

                          )
                          ,
                        ),
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => UserProductListScreen(categoryModelList[index],false)));
                        },
                      );
                    }),
            ),
        ),
    );
  }
  Widget imageView(CategoryModel categoryModel,BuildContext context){
    if(null!=categoryModel.imageName &&
        categoryModel.imageName!.isNotEmpty){
      return  Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: displayWidth(context)*0.7,width: displayWidth(context),
          decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover, image: NetworkImage(
                ApiInterFace.CATEGORY_IMAGE_URL +
                    categoryModel.imageName!)),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Colors.redAccent,
          ),
        ),
      );

      //   Image.network( ApiInterFace.CATEGORY_IMAGE_URL +
      //     categoryModel.imageName,width: displayWidth(context),
      //   fit: BoxFit.contain,
      // height: 200,);
    }else {
      return  Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: displayWidth(context)*0.7,width: displayWidth(context),
          decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover, image:  AssetImage('assets/noimage.png')),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Colors.redAccent,
          ),
        ),
      );

        //
        // Image(image: AssetImage('assets/noimage.png'),
        // width: displayWidth(context),
        //   fit: BoxFit.cover,
        // height: 200);
    }
  }
}
