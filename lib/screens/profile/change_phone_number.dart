import 'package:foap/helper/imports/common_import.dart';
import '../../controllers/profile/profile_controller.dart';

class ChangePhoneNumber extends StatefulWidget {
  const ChangePhoneNumber({Key? key}) : super(key: key);

  @override
  ChangePhoneNumberState createState() => ChangePhoneNumberState();
}

class ChangePhoneNumberState extends State<ChangePhoneNumber> {
  TextEditingController phoneNumber = TextEditingController();
  final ProfileController profileController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  String countryCode = "+1";

  @override
  void initState() {
    super.initState();
    phoneNumber.text = _userProfileManager.user.value!.phone ?? '';
    countryCode = _userProfileManager.user.value!.countryCode ?? '+1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(
              height: 55,
            ),
            profileScreensNavigationBar(
                title: changePhoneNumberString.tr,
                rightBtnTitle: doneString.tr,
                completion: () {
                  profileController.updateMobile(
                      countryCode: countryCode,
                      phoneNumber: phoneNumber.text,
                      );
                }),
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyLargeText(phoneNumberString.tr,
                    weight: TextWeight.medium),
                const SizedBox(
                  height: 8,
                ),
                addTextField(),
              ],
            ).hp(DesignConstants.horizontalPadding)
          ]),
        ));
  }

  addTextField() {
    return SizedBox(
      height: 50,
      child: AppMobileTextField(
        onChanged: (value) {},
        countryCodeValueChanged: (value) {
          countryCode = value;
          setState(() {});
        },
        controller: phoneNumber,
        hintText: '123456789',
      ),
    ).vP8;
  }
}
