import 'package:foap/helper/imports/common_import.dart';
import '../../controllers/profile/profile_controller.dart';

class ChangePaypalId extends StatefulWidget {
  const ChangePaypalId({Key? key}) : super(key: key);

  @override
  State<ChangePaypalId> createState() => _ChangePaypalIdState();
}

class _ChangePaypalIdState extends State<ChangePaypalId> {
  TextEditingController paypalId = TextEditingController();
  final ProfileController profileController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    paypalId.text = _userProfileManager.user.value!.paypalId ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          profileScreensNavigationBar(

              title: paymentDetailString.tr,
              rightBtnTitle: doneString.tr,
              completion: () {
                profileController.updatePaypalId(
                    paypalId: paypalId.text, );
              }),

          divider().vP8,
          const SizedBox(
            height: 20,
          ),
          Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Heading6Text(paypalIdString.tr,
                      weight: TextWeight.medium),
                  Container(
                    color: Colors.transparent,
                    height: 50,
                    child: AppTextField(
                      controller: paypalId,
                      // showBorder: true,
                      hintText: 'paypalId@gmail.com',
                    ),
                  ),
                ],
              ).vP8,
            ],
          ).hp(DesignConstants.horizontalPadding),
        ],
      ),
    );
  }
}
