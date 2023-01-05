import 'dart:convert';
import 'dart:io';

import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:Mr_k/Models/CategoryModel.dart';
import 'package:Mr_k/Models/ImageModel.dart';
import 'package:Mr_k/Models/OfferModel.dart';
import 'package:Mr_k/Models/ProductModel.dart';
import 'package:Mr_k/Models/StatusModel.dart';
import 'package:Mr_k/Models/UserModel.dart';
import 'package:Mr_k/Preference/Preference.dart';
import 'package:Mr_k/Ui/User/UserCategoryView.dart';
import 'package:Mr_k/Ui/User/UserProductView.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;


import 'package:url_launcher/url_launcher.dart';

import '../../Utils/DisplaySize.dart';
import '../AdminDashBoardScreen.dart';
import '../LoginScreen.dart';
import 'ImageScreen.dart';
import 'StatusViewScreen.dart';
import 'UserProductListScreen.dart';

class HomeScreen extends StatefulWidget {
  UserModel userModel = new UserModel();
  HomeScreen(this.userModel);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<ImageModel> billList = [];
  List<CategoryModel> categoryModelList = [];
  List<ProductModel> arrivalProductList = [];
  List<ProductModel> favoriteProductList = [];

  List<OfferModel> offerModelList = [];
  static const MethodChannel _channel = const MethodChannel('flutter_launch');
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;
  List<StatusModel> statusModelList = [];
  int totalStatusCount = -1;
  bool isStatusError = false;
  String currentDateInString = "";
  bool isLoading = true;
  @override
  void initState() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    initFireBase();

    FirebaseMessaging.instance.subscribeToTopic("mrk");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,

                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
                channelDescription: channel.description,
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Navigator.pushNamed(context, '/message',
      //     arguments: MessageArguments(message, true));
    });
    var formatter = new DateFormat('yyyy-MM-dd hh:mm:ss');
    currentDateInString = formatter.format(DateTime.now());

    getAllStatus(currentDateInString);
    getAllBills();
    Preference().getCategoryList().then((value) {
      categoryModelList = value;
      setState(() {});
    });
    // Preference().getFavoriteList().then((value) {
    //   favoriteProductList=value;
    //
    //   setState(() {
    //
    //   });
    // });
    getNewArrivals();
    getAllCategories();
    getOffers();
    super.initState();
  }

  void initFireBase() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        description:
            'This channel is used for important notifications.', // description
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
        // TODO: handle the received notifications
      } else {
        print('User declined or has not accepted permission');
      }

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Stack(
            children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: isStatusError
                      ? GestureDetector(
                          child: Row(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                child: const Icon(Icons.autorenew_outlined,
                                    color: Colors.red),
                              ),
                              const Text(
                                "Retry",
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 10),
                              ),
                            ],
                          ),
                          onTap: () {
                            totalStatusCount = -1;
                            isStatusError = false;
                            getAllStatus(currentDateInString);
                            setState(() {});
                          },
                        )
                      : totalStatusCount == statusModelList.length
                          ? GestureDetector(
                              child: Row(
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Icon(
                                      Icons.slow_motion_video_rounded,
                                      color: null != statusModelList &&
                                              statusModelList.length > 0
                                          ? Colors.red
                                          : Colors.blueGrey,
                                    ),
                                  ),
                                  const Text(
                                    "Now added",
                                    style: TextStyle(
                                        color: Colors.blueGrey, fontSize: 10),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        StatusViewScreen(statusModelList)));
                              },
                            )
                          : isLoading
                              ? Row(
                                  children: [
                                    Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child: Container(
                                            height: 25,
                                            width: 25,
                                            child:
                                                const CircularProgressIndicator())),
                                    const Text(
                                      "Loading status",
                                      style: TextStyle(
                                          color: Colors.blueGrey, fontSize: 10),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    const Text(
                                      "No status",
                                      style: TextStyle(
                                          color: Colors.blueGrey, fontSize: 10),
                                    ),
                                    Card(
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child:
                                            Container(height: 25, width: 25)),
                                  ],
                                )),
              const Align(
                alignment: Alignment.center,
                child: Image(
                  image: AssetImage('assets/icon.jpeg'),
                  width: 50,
                  fit: BoxFit.fill,
                  height: 40,
                ),
              ),
              GestureDetector(
                child: const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.power_settings_new_outlined,
                      color: Colors.blueGrey,
                    )),
                onTap: () {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) => logOutDialog());
                },
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Visibility(
              visible: widget.userModel.isAdmin!,
              child: GestureDetector(
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.add,
                      color: Colors.black,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AdminDashBoardScreen()));
                },
              ),
            ),
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: CircleAvatar(
                  backgroundColor: Colors.red[50],
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                ),
              ),
              onTap: () {
                CategoryModel categoryModel = new CategoryModel();
                categoryModel.categoryId = "0";
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        UserProductListScreen(categoryModel, true)));
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                onPressed: () {},
                child: IconButton(
                  icon: const Icon(MdiIcons.whatsapp),
                  onPressed: () {
                    _launchInBrowser("https://wa.me/971557117184");
                    // FlutterOpenWhatsapp.sendSingleMessage("971557117184", "");
                  },
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.only(right: 10, top: 5),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        "More",
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            UserCategoryScreen(categoryModelList)));
                  },
                ),
                Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                        height: displayHeight(context) * 0.18,
                        child: categoryView())),

                Visibility(
                    visible:
                        null != offerModelList && offerModelList.length > 0,
                    child: Container(
                        height: displayHeight(context) * 0.25,
                        child: offerView())),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Text(
                          "New Arrivals ",
                          style: TextStyle(
                              color: Colors.green[400],
                              fontWeight: FontWeight.bold),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.new_releases,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                        height: displayHeight(context) * 0.26,
                        child: arrivalProductView())),

                // Visibility(
                //   visible: favoriteProductList.length>0,
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Align(
                //       alignment: Alignment.topLeft,
                //       child: Row(
                //         children: [
                //           Text(
                //             "Favorites",
                //             style: TextStyle(
                //                 color: Colors.red[300], fontWeight: FontWeight.bold),
                //           ),
                //           Padding(
                //             padding: const EdgeInsets.only(right: 10),
                //             child: Icon(Icons.favorite,
                //               color: Colors.red[400],
                //               size: 20,),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Visibility(
                //   visible: favoriteProductList.length>0,
                //   child: Card(
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(10),
                //       ),
                //       child: Container(
                //           height: displayHeight(context) *0.25,
                //           child: Align(
                //             alignment: Alignment.centerLeft,
                //               child: favouriteProductView()))),
                // ),

                Visibility(
                  visible: null != billList && billList.length > 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Recent Purchases",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.receipt_long,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            child: const Padding(
                              padding: EdgeInsets.only(right: 10, top: 5),
                              child: Text(
                                "More",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                            ),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) =>
                                      ImageScreen(billList, true, "Bill", ""));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: null != billList && billList.length > 0,
                  child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: billView())),
                ),
              ],
            ),
          ),
        ));
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

  Future<void> sendPushMessage(String _token) async {
    setState(() {});
    String url =
        ApiInterFace.BASE_URL + ApiInterFace.SEND_PUSH_NOTIFICATION_API;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        offerModelList =
            responseModel.map((json) => new OfferModel.fromJson(json)).toList();

        setState(() {});
      }
    }
    // Message message = Message.builder()
    //     .putData("score", "850")
    //     .putData("time", "2:45")
    //     .setToken(registrationToken)
    //     .build();
    // FirebaseMessaging.instance.sendMessage()
    // if (_token == null) {
    //   print('Unable to send FCM message, no token exists.');
    //   return;
    // }
    // // "AAAAKO62hzg:APA91bFgTfvdYurxMu-ha_sCo-WbtxL8RGjYhc_4As-yciE1w7My3cTlLOfwVGo6KuiYL_nOUA-vMiV7yEWvy0tSDcwClEx5uiM2_SOKBjygYM8uz3K9WPM9l4FQ-qOXV9XGkpcLDnRq
    // try {
    //   https://fcm.googleapis.com/v1/{parent=projects/mrk-trader}/messages:send
    // final response=await http.post(
    //     Uri.parse('https://fcm.googleapis.com/fcm/send/'),
    //     headers: <String, String>{
    //       'Content-Type': 'application/json',
    //       'Authorization': 'key=AAAAKO62hzg:APA91bFgTfvdYurxMu-ha_sCo-WbtxL8RGjYhc_4As-yciE1w7My3cTlLOfwVGo6KuiYL_nOUA-vMiV7yEWvy0tSDcwClEx5uiM2_SOKBjygYM8uz3K9WPM9l4FQ-qOXV9XGkpcLDnRq'
    //
    //     },
    //     body: constructFCMPayload(_token),
    //   );
    //
    // String body=response.body.toString();
    // if (response.statusCode == 200) {
    //
    // }
    //   print('FCM request for device sent!');
    // } catch (e) {
    //   print(e);
    // }
  }

  String constructFCMPayload(String token) {
    return jsonEncode({
      "message": {
        "token": token,
        "notification": {
          "body": "This is an FCM notification message!",
          "title": "FCM Message"
        }
      }
    });
  }
  // void whatsAppOpen() async {
  //   // bool whatsapp = await hasApp(name: "whatsapp").then((value) ())
  //
  //     await launchWathsApp(phone: "7012006458", message: "Hello, flutter_launch");
  //
  // }
  // static Future<Null> launchWathsApp(
  //     {@required String phone, @required String message}) async {
  //   final Map<String, dynamic> params = <String, dynamic>{
  //     'phone': phone,
  //     'message': "message"
  //   };
  //   await _channel.invokeMethod('launchWathsApp', params);
  // }
  //
  // static Future<bool> hasApp({@required String name}) async {
  //   final Map<String, dynamic> params = <String, dynamic>{
  //     'name': name,
  //   };
  //   return await _channel.invokeMethod('hasApp', params);
  // }

  Widget categoryView() {
    if (null != categoryModelList && categoryModelList.length > 0) {
      return Center(
        child: ListView.builder(
          shrinkWrap: true,

          scrollDirection: Axis.horizontal,
          // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //   crossAxisCount: 4,
          //   childAspectRatio: 1,
          // ),
          itemCount: categoryModelList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      CircleAvatar(
                        radius: displayHeight(context) * 0.04,
                        backgroundImage:
                            categoryModelList[index].imageName!.isNotEmpty
                                ? NetworkImage(ApiInterFace.CATEGORY_IMAGE_URL +
                                    categoryModelList[index].imageName!)
                                : const AssetImage("assets/noimage.png")
                                    as ImageProvider,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          categoryModelList[index].categoryName!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UserProductListScreen(
                          categoryModelList[index], false)));
                });
          },
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget offerView() {
    if (null != offerModelList && offerModelList.length > 0) {
      return CarouselSlider(
        options: CarouselOptions(height: 400.0),
        items: offerModelList.map((offerModel) {
          return Builder(
            builder: (BuildContext context) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Container(
                        height: displayHeight(context),
                        width: displayHeight(context),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(ApiInterFace.OFFER_IMAGE_URL +
                                  offerModel.imageName!)),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8.0)),
                          color: Colors.redAccent,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Text(
                              offerModel.title!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget favouriteProductView() {
    if (null != favoriteProductList && favoriteProductList.length > 0) {
      return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: favoriteProductList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
              child: Container(
                width: 160,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: displayHeight(context) * 0.02,
                          right: displayHeight(context) * 0.02,
                          top: displayHeight(context) * 0.01),
                      child: CachedNetworkImage(
                        imageUrl: ApiInterFace.PRODUCT_IMAGE_URL +
                            favoriteProductList[index].iconImageName,
                        // height: displayHeight(context) *0.2,
                        // width: displayHeight(context) *0.2,
                        httpHeaders: ApiInterFace.headers,
                        imageBuilder: (context, imageProvider) => Container(
                          height: displayHeight(context) * 0.18,
                          width: displayHeight(context) * 0.18,
                          decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.blueGrey,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => Container(
                          height: displayHeight(context) * 0.18,
                          width: displayHeight(context) * 0.18,
                          child: const Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.blueGrey,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image,
                          size: 90,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        favoriteProductList[index].productName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: displayHeight(context) * 0.022,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) =>
                            UserProductViewScreen(favoriteProductList[index])))
                    .then((value) {
                  Preference().getFavoriteList().then((value) {
                    favoriteProductList = value;

                    setState(() {});
                  });
                });
              });
        },
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget arrivalProductView() {
    if (null != arrivalProductList && arrivalProductList.length > 0) {
      return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: arrivalProductList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
              child: Column(
                children: [
                  Padding(
                      padding: EdgeInsets.all((displayHeight(context) * 0.01)),
                      child: CachedNetworkImage(
                        imageUrl: ApiInterFace.PRODUCT_IMAGE_URL +
                            arrivalProductList[index].iconImageName,
                        height: displayHeight(context) * 0.2,
                        width: displayHeight(context) * 0.2,
                        httpHeaders: ApiInterFace.headers,
                        imageBuilder: (context, imageProvider) => Container(
                          height: displayHeight(context) * 0.2,
                          width: displayHeight(context) * 0.2,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                          backgroundColor: Colors.blueGrey,
                        )),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image,
                          size: 90,
                        ),
                      )

                      // Container(
                      //   height: displayHeight(context) *0.2,width: displayHeight(context) *0.2,
                      //   decoration: BoxDecoration(
                      //     image: DecorationImage(
                      //         fit: BoxFit.cover, image: NetworkImage(
                      //         ApiInterFace.PRODUCT_IMAGE_URL + arrivalProductList[index].iconImageName)),
                      //     borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      //     color: Colors.redAccent,
                      //   ),
                      // ),
                      ),
                  Text(
                    arrivalProductList[index].productName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: displayHeight(context) * 0.022,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) =>
                            UserProductViewScreen(arrivalProductList[index])))
                    .then((value) {
                  Preference().getFavoriteList().then((value) {
                    favoriteProductList = value;

                    setState(() {});
                  });
                });
              });
        },
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget billView() {
    if (null != billList && billList.length > 0) {
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
        ),
        shrinkWrap: true,
        itemCount: 6,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.network(
                ApiInterFace.BILL_IMAGE_URL + billList[index].imageName!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            onTap: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) =>
                      ImageScreen(billList, true, "Bill", ""));
            },
          );
        },
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget logOutDialog() {
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
          insetPadding: const EdgeInsets.all(40),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          //this right here
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    icon: const Icon(
                      Icons.close_fullscreen,
                      color: Colors.lightBlue,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
              Container(
                height: 50,
                padding: const EdgeInsets.all(8.0),
                child: const Center(
                  child: Text(
                    "Are You Sure To Log Out ? ",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
              Container(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                        child: const Center(
                          child: Text(
                            "Log Out ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.lightBlue),
                          ),
                        ),
                        onTap: () {
                          Preference().setUserData("");
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                              (Route<dynamic> route) => false);
                        }),
                  ),
                  Expanded(
                    flex: 1,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Colors.lightBlue,
                      child: GestureDetector(
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                "Exit App ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          onTap: () {
                            exit(1);
                          }),
                    ),
                  ),
                ],
              ),
              Container(
                height: 10,
              )
            ],
          ));
    });
  }

  Future getOffers() async {
    setState(() {});
    String url = ApiInterFace.BASE_URL + ApiInterFace.GET_LATEST_OFFER_API;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        offerModelList =
            responseModel.map((json) => new OfferModel.fromJson(json)).toList();

        setState(() {});
      }
    }
  }

  // Future getFavoriteList() async {
  //   String url = ApiInterFace.BASE_URL + ApiInterFace.GET_ALL_FAVORITE_PRODUCTS;
  //   // List args = {"ids": favoriteProductIdList};
  //   var body = json.encode(favoriteProductIdList);
  //
  //   final response =
  //   await http.post(Uri.parse(url), headers: ApiInterFace.headers,body: body);
  //
  //   if (response.statusCode == 200) {
  //     setState(() {});
  //     String sss = response.body;
  //     List responseModel = json.decode(response.body);
  //
  //     if (responseModel[0]["error"] == 0) {
  //       favoriteProductList = responseModel
  //           .map((json) => new ProductModel.fromJson(json))
  //           .toList();
  //
  //       setState(() {});
  //     }
  //   }
  // }
  Future getNewArrivals() async {
    setState(() {});
    String url = ApiInterFace.BASE_URL + ApiInterFace.GET_LAST_TEN_PRODUCTS_API;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        arrivalProductList = responseModel
            .map((json) => new ProductModel.fromJson(json))
            .toList();

        setState(() {});
      }
    }
  }

  Future getAllBills() async {
    setState(() {});
    String url = ApiInterFace.BASE_URL + ApiInterFace.GET_ALL_BILL_API;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      setState(() {});
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        billList = responseModel
            .map((userData) => new ImageModel.fromJson(userData))
            .toList();

        setState(() {});
      } else {
        Fluttertoast.showToast(
            msg: "No Bill Found",
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

  Future getAllStatus(String date) async {
    isLoading = true;
    setState(() {});
    String url = ApiInterFace.BASE_URL + ApiInterFace.GET_ALL_STATUS_API;

    final body = jsonEncode({"date": date});

    final response = await http.post(Uri.parse(url),
        headers: ApiInterFace.headers, body: body);
    if (response.statusCode == 200) {
      String sss = response.body;
      List responseModel = json.decode(response.body);

      setState(() {});
      if (responseModel[0]["error"] == 0) {
        statusModelList = responseModel
            .map((userData) => new StatusModel.fromJson(userData))
            .toList();
        totalStatusCount = 0;
        setState(() {});
        if (null != statusModelList && statusModelList.length > 0) {
          for (StatusModel statusModel in statusModelList) {
            DefaultCacheManager()
                .getFileFromCache(
                    ApiInterFace.STATUS_URL + statusModel.fileName!)
                .then((value) {
              if (null == value) {
                DefaultCacheManager()
                    .getFileStream(
                        ApiInterFace.STATUS_URL + statusModel.fileName!,
                        headers: ApiInterFace.headers,
                        withProgress: true)
                    .listen((event) {}, onDone: () {
                  totalStatusCount = totalStatusCount + 1;

                  if (totalStatusCount == statusModelList.length) {
                    isLoading = false;
                  }
                  setState(() {});
                  print("count=" + totalStatusCount.toString());
                }, onError: (error) {
                  isStatusError = true;
                  setState(() {});
                }, cancelOnError: false);
              } else {
                totalStatusCount = totalStatusCount + 1;
                if (totalStatusCount == statusModelList.length) {
                  isLoading = false;
                }
                setState(() {});
                print("count=" + totalStatusCount.toString());
              }
            });
          }
        }

        setState(() {});
      } else {
        isLoading = false;
        setState(() {});
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
      isLoading = false;

      isStatusError = true;
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

  Future getAllCategories() async {
    String url = ApiInterFace.BASE_URL + ApiInterFace.GET_ALL_CATEGORY_API;

    final response =
        await http.get(Uri.parse(url), headers: ApiInterFace.headers);

    if (response.statusCode == 200) {
      String sss = response.body;
      List responseModel = json.decode(response.body);

      if (responseModel[0]["error"] == 0) {
        categoryModelList = responseModel
            .map((userData) => new CategoryModel.fromJson(userData))
            .toList();
        setState(() {});
        Preference().setCategoryList(response.body);
      }
    }
  }
}
