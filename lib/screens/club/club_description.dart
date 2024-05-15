import 'package:foap/helper/imports/common_import.dart';

class ClubDescription extends StatefulWidget {
  const ClubDescription({Key? key}) : super(key: key);

  @override
  ClubDescriptionState createState() => ClubDescriptionState();
}

class ClubDescriptionState extends State<ClubDescription> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      // appBar: CustomNavigationBar(
      //   child: appBar(),
      // ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          backNavigationBar(
            title: clubDescriptionString.tr,
          ),
          const SizedBox(height: 8,),
          const SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading4Text('Add a Description', weight: TextWeight.semiBold),
              const Heading6Text(
                'Describe your group so people know what is about',
              ),
              const SizedBox(
                height: 10,
              ),
              AppTextField(
                hintText: 'Describe your group',
                maxLines: 5,
                controller: controller,
              )
            ],
          ).hp(DesignConstants.horizontalPadding),
          const Spacer(),
          AppThemeButton(
                  text: doneString.tr,
                  onPress: () {
                    // Get.to(() => const InviteUsersToClub());
                    // NavigationService.instance.navigateToRoute(
                    //     MaterialPageRoute(builder: (ctx) => InviteUser()));
                  })
              .hp(DesignConstants.horizontalPadding),
          const SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }
}
