import 'package:foap/helper/imports/common_import.dart';

class ProfilePictureWithName extends StatelessWidget {
  final UserModel user;

  const ProfilePictureWithName({Key? key, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AspectRatio(
                  aspectRatio: 1,
                  // height: 56,
                  // width: 56,
                  child: user.picture != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(21.0),
                          child: CachedNetworkImage(
                            imageUrl: user.picture!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                AppUtil.addProgressIndicator(size: 50),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ))
                      : Icon(Icons.person, color: AppColorConstants.themeColor))
              .borderWithRadius(
                  value: 2, radius: 30, color: AppColorConstants.themeColor),
        ),
        BodyMediumText(
          user.userName,
          color: AppColorConstants.themeColor,
        ).vP8
      ],
    );
  }
}
