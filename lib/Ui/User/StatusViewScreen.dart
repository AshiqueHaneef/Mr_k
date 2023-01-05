import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:Mr_k/Api/ApiInterFace.dart';
import 'package:Mr_k/Models/StatusModel.dart';

import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:video_viewer/video_viewer.dart';

class StatusViewScreen extends StatefulWidget {
  StatusViewScreen(this.statusModelList);
  List<StatusModel> statusModelList = [];

  @override
  statusViewScreenState createState() => statusViewScreenState(statusModelList);
}

class statusViewScreenState extends State<StatusViewScreen> {
  statusViewScreenState(this.statusModelList);
  Map<String, Map<String, String>>? database = {};
  MapEntry<String, Map<String, String>>? initial;
  List<StatusModel> statusModelList = [];
  VideoViewerController? controller = new VideoViewerController();
  int? currentVideoCount = 0;
  VideoPlayerController? _controller;
  // List<Map<String, String>> videoList = [];
   CarouselControllerImpl? _carouselController=new CarouselControllerImpl();
  VideoPlayerController? _videoPlayerController1;
  List<StoryItem>? storyItems = []; //
  StoryController? storyController = StoryController();
  StoryController? storyControllers = StoryController();

  @override
  void initState() {
    if (statusModelList.length > 0) {
      for (StatusModel statusModel in statusModelList) {
        storyController=new StoryController();

        if(statusModel.isVideo!){
          storyItems?.add(StoryItem.pageVideo(
            ApiInterFace.STATUS_URL + statusModel.fileName!,
          controller: storyController!,
            duration: Duration(seconds: int.parse(statusModel.duration!)),
          ));
        }else{
          storyItems!.add(StoryItem.pageImage( url: ApiInterFace.STATUS_URL + statusModel.fileName!, controller: storyController!));
        }

      }
    }

    super.initState();
  }

  @override
  void dispose() {
    storyController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: StoryView(
            storyItems: storyItems!,
            controller: storyControllers!, // pass controller here too
            // repeat: true, // should the stories be slid forever
            onStoryShow: (s) {

            },

            onComplete: () {
              Navigator.pop(context);
            },

            // onVerticalSwipeComplete: (direction) {
            //   if (direction == Direction.down) {
            //     Navigator.pop(context);
            //   }
            // } // To disable vertical swipe gestures, ignore this parameter.
          // Preferrably for inline story view.
        )
      ),
    );
  }
}
