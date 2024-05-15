import 'package:foap/helper/imports/common_import.dart';
import '../../../model/verification_request_model.dart';

class VerificationRejectReason extends StatelessWidget {
  final VerificationRequest request;

  const VerificationRejectReason({Key? key, required this.request})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [

          backNavigationBar(title: replyString.tr),
          // divider(context: context).tP8,
          const SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            child: Heading6Text(
              request.adminMessage ?? '',
              weight: TextWeight.regular,
            ).hp(DesignConstants.horizontalPadding),
          )
        ],
      ),
    );
  }
}
