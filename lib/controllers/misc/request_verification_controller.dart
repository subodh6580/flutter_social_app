import 'package:foap/apiHandler/apis/profile_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';
import 'package:foap/model/verification_request_model.dart';
import '../../apiHandler/apis/misc_api.dart';

class RequestVerificationController extends GetxController {
  RxList<VerificationRequest> verificationRequests =
      <VerificationRequest>[].obs;

  Rx<TextEditingController> messageTf = TextEditingController().obs;
  Rx<TextEditingController> documentType = TextEditingController().obs;

  RxList<File> selectedImages = <File>[].obs;

  bool get isVerificationInProcess {
    return verificationRequests
        .where((request) => request.isProcessing == true)
        .toList()
        .isNotEmpty;
  }

  bool get isApproved {
    return verificationRequests
        .where((request) => request.isApproved == true)
        .toList()
        .isNotEmpty;
  }

  String get verifiedOn {
    int verifiedOn = verificationRequests
        .where((request) => request.isApproved == true)
        .toList()
        .first
        .updatedAt!;

    return DateFormat('dd-MM-yyyy hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(verifiedOn * 1000));
  }

  String get requestSentOn {
    int verifiedOn = verificationRequests
        .where((request) => request.isProcessing == true)
        .toList()
        .first
        .createdAt;

    return DateFormat('dd-MM-yyyy hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(verifiedOn * 1000));
  }

  clear() {
    documentType.value.text = '';
    messageTf.value.text = '';
    selectedImages.clear();
  }

  getVerificationRequests() {
    ProfileApi.getVerificationRequestHistory(resultCallback: (result) {
      verificationRequests.value = result;
      verificationRequests.refresh();
      update();
    });
  }

  setSelectedDocumentType(String document) {
    documentType.value.text = document;
    documentType.refresh();
  }

  addDocument(File file) {
    selectedImages.add(file);
  }

  deleteDocument(File file) {
    selectedImages.remove(file);
  }

  submitRequest(BuildContext context) async {
    if (documentType.value.text.isEmpty) {
      AppUtil.showToast(
          message: pleaseSelectDocumentTypeString.tr, isSuccess: false);
      return;
    }
    if (selectedImages.isEmpty) {
      AppUtil.showToast(message: pleaseUploadProofString.tr, isSuccess: false);
      return;
    }

    List<Map<String, String>> idProofImages = [];

    EasyLoading.show(status: loadingString.tr);
    for (File file in selectedImages) {
      await MiscApi.uploadFile(file.path,
          mediaType: GalleryMediaType.photo, type: UploadMediaType.verification,
          resultCallback: (fileName, filePath) {
        Map<String, String> proof = {
          'filename': fileName,
          'media_type': '1',
          'title': '',
        };
        idProofImages.add(proof);
      });
    }

    ProfileApi.sendProfileVerificationRequest(
        userMessage: messageTf.value.text,
        documentType: documentType.value.text,
        images: idProofImages,
        resultCallback: () {
          EasyLoading.dismiss();

          getVerificationRequests();

          AppUtil.showToast(
              message: verificationRequestSentString.tr, isSuccess: true);

          clear();
          Timer(const Duration(seconds: 2), () {
            Get.back();
          });
        });
  }

  cancelRequest(int id) {
    ProfileApi.cancelProfileVerificationRequest(
        id: id,
        userMessage: '',
        resultCallback: () {
          verificationRequests.removeWhere((request) => request.id == id);
          update();
          getVerificationRequests();
          update();
        });
  }
}
