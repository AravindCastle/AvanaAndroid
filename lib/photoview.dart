import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewr extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Map arg = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(arg["name"]),
      ),
      body: Container(
          child: Stack(children: [
        SizedBox(
          height: 10,
          child: Icon(Icons.close),
        ),
        PhotoView(
            loadingBuilder: (context, event) => Center(
                  child: Container(
                    child: CircularProgressIndicator(
                      value: event == null
                          ? 0
                          : event.cumulativeBytesLoaded /
                              event.expectedTotalBytes,
                    ),
                  ),
                ),
            imageProvider: CachedNetworkImageProvider(arg["url"])),
      ])),
    );
  }
}
