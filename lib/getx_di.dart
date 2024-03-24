import 'package:get/get.dart';
import 'package:video_convertor/controller/video-to-gif-controller.dart';

class GetXDependencyInjector {
  void onInit() {
    Get.lazyPut(() => VideoToGifController(), fenix: true);
  }
}
