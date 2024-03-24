import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_convertor/screens/video_editor_screen.dart';

class ChooseVideo extends StatelessWidget {
  const ChooseVideo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
          child: Text('Choose video'),
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['mkv', 'flv', 'mp4'],
            );

            final inputVideoPath = result?.files.first.path ?? '';
            File file = File(inputVideoPath);
            Get.to(VideoEditor(file: file));
          },
        ),
      ),
    );
  }
}
