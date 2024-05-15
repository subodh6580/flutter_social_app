import 'package:foap/apiHandler/apis/misc_api.dart';
import 'package:get/get.dart';
import '../../model/category_model.dart';

class SetProfileCategoryController extends GetxController {
  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxInt profileCategoryType = (-1).obs;

  getProfileTypeCategories() {
    MiscApi.getProfileCategoryType(resultCallback: (result) {
      categories.value = result;
    });
  }

  setProfileCategoryType(int categoryType) {
    profileCategoryType.value = categoryType;
    update();
  }
}
