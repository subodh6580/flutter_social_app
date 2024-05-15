import 'package:foap/helper/imports/common_import.dart';
import '../../components/post_card.dart';
import '../../controllers/post/single_post_detail_controller.dart';

class SinglePostDetail extends StatefulWidget {
  final int postId;

  const SinglePostDetail({Key? key, required this.postId}) : super(key: key);

  @override
  State<SinglePostDetail> createState() => _SinglePostDetailState();
}

class _SinglePostDetailState extends State<SinglePostDetail> {
  final SinglePostDetailController singlePostDetailController =
      SinglePostDetailController();

  @override
  void initState() {
    singlePostDetailController.getPostDetail(widget.postId);
    super.initState();
  }

  @override
  void dispose() {
    singlePostDetailController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: postString.tr),
          const SizedBox(
            height: 8,
          ),
          const SizedBox(
            height: 20,
          ),
          GetBuilder<SinglePostDetailController>(
              init: singlePostDetailController,
              builder: (ctx) {
                return singlePostDetailController.post.value == null &&
                        singlePostDetailController.isLoading == false
                    ? Center(
                        child: Heading3Text(
                          postDeletedString.tr,
                          weight: TextWeight.bold,
                          color: AppColorConstants.themeColor,
                        ),
                      )
                    : singlePostDetailController.isLoading == false
                        ? PostCard(
                            model: singlePostDetailController.post.value!,
                            removePostHandler: () {
                              Get.back();
                            },
                            blockUserHandler: () {
                              Get.back();
                            }
                            // mediaTapHandler: (post) {
                            //   Get.to(() => PostMediaFullScreen(post: post));
                            // },
                            )
                        : Container();
              }),
        ],
      ),
    );
  }
}
