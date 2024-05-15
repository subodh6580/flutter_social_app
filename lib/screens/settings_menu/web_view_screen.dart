// import 'dart:io';
// import 'package:foap/helper/imports/common_import.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:get/get.dart';
//
// class WebViewScreen extends StatefulWidget {
//   final String header;
//   final String url;
//
//   const WebViewScreen({Key? key, required this.header, required this.url})
//       : super(key: key);
//
//   @override
//   State<WebViewScreen> createState() => _WebViewState();
// }
//
// class _WebViewState extends State<WebViewScreen> {
//   late final String header;
//   late final String url;
//
//   @override
//   void initState() {
//     super.initState();
//     header = widget.header;
//     url = widget.url;
//     // Enable hybrid composition.
//     if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: AppColorConstants.backgroundColor,
//         appBar: AppBar(
//             backgroundColor: AppColorConstants.themeColor,
//             centerTitle: true,
//             elevation: 0.0,
//             title: Heading5Text(
//               header,
//               color: AppColorConstants.subHeadingTextColor,
//             ),
//             leading: InkWell(
//                 onTap: () => Get.back(),
//                 child: const Icon(Icons.arrow_back_ios_rounded,
//                     color: Colors.white))),
//         body: WebView(
//           initialUrl: url,
//         ));
//   }
// }
