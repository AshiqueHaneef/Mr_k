import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class StatusModel{

  String? id;
  String? fileName;
  String? endDate;
  String? productId;
  bool? isVideo;
  String? createdDate;
  String? duration;
  bool? isDeleting=false;

  StatusModel({this.id,this.fileName,this.endDate,this.productId,this.isVideo,this.createdDate,this.isDeleting,this.duration});

  factory StatusModel.fromJson(dynamic json){

    return  StatusModel(
      id: json['id']??"",
      fileName : json ['fileName']??"" ,
      endDate : json ['endDate']??"" ,
      productId : json ['productId']??"" ,
      isVideo : json ['isVideo']== "1"?true:false,
      createdDate : json ['createdDate']??"" ,
      isDeleting : false,
      duration : json ['duration'] ??"",



    );

  }
}