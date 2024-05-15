import '../helper/imports/common_import.dart';

class MediaCard extends StatelessWidget {
  final MediaModel model;

  const MediaCard({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: AppColorConstants.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CachedNetworkImage(
            imageUrl: model.image ?? '',
            fit: BoxFit.cover,
            height: 110,
          ).round(12),
          BodySmallText(model.name ?? '',
                  maxLines: 1, weight: TextWeight.regular)
              .setPadding(top: 12, bottom: 6),
          BodySmallText(
            model.showTime ?? '',
            weight: TextWeight.semiBold,
            color: AppColorConstants.themeColor,
          ),
        ],
      ).p(12),
    ).round(15);
  }
}

class MediaModel {
  String? name;
  String? image;
  String? showTime;

  MediaModel(this.name, this.image, this.showTime);
}
