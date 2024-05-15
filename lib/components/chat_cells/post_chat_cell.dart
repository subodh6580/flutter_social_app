import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../apiHandler/apis/post_api.dart';
import '../../model/post_model.dart';

class PostChatTile extends StatelessWidget {
  final ChatMessageModel message;

  const PostChatTile({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 350,
        width: double.infinity,
        child: Container(
          color: message.isMineMessage
              ? AppColorConstants.disabledColor
              : AppColorConstants.themeColor.withOpacity(0.2),
          child: FutureBuilder<PostModel?>(
              future: getPostDetail(message.postContent.postId),
              builder:
                  (BuildContext context, AsyncSnapshot<PostModel?> snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data == null
                      ? Center(
                          child: Heading5Text(postDeletedString.tr,
                              weight: TextWeight.bold,
                              color: AppColorConstants.themeColor),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                AvatarView(
                                  url: snapshot.data!.user.picture,
                                  name: snapshot.data!.user.userName,
                                  size: 25,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                BodyLargeText(
                                  snapshot.data!.user.userName,
                                  weight: TextWeight.medium,
                                ),
                              ],
                            ).hP8,
                            const SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: Stack(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot
                                          .data!.gallery.first.thumbnail,
                                      httpHeaders: const {'accept': 'image/*'},
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          AppUtil.addProgressIndicator(
                                              size: 100),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                  snapshot.data!.gallery.first.isVideoPost
                                      ? Container(
                                          color: Colors.black26,
                                          height: 280,
                                          width: double.infinity,
                                        ).round(15)
                                      : Container()
                                ],
                              ),
                            ),
                          ],
                        );
                } else {
                  if (snapshot.data == null &&
                      snapshot.connectionState == ConnectionState.done) {
                    return Center(
                        child: Heading3Text(
                      postDeletedString.tr,
                      color: AppColorConstants.themeColor,
                      weight: TextWeight.bold,
                    ));
                  } else {
                    return AppUtil.addProgressIndicator(size: 100);
                  }
                }
              }),
        ).round(15));
  }

  Future<PostModel?> getPostDetail(int postId) async {
    PostModel? post;
    await PostApi.getPostDetail(postId, resultCallback: (result) {
      post = result;
    });
    return post;
  }
}

class MinimalInfoPostChatTile extends StatelessWidget {
  final ChatMessageModel message;

  const MinimalInfoPostChatTile({Key? key, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 350,
        width: double.infinity,
        child: Container(
          color: message.isMineMessage
              ? AppColorConstants.disabledColor
              : AppColorConstants.themeColor.withOpacity(0.2),
          child: FutureBuilder<PostModel?>(
              future: getPostDetail(message.postContent.postId),
              builder:
                  (BuildContext context, AsyncSnapshot<PostModel?> snapshot) {
                if (snapshot.hasData) {
                  return Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: snapshot.data!.gallery.first.thumbnail,
                          httpHeaders: const {'accept': 'image/*'},
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              AppUtil.addProgressIndicator(size: 100),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      snapshot.data!.gallery.first.isVideoPost
                          ? Container(
                              color: Colors.black26,
                              height: 280,
                              width: double.infinity,
                            ).round(15)
                          : Container()
                    ],
                  );
                } else {
                  if (snapshot.data == null &&
                      snapshot.connectionState == ConnectionState.done) {
                    return Center(
                      child: Heading5Text(
                        postDeletedString.tr,
                        weight: TextWeight.bold,
                        color: AppColorConstants.themeColor,
                      ),
                    );
                  } else {
                    return AppUtil.addProgressIndicator(size: 100);
                  }
                }
              }),
        ).round(15));
  }

  Future<PostModel?> getPostDetail(int postId) async {
    PostModel? post;
    await PostApi.getPostDetail(postId, resultCallback: (result) {
      post = result;
    });

    return post;
  }
}
