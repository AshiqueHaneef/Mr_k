import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:Mr_k/Models/StatusModel.dart';
import 'package:video_viewer/video_viewer.dart';

class StatusManageScreen extends StatefulWidget {
  StatusManageScreen();

  @override
  StatusManageScreenViewState createState() => StatusManageScreenViewState();
}

class StatusManageScreenViewState extends State<StatusManageScreen> {
  List<StatusModel> statusModelList = [];
  Map<String, Map<String, String>> database = {};
  late MapEntry<String, Map<String, String>> initial;
  List<Map<String, String>> videoList=[];
  final VideoViewerController controller = VideoViewerController();
  bool isLoading=false;
  @override
  void initState() {
    getAllStatus();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Manage Status",
            style: TextStyle(
                color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          leading: GestureDetector(
            child: (Icon(
              Icons.arrow_back,
              color: Colors.grey,
            )),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
      child: null!=statusModelList && statusModelList.length>0?GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: statusModelList.length,
          itemBuilder: (context, index) {
            return Card(
              child: Stack(
                children: [
                  statusModelList[index].isVideo!
                      ? Center(
                        child: Stack(
                          children: [

                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                  child:  VideoViewer(
                                    source: {
                                      "SubRip Text": VideoSource(
                                        video: VideoPlayerController.network(
                                            ApiInterFace.STATUS_URL + statusModelList[index].fileName!),

                                      )
                                    },
                                  ),
                              ),

                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.topRight,
                                  child: Icon(Icons.play_circle_fill)),
                            ),
                          ],
                        ),
                      )
                      : Center(
                          child: Container(
                            child: Image.network(ApiInterFace.STATUS_URL +
                                statusModelList[index].fileName!),
                          ),
                        ),
                  statusModelList[index].isDeleting!?Container(
                    height: 30,width: 30,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                  :IconButton(
                      icon: Icon(Icons.delete,
                      color: Colors.red,),
                      onPressed: (){
                        statusModelList[index].isDeleting=true;
                        deleteStatus(statusModelList[index]);
                        setState(() {

                        });
                      }),
                ],
              ),
            );
          }):Center(
        child: isLoading?Text("No status found"):CircularProgressIndicator(),
      ),
    ));
  }

  Future getAllStatus() async {
    setState(() {});
    String url = ApiInterFace.BASE_URL + ApiInterFace.GET_ALL_STATUS_API
    +"&date=0";

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        statusModelList = responseModel
            .map((userData) => new StatusModel.fromJson(userData))
            .toList();

        // if (null != statusModelList && statusModelList.length > 0) {
        //   for (StatusModel statusModel in statusModelList) {
        //     database={};
        //     if (statusModel.isVideo) {
        //       final Map<String, Map<String, String>> data = {
        //         statusModel.id: {
        //           statusModel.id:
        //               ApiInterFace.STATUS_URL + statusModel.fileName,
        //         },
        //       };
        //       database.addAll(data);
        //
        //       initial = database.entries.single;
        //
        //       videoList.add(initial.value);
        //     }
        //   }
        // }

        setState(() {});
      } else {
        Fluttertoast.showToast(
            msg: "No Status Found",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      setState(() {});
      Fluttertoast.showToast(
          msg: "Something went wrong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
  Future deleteStatus(StatusModel statusModel) async {
    setState(() {});
    String url = ApiInterFace.BASE_URL
        + ApiInterFace.DELETE_STATUS_API+
    "&videoFileName=" +
        statusModel.fileName! +
        "&statusId=" +
        statusModel.id!;

    final response =
    await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {

        statusModelList.removeWhere((element) => element.id==statusModel.id);

        setState(() {});
      } else {
        Fluttertoast.showToast(
            msg: "No Status Found",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      setState(() {});
      Fluttertoast.showToast(
          msg: "Something went wrong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
