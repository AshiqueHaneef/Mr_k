import 'dart:io';

import 'package:dio/dio.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';

import 'package:external_path/external_path.dart';
import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart' as p;

import '../../Models/ImageModel.dart';

class ImageScreen extends StatefulWidget {
  ImageScreen(this.imageModelList, this.isBill, this.name, this.productId,
      {super.key});
  List<ImageModel> imageModelList;
  String name, productId;
  bool isBill;

  @override
  ImagePageState createState() => ImagePageState(
        imageModelList,
        isBill,
        name,
        productId,
      );
}

class ImagePageState extends State<ImageScreen> {
  ImagePageState(this.imageModelList, this.isBill, this.name, this.productId);
  List<ImageModel> imageModelList;
  String name, productId;
  bool isBill;
  Dio dio = Dio();
  Directory? destinationDirectory;

  @override
  void initState() {
    getDirectoryPath();
    super.initState();
  }

  @override
  void dispose() {
    imageModelList = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            child: (const Icon(
              Icons.arrow_back,
              color: Colors.blueGrey,
            )),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(
          child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      childAspectRatio: 1),
                  itemCount: imageModelList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: InteractiveViewer(
                              panEnabled: true, // Set it to false
                              boundaryMargin: const EdgeInsets.all(0),

                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                        isBill
                                            ? ApiInterFace.BILL_IMAGE_URL +
                                                imageModelList[index].imageName!
                                            : ApiInterFace.PRODUCT_IMAGE_URL +
                                                imageModelList[index].imageName!,
                                      )),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0)),
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                          Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  child: const CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.white,
                                    child: Center(
                                      child: Icon(
                                        Icons.share,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    imageModelList[index].deletingStatus = 1;
                                    setState(() {});
                                    if (kIsWeb) {
                                      _launchInBrowser(
                                          "https://wa.me/971557117184?text=" +
                                              name +
                                              " " +
                                              productId);
                                    } else {
                                      _requestPermission().then((value) {
                                        downloadImages(
                                            imageModelList[index], index, true);
                                      });
                                    }
                                  },
                                ),
                              )),
                          Visibility(
                            visible: !kIsWeb,
                            child: Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 50, bottom: 8.0, left: 8, right: 8),
                                  child: GestureDetector(
                                    child: const CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.white,
                                      child: Center(
                                        child: Icon(
                                          Icons.download_outlined,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      imageModelList[index].downloadingStatus =
                                          1;
                                      setState(() {});
                                      if (kIsWeb) {
                                      } else {
                                        _requestPermission().then((value) {
                                          downloadImages(imageModelList[index],
                                              index, false);
                                        });
                                      }
                                    },
                                  ),
                                )),
                          ),
                          Visibility(
                            visible:
                                null != imageModelList[index].deletingStatus &&
                                    imageModelList[index].deletingStatus == 1 &&
                                    !kIsWeb,
                            child: const Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: CircularProgressIndicator(),
                                )),
                          ),
                          Visibility(
                            visible: null !=
                                    imageModelList[index].downloadingStatus &&
                                imageModelList[index].downloadingStatus == 1,
                            child: const Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 47, bottom: 0, left: 8, right: 5),
                                  child: CircularProgressIndicator(),
                                )),
                          )
                        ],
                      ),
                    );
                  })),
        ));
  }

  getDirectoryPath() async {
    if (Platform.isIOS) {
      await getLibraryDirectory().then((value) {
        destinationDirectory = value;
        setState(() {});
      });
    } else {
      String path = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);

      Directory directory = Directory(path);
      destinationDirectory = directory;
      setState(() {});
      // await getApplicationDocumentsDirectory().then((value) {
      //   destinationDirectory = value;
      //   setState(() {});
      // });
    }
  }

  downloadImages(ImageModel imageModel, int index, bool isShare) async {
    String progress = "";

    // String path=await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
    String path = destinationDirectory!.path;
    path = path + "/" + imageModel.imageName!;
    String url;
    if (isBill) {
      url = ApiInterFace.BILL_IMAGE_URL + imageModel.imageName!;
    } else {
      url = ApiInterFace.PRODUCT_IMAGE_URL + imageModel.imageName!;
    }
    await dio.download(url, path, onReceiveProgress: (rec, total) {
      progress = ((rec / total) * 100).toStringAsFixed(0) + "%";
      print(progress.toString());
      if (progress == "100%") {
        if (isShare) {
          imageModelList[index].deletingStatus = 0;

          shareImages(context, path);
        } else {
          if (Platform.isIOS) {
            shareImages(context, path);
          }
          imageModelList[index].downloadingStatus = 0;
        }
        setState(() {});
        Fluttertoast.showToast(
            msg: "Download successful",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
    // var file ;
    // await DefaultCacheManager().getSingleFile(ApiInterFace.PRODUCT_IMAGE_URL + imageModel.imageName).then((value) {
    //   file=value;
    // });

    // String result = await FolderFileSaver.saveImage(pathImage: pathImage);
    // var imageId = await ImageDownloader.downloadImage(
    //   ApiInterFace.PRODUCT_IMAGE_URL + imageModel.imageName,
    //   destination: AndroidDestinationType.custom(directory: '/storage/emulated/0/DCIM/',inPublicDir: true)
    //     ..subDirectory(imageModel.imageName),
    // );
    // File file=new File("/storage/emulated/0/DCIM/");
    // var path = await ImageDownloader.findPath(imageId);
    // imageModelList[index].deletingStatus = 0;
    // setState(() {
    //
    // });
    // shareImages(context, path);
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {}
  }

  Future<bool> _requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      if (statuses[0] == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  shareImages(BuildContext context, String imagePath) async {
    final RenderBox box = context.findRenderObject() as RenderBox;

    List<String> paths = [];
    paths.add(imagePath);
    await Share.shareFiles(paths,
        text: name,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}
