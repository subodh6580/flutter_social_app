import 'package:foap/components/thumbnail_view.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/story_imports.dart';

double storyCircleSize = 50;

class StoryUpdatesBar extends StatelessWidget {
  final List<StoryModel> stories;
  final List<UserModel> liveUsers;

  final VoidCallback addStoryCallback;
  final Function(StoryModel) viewStoryCallback;
  final Function(UserModel) joinLiveUserCallback;

  const StoryUpdatesBar({
    Key? key,
    required this.stories,
    required this.liveUsers,
    required this.addStoryCallback,
    required this.viewStoryCallback,
    required this.joinLiveUserCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
          left: DesignConstants.horizontalPadding,
          right: DesignConstants.horizontalPadding),
      scrollDirection: Axis.horizontal,
      itemCount: stories.length + liveUsers.length + 1,
      itemBuilder: (BuildContext ctx, int index) {
        if (index == 0) {
          return SizedBox(
            width: storyCircleSize + 20,
            child: Column(
              children: [
                SizedBox(
                  height: storyCircleSize,
                  width: storyCircleSize,
                  child: ThemeIconWidget(
                    ThemeIcon.plus,
                    size: 28,
                    color: AppColorConstants.themeColor.darken(),
                  ),
                ).borderWithRadius(value: 2, radius: 50).ripple(() {
                  addStoryCallback();
                }),
                const SizedBox(
                  height: 5,
                ),
                BodySmallText(yourStoryString.tr, weight: TextWeight.medium)
              ],
            ),
          );
        } else {
          if (index <= liveUsers.length) {
            return SizedBox(
                width: 100,
                child: Column(
                  children: [
                    UserAvatarView(
                      size: storyCircleSize,
                      user: liveUsers[index - 1],
                      onTapHandler: () {
                        joinLiveUserCallback(liveUsers[index - 1]);
                      },
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Expanded(
                        child: BodySmallText(liveUsers[index - 1].userName,
                                maxLines: 1, weight: TextWeight.medium)
                            .hP4)
                  ],
                ));
          } else {
            return SizedBox(
                width: storyCircleSize + 20,
                child: Column(
                  children: [
                    MediaThumbnailView(
                      borderColor:
                          stories[index - liveUsers.length - 1].isViewed == true
                              ? AppColorConstants.disabledColor
                              : AppColorConstants.themeColor,
                      media: stories[index - liveUsers.length - 1].media.last,
                    ).ripple(() {
                      viewStoryCallback(stories[index - liveUsers.length - 1]);
                    }).ripple(() {
                      viewStoryCallback(stories[index - liveUsers.length - 1]);
                    }),
                    const SizedBox(
                      height: 4,
                    ),
                    Expanded(
                      child: BodySmallText(
                              stories[index - liveUsers.length - 1].userName,
                              maxLines: 1,
                              weight: TextWeight.medium)
                          .hP4,
                    ),
                  ],
                ));
          }
        }
      },
    );
  }
}
