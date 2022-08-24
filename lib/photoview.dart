import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

import 'package:photo_view/photo_view.dart';

class PhotoViewr extends StatelessWidget {
  Future<String> getDownloadPath() async {
    Directory directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists())
          directory = await getExternalStorageDirectory();
      }
    } catch (err, stack) {
      print("Cannot get download folder path");
    }
    return directory.path;
  }

  Future<void> fileDownload(String url) async {
    final downloadPath = await getDownloadPath();

    final taskId = await FlutterDownloader.enqueue(
      url: url,
      saveInPublicStorage: true,
      savedDir: downloadPath,
      headers: {}, // optional: header send with url (auth token etc)
      //savedDir: 'the path of directory where you want to save downloaded files',
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
  }

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
        ElevatedButton(
          child: Text("Download"),
          onPressed: () => {fileDownload(arg["url"])},
        ),
      ])),
    );
  }
}
