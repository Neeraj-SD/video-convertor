import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_convertor/controller/video-to-gif-controller.dart';

class VideoToGIFScreen extends StatelessWidget {
  VideoToGIFScreen({super.key});

  final VideoToGifController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video to GIF convertor"),
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
                      DropdownMenu<FilterLabel>(
                        initialSelection: controller.filter.value,
                        width: 200,
                        label: const Text('Filter'),
                        onSelected: (FilterLabel? filter) {
                          controller.setFilter(filter!);
                        },
                        dropdownMenuEntries: FilterLabel.values
                            .map<DropdownMenuEntry<FilterLabel>>(
                                (FilterLabel color) {
                          return DropdownMenuEntry<FilterLabel>(
                            value: color,
                            label: color.label,
                            enabled: controller.hasGif.value,
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
                    : Image.file(
                        controller.gifImage,
                        height: 500,
                      ),
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
