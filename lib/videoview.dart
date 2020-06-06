import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoPage extends StatelessWidget {
  VideoPage({Key key, this.param}) : super(key: key);
  final Map param;

  VideoPlayerController _videoPlayerController1;
  ChewieController _chewieController;

  void initPlayer() {
    _videoPlayerController1 = VideoPlayerController.network(param["url"]);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      aspectRatio: 16 / 9,
      autoPlay: true,
      looping: true,
      // Try playing around with some of these other options:

      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // placeholder: Container(
      //   color: Colors.grey,
      // ),
      // autoInitialize: true,
    );
  }

  Widget build(BuildContext context) {
    initPlayer();
    return new WillPopScope(
        onWillPop: () {
          _videoPlayerController1.pause();
          _videoPlayerController1.dispose();
          _chewieController.dispose();
          Navigator.pop(context);
        },
        child: Expanded(
          child: Center(
            child: Chewie(
              controller: _chewieController,
            ),
          ),
        ));
  }
}

class VideoViewer extends StatefulWidget {
  @override
  VideoViewerState createState() => VideoViewerState();
}

class VideoViewerState extends State<VideoViewer> {
  Map args;

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(args["name"]),
      ),
      body: Column(
        children: <Widget>[
          VideoPage(param: args),
        ],
      ),
    );
  }
}
