import 'package:foap/components/smart_text_field.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/hashtag_tile.dart';
import '../../helper/imports/common_import.dart';

class TagHashtagView extends StatelessWidget {
  TagHashtagView({
    Key? key,
  }) : super(key: key);

  final SmartTextFieldController _smartTextFieldController = Get.find();

  final RefreshController _hashtagRefreshController =
  RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
      padding: EdgeInsets.only(
          left: DesignConstants.horizontalPadding,
          right: DesignConstants.horizontalPadding),
      itemCount: _smartTextFieldController.hashTags.length,
      itemBuilder: (BuildContext ctx, int index) {
        return HashTagTile(
          hashtag: _smartTextFieldController.hashTags[index],
          onItemCallback: () {
            _smartTextFieldController
                .addHashTag(_smartTextFieldController.hashTags[index].name);
          },
        );
      },
    ).addPullToRefresh(
        refreshController: _hashtagRefreshController,
        onRefresh: () {},
        onLoading: () {
          _smartTextFieldController.searchHashTags(
              text: _smartTextFieldController.currentHashtag.value,
              callBackHandler: () {
                _hashtagRefreshController.loadComplete();
              });
        },
        enablePullUp: true,
        enablePullDown: false));
  }
}
