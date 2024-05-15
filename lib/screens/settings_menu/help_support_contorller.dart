import 'package:foap/helper/imports/common_import.dart';
import '../../apiHandler/apis/misc_api.dart';
import '../../model/support_request_response.dart';
import 'package:foap/helper/list_extension.dart';

class HelpSupportController extends GetxController {
  RxList<SupportRequest> list = <SupportRequest>[].obs;

  void getSupportRequests() {
    AppUtil.checkInternet().then((value) {
      MiscApi.getSupportMessages(resultCallback: (result, metadata) {
        list.clear();
        list.addAll(result);
        list.unique((e) => e.id);
      });
    });
  }

  void submitSupportRequest(
      {required String? name,
      required String? email,
      required String? phone,
      required String? message}) {
    if (name!.isNotEmpty &&
        email!.isNotEmpty &&
        phone!.isNotEmpty &&
        message!.isNotEmpty) {
      MiscApi.sendSupportRequest(
          name: name, email: email, phone: phone, message: message);
    }
  }

  void getSupportRequestView(int id) {
    MiscApi.getSupportMessageView(id);
  }
}
