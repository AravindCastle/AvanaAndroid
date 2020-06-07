

import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoViewer extends StatefulWidget {
  @override
  VideoViewerState createState() => VideoViewerState();
}

class VideoViewerState extends State<VideoViewer> {
  Map args;
  Future<bool> closePop(BuildContext context,VideoPlayerController vd) async{
      vd.pause();
      setState(() {
        vd=null;
      });
      
         
          vd.dispose();
          Navigator.pop(context); 
          return Future.value(true);
  }
  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    VideoPlayerController vidCnt=VideoPlayerController.network(args["url"]);
    return 
    WillPopScope(
        onWillPop: (){closePop(context,vidCnt);  return Future.value(true);},
        child:
    Scaffold(
      appBar: AppBar(
        title: Text(args["name"]),
      ),
      body: Column(
        children: <Widget>[
          ChewieListItem(
            videoPlayerController:vidCnt ,
          )
        ],
      ),
    ));
  }
}



class ChewieListItem extends StatefulWidget {
  // This will contain the URL/asset path which we want to play
  final VideoPlayerController videoPlayerController;
 

  ChewieListItem({
    @required this.videoPlayerController,Key key,}) : super(key: key);

  @override
  _ChewieListItemState createState() => _ChewieListItemState();
}

class _ChewieListItemState extends State<ChewieListItem> {
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    // Wrapper on top of the videoPlayerController
    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      aspectRatio: 16 / 9,
      // Prepare the video to be played and display the first frame
      autoInitialize: true,     
      // Errors can occur for example when trying to play a video
      // from a non-existent URL
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return 
 WillPopScope(
        onWillPop: (){_chewieController.dispose();  return Future.value(true);},
        child:
       
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Chewie(
        controller: _chewieController,
      ),
 ));
  }

  @override
  void dispose() {
    super.dispose();
    // IMPORTANT to dispose of all the used resources
    _chewieController.dispose();
    widget.videoPlayerController.dispose();

  }
}