import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class VideoListScreen extends StatefulWidget {
  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  late Future<List<File>> _videoFiles;

  @override
  void initState() {
    super.initState();
    _videoFiles = listVideoFiles();
  }

  Future<List<File>> listVideoFiles() async {
    Directory? appDocDir = await getDownloadsDirectory();
    List<FileSystemEntity> files =
        appDocDir!.listSync(recursive: true, followLinks: false);

    List<File> videoFiles = files
        .where((file) {
          return FileSystemEntity.isFileSync(file.path) &&
                  file.path.toLowerCase().endsWith('.mp4') ||
              file.path.toLowerCase().endsWith('.mkv') ||
              file.path.toLowerCase().endsWith('.mov') ||
              file.path.toLowerCase().endsWith('.flv');
        })
        .map((file) => File(file.path))
        .toList();

    print('video Files: ${videoFiles}');

    setState(() {});

    return videoFiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Files'),
      ),
      body: FutureBuilder<List<File>>(
        future: _videoFiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<File> videoFiles = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: videoFiles.length,
              itemBuilder: (context, index) {
                return VideoTile(videoFiles[index]);
              },
            );
          }
        },
      ),
    );
  }
}

class VideoTile extends StatelessWidget {
  final File videoFile;

  VideoTile(this.videoFile);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle tap, e.g., play the video
        // You can add your logic here to play the video
      },
      child: Card(
        elevation: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey,
                child: Icon(
                  Icons.play_circle_outline,
                  size: 50.0,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                videoFile.path.split('/').last,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
