import 'package:foap/helper/imports/common_import.dart';
import '../../controllers/profile/profile_controller.dart';

class ChangeLocation extends StatefulWidget {
  const ChangeLocation({Key? key}) : super(key: key);

  @override
  State<ChangeLocation> createState() => _ChangeLocationState();
}

class _ChangeLocationState extends State<ChangeLocation> {
  final UserProfileManager _userProfileManager = Get.find();

  TextEditingController country = TextEditingController();
  TextEditingController city = TextEditingController();

  late UserModel model;

  final ProfileController profileController = Get.find();

  @override
  void initState() {
    model = _userProfileManager.user.value!;

    super.initState();

    country.text = model.country ?? '';
    city.text = model.city ?? '';
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
              
              title: changeLocationString.tr,
              rightBtnTitle: doneString.tr,
              completion: () {
                updateLocation();
              }),
          divider().vP8,
          const SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading6Text(countryString.tr,
                  weight: TextWeight.medium),
              Container(
                color: Colors.transparent,
                height: 50,
                child: AppTextField(
                  controller: country,
                  hintText: countryString.tr,
                ),
              ).vP8,
              const SizedBox(
                height: 20,
              ),
              Heading6Text(cityString.tr, weight: TextWeight.medium),
              Container(
                color: Colors.transparent,
                height: 50,
                child: AppTextField(
                  controller: city,
                  hintText: cityString.tr,
                ),
              ).vP8,
              const SizedBox(
                height: 20,
              ),
            ],
          ).hp(DesignConstants.horizontalPadding),
        ],
      ),
    );
  }

  updateLocation() {
    profileController.updateLocation(
        country: country.text, city: city.text);
  }
}
