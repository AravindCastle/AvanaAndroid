import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

import 'package:photo_view/photo_view.dart';

class PhotoViewr extends StatefulWidget {
  _PhotoViewrState createState() => _PhotoViewrState();
}

class _PhotoViewrState extends State<PhotoViewr> {
  ReceivePort _port = ReceivePort();
  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  void _download(String url) async {
    final externalDir = await getExternalStorageDirectory();

    final id = await FlutterDownloader.enqueue(
      url: url,
      savedDir: externalDir.path,
      showNotification: true,
      openFileFromNotification: true,
      saveInPublicStorage: true,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Download started ...'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    Map arg = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(arg["name"]),
        actions: [
          IconButton(
              icon: Icon(Icons.download_sharp),
              onPressed: () => {_download(arg["url"])})
        ],
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
