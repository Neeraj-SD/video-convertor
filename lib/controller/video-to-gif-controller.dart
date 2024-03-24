import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

enum FilterLabel {
  DEFAULT('Default', Colors.green),
  HIGH_QUALITY('Highest Quality', Colors.blue),
  HIGH_QUALITY_COMPRESSED('Highest Quality and Compressed', Colors.pink);
  // yellow('Orange', Colors.orange),
  // grey('Grey', Colors.grey);

  const FilterLabel(this.label, this.color);
  final String label;
  final Color color;
}

enum FormatLabel {
  _3GP('3GP', Colors.green, '3gp'),
  MKV('MKV', Colors.blue, 'mkv'),
  AVI('AVI', Colors.pink, 'avi'),
  MP3('MP3', Colors.grey, 'mp3'),
  MP4('MP4', Colors.orange, 'mp4'),
  GIF('GIF', Colors.pink, 'gif');
  // yellow('Orange', Colors.orange),
  // grey('Grey', Colors.grey);

  const FormatLabel(this.label, this.color, this.format);
  final String label;
  final Color color;
  final String format;
}

String getDefault(String inputVideoName, String outputVideoName) =>
    '-i $inputVideoName $outputVideoName';

String getHighQualityGIF(String inputVideoName, String outputVideoName) =>
    '-i $inputVideoName -filter_complex "[0]split[a][b]; [a]palettegen[palette]; [b][palette]paletteuse" $outputVideoName';

String getHighQualityGIFAndCompressed(
        String inputVideoName, String outputVideoName) =>
    '-ss 3 -to 8 -i $inputVideoName -filter_complex "fps=10,scale=360:-1[s]; [s]split[a][b]; [a]palettegen[palette]; [b][palette]paletteuse" $outputVideoName';

class VideoToGifController extends GetxController {
  late File gifImage;
  final loading = false.obs;
  final videoReady = false.obs;
  final hasGif = false.obs;
  final filter = FilterLabel.DEFAULT.obs;
  final toFormat = FormatLabel.MP4.obs;
  late VideoPlayerController videoController;

  String inputVideoName = '';
  String inputVideoFileName = '';

  String _getExecCommand(String inputVideoName, String outputVideoName) {
    switch (filter.value) {
      case FilterLabel.DEFAULT:
        return getDefault(inputVideoName, outputVideoName);
      case FilterLabel.HIGH_QUALITY:
        return getHighQualityGIF(inputVideoName, outputVideoName);
      case FilterLabel.HIGH_QUALITY_COMPRESSED:
        return getHighQualityGIFAndCompressed(inputVideoName, outputVideoName);
    }
  }

  String _getVideoConvertCommand(
      String inputVideoPath, String outputVideoPath) {
    return '-i $inputVideoPath -c copy $outputVideoPath';
  }

  String _getVideoToAudioConvertCommand(
      String inputVideoPath, String outputVideoPath) {
    return '-i $inputVideoPath -vn $outputVideoPath';
  }

  void convert() async {
    loading.value = true;
    String outputVideoName =
        '/data/user/0/com.example.video_convertor/cache/file_picker/${DateTime.now().millisecondsSinceEpoch}.${toFormat.value.format}';
    log('OUTPUT FILE: $outputVideoName');
    String execCommand = toFormat.value == FormatLabel.GIF
        ? _getExecCommand(inputVideoName, outputVideoName)
        : toFormat.value == FormatLabel.MP3
            ? _getVideoToAudioConvertCommand(inputVideoName, outputVideoName)
            : _getVideoConvertCommand(inputVideoName, outputVideoName);
    FFmpegKit.executeAsync(
            execCommand,
            (session) async {
              final state = FFmpegKitConfig.sessionStateToString(
                  await session.getState());
              final returnCode = await session.getReturnCode();
              final failStackTrace = await session.getFailStackTrace();
              final duration = await session.getDuration();

              // this.hideProgressDialog();

              if (ReturnCode.isSuccess(returnCode)) {
                log("Encode completed successfully in ${duration} milliseconds; playing video.");
                gifImage = File(outputVideoName);
                loading.value = false;
                hasGif.value = true;
                videoController = VideoPlayerController.file(gifImage)
                  ..initialize().then((value) => videoReady.value = true);
                videoController.play();
              } else {
                Get.snackbar(
                    'Encode failed.',
                    ("Encode failed with state ${state} and rc ${returnCode}.${(
                      failStackTrace,
                      "\\n"
                    )}"));
                log("Encode failed. Please check log for the details.");
                log("Encode failed with state ${state} and rc ${returnCode}.${(
                  failStackTrace,
                  "\\n"
                )}");
                loading.value = false;
              }
            },
            (logFile) => log(logFile.getMessage()),
            (statistics) {
              // this._statistics = statistics;
              // this.updateProgressDialog();
            })
        .then((session) => log(
            "Async FFmpeg process started with sessionId ${session.getSessionId()}."));
  }

  void videoConvert() async {}

  void convertToGIF() async {
    loading.value = true;
    videoReady.value = false;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['3gp', 'flv', 'doc', 'mp4'],
    );

    inputVideoName = result?.files.first.path ?? '';
    inputVideoFileName = result?.files.first.name ?? '';

    // FFMP convert to gif
    convert();
  }

  void setFilter(FilterLabel filterLabel) {
    if (filterLabel == filter.value) return;

    filter.value = filterLabel;

    // recall the convert func
    convert();
  }

  void setFormat(FormatLabel formatLabel) {
    if (formatLabel == toFormat.value) return;

    toFormat.value = formatLabel;

    // recall the convert func
    convert();
  }

  MimeType getMimeType() {
    switch (toFormat.value) {
      case FormatLabel.AVI:
        return MimeType.avi;
      case FormatLabel.MP3:
        return MimeType.mp3;
      case FormatLabel.GIF:
        return MimeType.gif;
      default:
        return MimeType.mpeg;
    }
  }

  void exportGIF() async {
    final res = await FileSaver.instance.saveAs(
      name: 'generated',
      file: gifImage,
      ext: toFormat.value.format,
      mimeType: getMimeType(),
    );
    log(res.toString());
  }

  void shareGIF() async {
    await FlutterShare.shareFile(
      title: 'Example share',
      text: 'Example share text',
      chooserTitle: 'Example Chooser Title',
      filePath: gifImage.path,
    );
  }
}
