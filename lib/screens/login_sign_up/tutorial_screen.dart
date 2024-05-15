import 'package:carousel_slider/carousel_slider.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/login_sign_up/auth_tab.dart';


class TutorialScreen extends StatefulWidget {
  const TutorialScreen({Key? key}) : super(key: key);

  @override
  TutorialScreenState createState() => TutorialScreenState();
}

class TutorialScreenState extends State<TutorialScreen> {
  int _current = 0;
  List<String> imgList = [
    "assets/tutorial1.jpg",
    "assets/tutorial2.jpg",
    "assets/tutorial3.jpg",
    "assets/tutorial4.jpg",
  ];

  List<String> headings = ["Post", "Chat", "Calls", "Live"];

  List<String> subHeadings = [
    "Join us and share you life experience, Post picture and videos",
    "Have conversations with friends, with text,image,video,audio,gif,stickers etc messages",
    "Audio and video to talk long with your friends and family",
    "Go live with your followers to share",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        // appBar: AppBar(
        //     backgroundColor: ColorConstants.backgroundColor,
        //     centerTitle: true,
        //     elevation: 0.0,
        //     title: Image.asset(
        //       'assets/logo.png',
        //       width: 80,
        //       height: 25,
        //     )),
        body: Column(children: [
          Expanded(
            child: CarouselSlider(
              items: addImages(),
              options: CarouselOptions(
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  height: double.infinity,
                  viewportFraction: 1,
                  // height: Get.height / 1.5,
                  // aspectRatio: 0.7,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imgList.map((url) {
              int index = imgList.indexOf(url);
              return Container(
                width: 8.0,
                height: 8.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == index
                      ? AppColorConstants.themeColor
                      : AppColorConstants.dividerColor,
                ),
              );
            }).toList(),
          ),
          Heading5Text(
            headings[_current],
            textAlign: TextAlign.center,
            weight: TextWeight.bold,
            color: AppColorConstants.themeColor,
          ).setPadding(left: 50, right: 50),
          const SizedBox(
            height: 16,
          ),
          BodyLargeText(
            subHeadings[_current],
            textAlign: TextAlign.center,
          ).setPadding(left: 25, right: 25),
          const SizedBox(
            height: 52,
          ),
          addActionBtn(),
          const SizedBox(
            height: 56,
          ),
        ]));
  }

  List<Widget> addImages() {
    return imgList
        .map((item) => SizedBox(
              height: double.infinity,
              child: Image.asset(
                item,
                fit: BoxFit.cover,
                width: 1000.0,
                height: double.infinity,
              ),
            ))
        .toList();
  }

  addActionBtn() {
    return AppThemeButton(
      onPress: () {
        Get.to(() => const AuthTab());
      },
      text: signUpString.tr,

    ).hP25;
  }
}
