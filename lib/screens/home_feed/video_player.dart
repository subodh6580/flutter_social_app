// import 'package:foap/helper/common_import.dart';
//
// class VideoPlayerScreen extends StatefulWidget {
//   final String url;
//
//   const VideoPlayerScreen({Key? key, required this.url}): super(key: key);
//
//   @override
//   VideoPlayerScreenState createState() => VideoPlayerScreenState();
// }
//
// class VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late FlickManager flickManager;
//   late String url;
//
//   @override
//   void initState() {
//
//     super.initState();
//     url = widget.url;
//
//     flickManager = FlickManager(
//       videoPlayerController:
//       VideoPlayerController.network(url),
//     );
//   }
//
//   @override
//   void dispose() {
//     flickManager.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//             backgroundColor: Colors.black,
//             centerTitle: true,
//             elevation: 0.0,
//             ),
//         body: Column(children: [
//           FlickVideoPlayer(flickManager: flickManager),
//           const Spacer(),
//         ]));
//   }
// }
