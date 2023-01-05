import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class OfferModel{

  String? imageName;
  String? offerId;
  String? title;

  OfferModel({this.offerId,this.imageName,this.title});

  factory OfferModel.fromJson(dynamic json){

    return new OfferModel(
      offerId: json['offerId']??"",
      imageName : json ['imageName']??"" ,
      title : json ['title']??"" ,

    );

  }
}