import 'package:foap/helper/imports/club_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/reuseable_widgets/club_listing.dart';

import '../../components/actionSheets/action_sheet1.dart';
import '../../model/category_model.dart';
import '../../model/generic_item.dart';
import '../../model/post_model.dart';
import '../../segmentAndMenu/horizontal_menu.dart';

class CategoryClubsListing extends StatefulWidget {
  final CategoryModel category;

  const CategoryClubsListing({Key? key, required this.category})
      : super(key: key);

  @override
  CategoryClubsListingState createState() => CategoryClubsListingState();
}

class CategoryClubsListingState extends State<CategoryClubsListing> {
  final ClubsController _clubsController = Get.find();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clubsController.setCategoryId(widget.category.id);
      _clubsController.selectedSegmentIndex(index: 0);
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
            title: widget.category.name,
          ),
          Obx(() => Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  HorizontalMenuBar(
                      padding:  EdgeInsets.only(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding),
                      onSegmentChange: (segment) {
                        _clubsController.selectedSegmentIndex(
                          index: segment,
                        );
                      },
                      selectedIndex: _clubsController.segmentIndex.value,
                      menus: [
                        allString.tr,
                        joinedString.tr,
                        myClubString.tr,
                      ]),
                ],
              )),
          const SizedBox(
            height: 20,
          ),
          Expanded(child: ClubListing())
        ],
      ),
    );
  }

  showActionSheet(PostModel post) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ActionSheet1(
              items: [
                GenericItem(
                    id: '1', title: shareString.tr, icon: ThemeIcon.share),
                GenericItem(
                    id: '2', title: reportString.tr, icon: ThemeIcon.report),
                GenericItem(
                    id: '3', title: hideString.tr, icon: ThemeIcon.hide),
              ],
              itemCallBack: (item) {},
            ));
  }
}
