import 'package:foap/helper/imports/club_imports.dart';
import 'package:foap/helper/imports/common_import.dart';

import '../../components/group_avatars/group_avatar1.dart';
import '../../model/category_model.dart';

class CategoriesList extends StatefulWidget {
  final ClubsController clubsController;

  const CategoriesList({Key? key, required this.clubsController})
      : super(key: key);

  @override
  State<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
            title: categoriesString.tr,
          ),
          const SizedBox(height: 8,),

          Expanded(
              child: GetBuilder<ClubsController>(
                  init: widget.clubsController,
                  builder: (ctx) {
                    return GridView.builder(
                        itemCount: widget.clubsController.categories.length,
                        padding:  EdgeInsets.only(
                            top: 20, left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, bottom: 50),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                                childAspectRatio: 1),
                        itemBuilder: (ctx, index) {
                          CategoryModel category =
                              widget.clubsController.categories[index];
                          return CategoryAvatarType1(category: category)
                              .ripple(() {
                            ClubModel club = ClubModel();
                            club.categoryId = category.id;
                            Get.to(() => CreateClub(
                                  club: club,
                                ));
                          });
                        });
                  }))
        ],
      ),
    );
  }
}
