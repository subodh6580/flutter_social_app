import 'package:foap/screens/reuseable_widgets/post_list.dart';
import '../../helper/imports/common_import.dart';
import 'package:foap/controllers/post/saved_post_controller.dart';

class SavedPosts extends StatefulWidget {
  const SavedPosts({Key? key}) : super(key: key);

  @override
  State<SavedPosts> createState() => _SavedPostsState();
}

class _SavedPostsState extends State<SavedPosts> {

  @override
  void initState() {
    Get.put(SavedPostController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: savedPostsString),
          Expanded(
            child: PostList(
              postSource: PostSource.saved,
            ),
          ),
        ],
      ),
    );
  }
}
