import 'package:foap/controllers/misc/users_controller.dart';
import 'package:foap/controllers/post/post_controller.dart';
import 'package:get/get.dart';
import '../../model/location.dart';
import '../../model/post_search_query.dart';
import '../clubs/clubs_controller.dart';
import 'misc_controller.dart';

class ExploreController extends GetxController {
  final PostController _postController = Get.find();
  final UsersController _usersController = Get.find();
  final MiscController _miscController = Get.find();
  final ClubsController _clubsController = Get.find();

  RxList<LocationModel> locations = <LocationModel>[].obs;

  bool isSearching = false;
  RxString searchText = ''.obs;
  int selectedSegment = 0;

  clear() {
    isSearching = false;
    searchText.value = '';
    selectedSegment = 0;
  }

  startSearch() {
    update();
  }

  closeSearch() {
    clear();
    _postController.clear();
    searchText.value = '';
    selectedSegment = 0;
    update();
  }

  searchTextChanged(String text) {
    clear();
    searchText.value = text;
    _postController.clear();
    searchData();
  }

  searchData() {
    if (searchText.isNotEmpty) {
      PostSearchQuery query = PostSearchQuery();
      query.title = searchText.value;
      _postController.setPostSearchQuery(query: query, callback: () {});
      _usersController.setSearchTextFilter(searchText.value,(){});
      _miscController.searchHashTags(searchText.value);
      _clubsController.setSearchText(searchText.value);
    } else {
      closeSearch();
    }
  }

  segmentChanged(int index) {
    selectedSegment = index;
    searchData();
    update();
  }
}
