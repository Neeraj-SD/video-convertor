import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:video_convertor/controller/video-to-gif-controller.dart';
import 'package:video_convertor/getx_di.dart';
import 'package:video_convertor/screens/choose_video.dart';
import 'package:video_convertor/screens/display_videos.dart';
import 'package:video_convertor/screens/video_convert_sceen.dart';
import 'package:video_convertor/screens/video_to_gif_screen.dart';

void main() {
  GetXDependencyInjector().onInit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: MyHomePage(title: 'Flutter Demo Home Page'),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () => Get.to(VideoConvertScreen()),
                child: const Text('Video to any convertor')),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
                onPressed: () => Get.to(VideoToGIFScreen()),
                child: const Text('Video to GIF convertor')),
            ElevatedButton(
                onPressed: () => Get.to(ChooseVideo()),
                child: const Text('Video Editor')),
            ElevatedButton(
                onPressed: () => Get.to(VideoListScreen()),
                child: const Text('Video List Screen')),
          ],
        ),
      ),
    );
  }
}
