import 'package:foap/controllers/post/watch_videos_controller.dart';
import 'package:foap/screens/reuseable_widgets/post_list.dart';
import '../../helper/imports/common_import.dart';

class WatchVideos extends StatefulWidget {
  const WatchVideos({Key? key}) : super(key: key);

  @override
  State<WatchVideos> createState() => _WatchVideosState();
}

class _WatchVideosState extends State<WatchVideos> {
  @override
  void initState() {
    Get.put(WatchVideosController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          titleNavigationBar(title: videosString),
          Expanded(
            child: PostList(
              postSource: PostSource.videos,
            ),
          ),
        ],
      ),
    );
  }
}
