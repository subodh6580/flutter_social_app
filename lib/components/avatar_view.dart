import 'package:foap/helper/imports/common_import.dart';

class AvatarView extends StatelessWidget {
  final String? url;
  final String? name;

  final double? size;
  final Color? borderColor;

  const AvatarView(
      {Key? key,
      required this.url,
      this.size = 60,
      this.borderColor,
      this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String initials = '';

    if (name != null) {
      List<String> nameParts = name!.trim().split(' ');
      initials = '';
      for (var part in nameParts) {
        initials += part.substring(0, 1).toUpperCase();
        if (initials.length >= 2) {
          break;
        }
      }
    }

    return SizedBox(
      height: size ?? 60,
      width: size ?? 60,
      child: url != null && (url ?? '').isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url!,
              fit: BoxFit.cover,
              placeholder: (context, url) => SizedBox(
                  height: 20,
                  width: 20,
                  child: const CircularProgressIndicator().p16),
              errorWidget: (context, url, error) => const Icon(
                Icons.error,
              ),
            ).round(18)
          : Center(
              child: BodySmallText(initials, weight: TextWeight.medium).p8,
            ),
    ).borderWithRadius(
        value: 2,
        radius: 20,
        color: borderColor ?? AppColorConstants.themeColor);
  }
}

class UserAvatarView extends StatelessWidget {
  final UserModel user;
  final double? size;
  final VoidCallback? onTapHandler;
  final bool hideLiveIndicator;
  final bool hideOnlineIndicator;
  final bool hideBorder;

  const UserAvatarView(
      {Key? key,
      required this.user,
      this.size = 60,
      this.onTapHandler,
      this.hideLiveIndicator = false,
      this.hideOnlineIndicator = false,
      this.hideBorder = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size ?? 60,
      width: size ?? 60,
      child: Stack(
        children: [
          user.liveCallDetail != null && hideLiveIndicator == false
              ? liveUserWidget(
                  size: size ?? 60,
                ).ripple(() {
                  if (onTapHandler != null) {
                    onTapHandler!();
                  }
                })
              : userPictureView(
                  size: size ?? 60,
                ),
          (user.liveCallDetail == null || hideLiveIndicator == true) &&
                  hideOnlineIndicator == false
              ? Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 15,
                    width: 15,
                    color: user.isOnline == true
                        ? AppColorConstants.themeColor
                        : Colors.transparent,
                  ).circular)
              : Container(),
        ],
      ),
    );
  }

  Widget userPictureView({
    required double size,
    double? radius,
  }) {
    return user.picture != null && user.picture != 'null'
        ? CachedNetworkImage(
            imageUrl: user.picture!,
            fit: BoxFit.cover,
            height: size,
            width: size,
            placeholder: (context, url) => SizedBox(
                height: 20,
                width: 20,
                child: const CircularProgressIndicator().p16),
            errorWidget: (context, url, error) => SizedBox(
                height: size,
                width: size,
                child: Icon(
                  Icons.error,
                  size: size / 2,
                )),
          ).borderWithRadius(
            value: hideBorder ? 0 : 1,
            radius: 100,
            color: AppColorConstants.themeColor)
        : SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Center(
              child: BodySmallText(
                user.getInitials,
                weight: TextWeight.medium,
              ),
            ),
          ).borderWithRadius(
            value: hideBorder ? 0 : 1,
            radius: 100,
            color: AppColorConstants.themeColor);
  }

  Widget liveUserWidget({
    required double size,
  }) {
    return Stack(
      children: [
        userPictureView(size: size, radius: 5),
        Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: Container(
              height: 18,
              color: AppColorConstants.themeColor,
              child: Center(
                child: BodyMediumText(
                  liveString.tr,
                ),
              ),
            ).round(5))
      ],
    );
  }
}
