import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import '../../../controllers/misc/request_verification_controller.dart';
import '../../../model/verification_request_model.dart';

class RequestVerificationList extends StatefulWidget {
  const RequestVerificationList({Key? key}) : super(key: key);

  @override
  State<RequestVerificationList> createState() =>
      _RequestVerificationListState();
}

class _RequestVerificationListState extends State<RequestVerificationList> {
  final RequestVerificationController _requestVerificationController =
      RequestVerificationController();

  @override
  void initState() {
    _requestVerificationController.getVerificationRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [

            backNavigationBar(title: requestVerificationString.tr),
            // divider(context: context).tP8,
            Expanded(
              child: Obx(() => ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _requestVerificationController
                      .verificationRequests.length,
                  itemBuilder: (BuildContext context, int index) {
                    VerificationRequest request = _requestVerificationController
                        .verificationRequests[index];
                    return Container(
                      height: 80,
                      width: 80,
                      color: AppColorConstants.cardColor,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    ThemeIconWidget(
                                      ThemeIcon.calendar,
                                      color: AppColorConstants.themeColor,
                                      size: 15,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    BodySmallText(request.sentOn,
                                        weight: TextWeight.medium)
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    BodySmallText('${statusString.tr} :',
                                        weight: TextWeight.semiBold),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    BodySmallText(
                                      request.isProcessing
                                          ? inProcessingString.tr
                                          : request.isCancelled
                                              ? cancelledString.tr
                                              : request.isRejected
                                                  ? rejectedString.tr
                                                  : approvedString.tr,
                                      color: request.isProcessing
                                          ? Colors.yellow.darken(0.25)
                                          : request.isRejected ||
                                                  request.isCancelled
                                              ? Colors.red
                                              : Colors.green,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          if (request.isProcessing)
                            Container(
                              width: 80,
                              color: AppColorConstants.themeColor,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const ThemeIconWidget(ThemeIcon.close,
                                      size: 28),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  BodyMediumText(
                                    cancelString.tr,
                                  )
                                ],
                              ),
                            ).ripple(() {
                              _requestVerificationController
                                  .cancelRequest(request.id);
                            }),
                          if (request.isRejected)
                            const ThemeIconWidget(
                              ThemeIcon.nextArrow,
                              size: 18,
                            ).rP16
                        ],
                      ).lP16,
                    ).ripple(() {
                      if (request.isRejected) {
                        Get.to(() => VerificationRejectReason(
                              request: request,
                            ));
                      }
                    });
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return divider().vP8;
                  })),
            ),
          ],
        ));
  }
}
