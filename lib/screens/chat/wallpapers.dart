import 'package:foap/helper/imports/common_import.dart';

import '../../util/shared_prefs.dart';

class WallpaperForChatBackground extends StatefulWidget {
  final int roomId;

  const WallpaperForChatBackground({Key? key, required this.roomId})
      : super(key: key);

  @override
  State<WallpaperForChatBackground> createState() =>
      _WallpaperForChatBackgroundState();
}

class _WallpaperForChatBackgroundState
    extends State<WallpaperForChatBackground> {
  String currentWallpaper = '';

  List<String> wallpapers = [
    'assets/chatbg/chatbg1.jpg',
    'assets/chatbg/chatbg2.jpg',
    'assets/chatbg/chatbg3.jpg',
    'assets/chatbg/chatbg4.jpg',
    'assets/chatbg/chatbg5.jpg',
    'assets/chatbg/chatbg6.jpg',
    'assets/chatbg/chatbg7.jpg',
    'assets/chatbg/chatbg8.jpg',
    'assets/chatbg/chatbg9.jpg',
    'assets/chatbg/chatbg10.jpg',
    'assets/chatbg/chatbg11.jpg',
    'assets/chatbg/chatbg12.jpg',
    'assets/chatbg/chatbg13.jpg',
  ];

  @override
  void initState() {
    super.initState();
    getCurrentWallpaper();
  }

  getCurrentWallpaper() async {
    currentWallpaper =
        await SharedPrefs().getWallpaper(roomId: widget.roomId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [

        backNavigationBar(
             title: wallpaperString.tr),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 0.6,
                    crossAxisCount: 3),
                itemCount: wallpapers.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Image.asset(
                        wallpapers[index],
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                      currentWallpaper == wallpapers[index]
                          ? Positioned(
                              child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              color: Colors.black38,
                              child: const ThemeIconWidget(
                                ThemeIcon.checkMark,
                                size: 50,
                                color: Colors.white,
                              ),
                            ))
                          : Container()
                    ],
                  ).round(5).ripple(() {
                    currentWallpaper = wallpapers[index];
                    SharedPrefs().setWallpaper(
                        roomId: widget.roomId,
                        wallpaper: wallpapers[index]);

                    setState(() {});
                  });
                }).hp(DesignConstants.horizontalPadding),
          )
        ],
      ),
    );
  }
}
