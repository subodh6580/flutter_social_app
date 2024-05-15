import '../../components/highlights_bar.dart';
import '../../components/post_card.dart';
import '../../controllers/story/highlights_controller.dart';
import '../../controllers/profile/profile_controller.dart';
import '../../helper/imports/common_import.dart';
import '../../model/post_model.dart';
import '../dashboard/mentions.dart';
import '../highlights/choose_stories.dart';
import '../highlights/hightlights_viewer.dart';

class HighlightsView extends StatelessWidget {
  final HighlightsController _highlightsController = Get.find();

  HighlightsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HighlightsController>(
        init: _highlightsController,
        builder: (ctx) {
          return _highlightsController.isLoading == true
              ? const StoryAndHighlightsShimmer()
              : HighlightsBar(
                  highlights: _highlightsController.highlights,
                  addHighlightCallback: () {
                    Get.to(() => const ChooseStoryForHighlights());
                  },
                  viewHighlightCallback: (highlight) {
                    Get.to(() => HighlightViewer(highlight: highlight))!
                        .then((value) {
                      //loadData();
                    });
                  },
                );
        });
  }
}

class MentionsList extends StatelessWidget {
  final ProfileController _profileController = Get.find();

  MentionsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GetBuilder<ProfileController>(
          init: _profileController,
          builder: (ctx) {
            ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.maxScrollExtent ==
                  scrollController.position.pixels) {
                _profileController
                    .getMentionPosts(_profileController.user.value!.id);
              }
            });

            List<PostModel> posts = _profileController.mentions;

            return _profileController.isLoadingPosts
                ? const PostBoxShimmer()
                : ListView.builder(
                    controller: scrollController,
                    itemCount: posts.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    // You won't see infinite size error
                    // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: 3,
                    //     crossAxisSpacing: 8.0,
                    //     mainAxisSpacing: 8.0,
                    //     mainAxisExtent: 100),
                    itemBuilder: (BuildContext context, int index) => PostCard(
                      model: posts[index],
                      removePostHandler: () {},
                      blockUserHandler: () {},
                    ).ripple(() {
                      Get.to(() => Mentions(
                          posts: List.from(posts),
                          index: index,
                          userId: _profileController.user.value!.id,
                          page: _profileController.mentionsPostPage,
                          totalPages: _profileController.totalPages));
                    }),
                  ).hp(DesignConstants.horizontalPadding);
          }),
    );
  }
}
