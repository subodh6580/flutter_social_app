import 'package:foap/helper/imports/common_import.dart';

import '../../controllers/misc/faq_controller.dart';

class FaqList extends StatefulWidget {
  const FaqList({Key? key}) : super(key: key);

  @override
  State<FaqList> createState() => _FaqListState();
}

class _FaqListState extends State<FaqList> {
  final FAQController _faqController = FAQController();

  @override
  void initState() {
    _faqController.loadFAQs();
    super.initState();
  }

  @override
  void dispose() {
    // _faqController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: faqString.tr),
          Expanded(
              child: Obx(
            () => ListView.builder(
                padding: const EdgeInsets.only(bottom: 50),
                itemCount: _faqController.faqs.length,
                itemBuilder: (ctx, index) {
                  return ExpansionTile(
                    title: BodyLargeText(
                      _faqController.faqs[index].question,
                      weight: TextWeight.bold,
                    ),
                    children: <Widget>[
                      ListTile(
                          title: BodyLargeText(
                        _faqController.faqs[index].answer,
                      )),
                    ],
                    onExpansionChanged: (bool expanded) {},
                  );
                }),
          ))
        ],
      ),
    );
  }
}
