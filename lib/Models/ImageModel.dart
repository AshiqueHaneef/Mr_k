import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class ImageModel{

  String? imageName;
  String? imageId;
  String? productId;
  int? deletingStatus;
  int? downloadingStatus;

  ImageModel({this.imageId,this.imageName,this.productId,this.deletingStatus});

  factory ImageModel.fromJson(dynamic json){

    return  ImageModel(
      imageId: json['imageId']!=null?json['imageId']:json['billId'],
      imageName : json ['imageName'] ??"",
      productId : json ['productId']??"" ,

    );

  }
}