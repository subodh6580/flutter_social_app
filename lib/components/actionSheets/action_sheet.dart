import '../../model/generic_item.dart';
import 'package:foap/helper/imports/common_import.dart';

class ActionSheet extends StatefulWidget {
  final List<GenericItem> items;
  final Function(GenericItem) itemCallBack;

  const ActionSheet({Key? key, required this.items, required this.itemCallBack})
      : super(key: key);

  @override
  ActionSheetState createState() => ActionSheetState();
}

class ActionSheetState extends State<ActionSheet> {
  late List<GenericItem> items;
  late Function(GenericItem) itemCallBack;
  GenericItem? selectedItem;

  @override
  void initState() {
    // TODO: implement initState
    items = widget.items;
    itemCallBack = widget.itemCallBack;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (items.length * 76) + 100,
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ThemeIconWidget(
                ThemeIcon.close,
                size: 20,
              ).ripple(() {
                Navigator.pop(context);
              }),
              const Spacer(),
              BodyLargeText(choosePrivacyString.tr,
                  weight:TextWeight.medium),
              const Spacer(),
              BodyLargeText(
                doneString.tr,
                weight:TextWeight.medium,
              ).ripple(() {
                if (selectedItem != null) {
                  itemCallBack(selectedItem!);
                }
                Navigator.pop(context);
              })
            ],
          ).setPadding(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 25),
          divider( height: 0.2).tP25,
          for (int i = 0; i < items.length; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                        color: AppColorConstants.backgroundColor,
                        child: ThemeIconWidget(
                          items[i].icon!,
                          color: AppColorConstants.iconColor,
                        ).p8)
                    .circular,
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyLargeText(
                        items[i].title,
                          weight: TextWeight.semiBold

                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      BodySmallText(
                        items[i].subTitle!,
                      ),
                    ],
                  ),
                ),
                // Spacer(),
                ThemeIconWidget(
                  selectedItem?.id == items[i].id
                      ? ThemeIcon.selectedRadio
                      : ThemeIcon.unSelectedRadio,
                  size: 25,
                  color: selectedItem?.id == items[i].id
                      ? AppColorConstants.themeColor
                      : AppColorConstants.iconColor,
                )
              ],
            ).p16.ripple(() {
              setState(() {
                selectedItem = items[i];
              });
              // itemCallBack(items[i]);
              // Navigator.pop(context);
            })
        ],
      ),
    ).topRounded(20);
  }
}
