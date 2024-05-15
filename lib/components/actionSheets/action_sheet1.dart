import 'package:foap/helper/imports/common_import.dart';

import '../../model/generic_item.dart';

class ActionSheet1 extends StatelessWidget {
  final List<GenericItem> items;
  final Function(GenericItem) itemCallBack;

  const ActionSheet1(
      {Key? key, required this.items, required this.itemCallBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: items.length * 60,
      color: AppColorConstants.cardColor.darken(),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++)
            Row(
              children: <Widget>[
                items[i].icon != null
                    ? ThemeIconWidget(
                        items[i].icon!,
                        color: AppColorConstants.iconColor,
                      )
                    : Container(),
                const SizedBox(width: 20),
                Heading6Text(
                  items[i].title,
                  weight: TextWeight.medium,

                )
              ],
            ).p16.ripple(() {
              Navigator.pop(context);
              itemCallBack(items[i]);
            })
        ],
      ),
    ).topRounded(20);
  }
}
