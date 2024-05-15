import 'dart:ui';
import 'package:foap/helper/imports/common_import.dart';


class LeaveDialog extends StatefulWidget {
  final String title;
  final String yesText;
  final String noText;
  final Function onYesAction;

  const LeaveDialog(
      {Key? key, required this.title,
        required this.yesText,
        required this.noText,
        required this.onYesAction}) : super(key:key);

  @override
  State<LeaveDialog> createState() => _LeaveDialogState();
}

class _LeaveDialogState extends State<LeaveDialog> {
  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: _getDialogLayout(context),
      ),
    ),
  );

  _getDialogLayout(BuildContext context) => SingleChildScrollView(
    child: Wrap(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              width: MediaQuery.of(context).size.width * 0.85,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  BodyLargeText(
                    widget.title,
                    color:AppColorConstants.themeColor,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                      color: AppColorConstants.themeColor,

                      child: Text(
                        widget.yesText,
                        style: const TextStyle(color: Colors.white),
                      )).ripple((){
                    dismissAlertDialog(context);

                    widget.onYesAction();
                  }),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    color: AppColorConstants.themeColor,

                    child: Text(widget.noText),
                  ).ripple((){
                    dismissAlertDialog(context);
                  }),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void dismissAlertDialog(BuildContext context) {
  Get.back();
}

Future<dynamic> showCallLeaveDialog(BuildContext context, String title,
    String yesText, String noText, Function onYesAction) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return LeaveDialog(
        title: title,
        yesText: yesText,
        noText: noText,
        onYesAction: onYesAction,
      );
    },
  );
}
