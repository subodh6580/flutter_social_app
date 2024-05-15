import 'package:foap/helper/imports/club_imports.dart';
import 'package:foap/helper/imports/common_import.dart';

class ClubSettings extends StatefulWidget {
  final ClubModel club;
  final Function(ClubModel) deleteClubCallback;

  // final Function(ClubModel) updateClubCallback;
  const ClubSettings({
    Key? key,
    required this.club,
    required this.deleteClubCallback,
    // required this.updateClubCallback
  }) : super(key: key);

  @override
  State<ClubSettings> createState() => _ClubSettingsState();
}

class _ClubSettingsState extends State<ClubSettings> {
  final ClubsController _clubsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
               title: clubSettingsString.tr),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 25),
              children: [
                Row(
                  children: [
                    Heading6Text(
                      editClubInfoString.tr,
                    ),
                    const Spacer(),
                    const ThemeIconWidget(
                      ThemeIcon.nextArrow,
                      size: 20,
                    )
                  ],
                ).ripple(() {
                  Get.to(() => CreateClub(
                        club: widget.club,
                        // submittedCallback: (club) {
                        //   widget.updateClubCallback(club!);
                        //   Get.back();
                        // },
                      ));
                }),
                divider().vP16,
                Row(
                  children: [
                    Heading6Text(
                      editClubImageString.tr,
                    ),
                    const Spacer(),
                    const ThemeIconWidget(
                      ThemeIcon.nextArrow,
                      size: 20,
                    )
                  ],
                ).ripple(() {
                  Get.to(() => ChooseClubCoverPhoto(
                        club: widget.club,
                        // submittedCallback: (club) {
                        //   widget.updateClubCallback(club!);
                        //   Get.back();
                        // },
                      ));
                }),
                divider().vP16,
                Row(
                  children: [
                    Heading6Text(deleteClubString.tr,
                        weight: TextWeight.medium, color: AppColorConstants.red),
                  ],
                ).ripple(() {
                  AppUtil.showConfirmationAlert(
                      title: deleteClubString.tr,
                      subTitle: areYouSureToDeleteClubString.tr,
                      okHandler: () {
                        _clubsController.deleteClub(
                            club: widget.club,
                            callback: () {
                              widget.deleteClubCallback(widget.club);
                            });
                      });
                }),
                divider().vP16,
              ],
            ).hp(DesignConstants.horizontalPadding),
          )
        ],
      ),
    );
  }
}
