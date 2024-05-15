import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({Key? key}) : super(key: key);

  @override
  State<ChangeLanguage> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  final SettingsController _settingsController = Get.find();

  @override
  void initState() {
    _settingsController.setCurrentSelectedLanguage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
               title: changeLanguageString.tr),
          const SizedBox(height: 8,),
          Expanded(
              child: GetBuilder<SettingsController>(
                  init: _settingsController,
                  builder: (ctx) {
                    return ListView.separated(
                        padding: const EdgeInsets.only(top: 20),
                        itemBuilder: (ctx, index) {
                          Map<String, String> language =
                              _settingsController.languagesList[index];
                          return Row(
                            children: [
                              BodyLargeText(
                                language['language_name']!,
                              ),
                              const Spacer(),
                              _settingsController.currentLanguage.value ==
                                      language['language_code']!
                                  ? ThemeIconWidget(
                                      ThemeIcon.checkMarkWithCircle,
                                      size: 20,
                                      color: AppColorConstants.themeColor,
                                    )
                                  : Container()
                            ],
                          ).hp(DesignConstants.horizontalPadding).ripple(() {
                            // var locale = Locale(language['language_code']!,
                            //     language['country_code']!);
                            // context.setLocale(locale);
                            _settingsController.changeLanguage(language);
                          });
                        },
                        separatorBuilder: (ctx, index) {
                          return divider().vP16;
                        },
                        itemCount: _settingsController.languagesList.length);
                  }))
        ],
      ),
    );
  }
}
