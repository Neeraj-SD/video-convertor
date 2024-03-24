import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_convertor/controller/video-to-gif-controller.dart';
import 'package:video_player/video_player.dart';

class VideoConvertScreen extends StatelessWidget {
  const VideoConvertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VideoToGifController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video to any format convertor"),
      ),
      body: Obx(
        () => controller.loading.value
            ? const Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : Column(children: [
                SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          child: const Text('Choose video'),
                          onPressed: () => controller.convertToGIF()),
                      DropdownMenu<FormatLabel>(
                        initialSelection: controller.toFormat.value,
                        width: 200,
                        label: const Text('Format'),
                        onSelected: (FormatLabel? filter) {
                          controller.setFormat(filter!);
                        },
                        dropdownMenuEntries: FormatLabel.values
                            .map<DropdownMenuEntry<FormatLabel>>(
                                (FormatLabel color) {
                          return DropdownMenuEntry<FormatLabel>(
                            value: color,
                            label: color.label,
                            enabled: true,
                            style: MenuItemButton.styleFrom(
                              foregroundColor: color.color,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                !controller.hasGif.value
                    ? const Text('Please choose a video file to convert')
                    : controller.toFormat == FormatLabel.GIF
                        ? Image.file(
                            controller.gifImage,
                            height: 500,
                          )
                        : controller.videoReady.value
                            ? AspectRatio(
                                aspectRatio: controller
                                    .videoController.value.aspectRatio,
                                child: VideoPlayer(controller.videoController),
                              )
                            : Container(),
                OutlinedButton(
                  onPressed: () => controller.exportGIF(),
                  child: const Text('Export'),
                ),
                OutlinedButton(
                  onPressed: () => controller.shareGIF(),
                  child: const Text('Share'),
                ),
              ]),
      ),
    );
  }
}
