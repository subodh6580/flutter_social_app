// import 'package:foap/helper/imports/common_import.dart';
// import 'package:foap/helper/imports/chat_imports.dart';
//
// class ChooseMediaForChat extends StatefulWidget {
//   final Function(List<Media>) selectedMediaCompletetion;
//
//   const ChooseMediaForChat({Key? key, required this.selectedMediaCompletetion})
//       : super(key: key);
//
//   @override
//   State<ChooseMediaForChat> createState() => _ChooseMediaForChatState();
// }
//
// class _ChooseMediaForChatState extends State<ChooseMediaForChat> {
//   final SelectMediaController selectMediaController = SelectMediaController();
//
//   @override
//   void initState() {
//     // selectMediaController.loadGalleryData(context);
//     // selectMediaController.mediaCountSelected(MediaCount.single);
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     selectMediaController.clear();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: GetBuilder<SelectMediaController>(
//               init: selectMediaController,
//               builder: (ctx) {
//                 return Stack(
//                   children: [
//                     CustomGalleryPicker(
//                       mediaSelectionCompletion: (medias) {
//                         selectMediaController.mediaSelected(medias);
//                       },
//                       mediaCapturedCompletion: (media) {
//                         widget.selectedMediaCompletetion([media]);
//                       },
//                     ).round(20).p16,
//                     Obx(() {
//                       return selectMediaController.mediaList.isNotEmpty
//                           ? Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: Container(
//                                 color: AppColorConstants.themeColor,
//                                 height: 60,
//                                 width: 60,
//                                 child: const ThemeIconWidget(
//                                   ThemeIcon.send,
//                                   size: 25,
//                                 ),
//                               ).circular.p25.ripple(() {
//                                 widget.selectedMediaCompletetion(
//                                     selectMediaController.mediaList);
//                               }),
//                             )
//                           : Container();
//                     })
//                   ],
//                 );
//               }),
//         ),
//         const SizedBox(
//           height: 10,
//         ),
//         Align(
//           alignment: Alignment.center,
//           child: Container(
//             height: 50,
//             width: 50,
//             color: AppColorConstants.backgroundColor,
//             child: Center(
//               child: ThemeIconWidget(
//                 ThemeIcon.close,
//                 color: AppColorConstants.iconColor,
//                 size: 25,
//               ),
//             ),
//           ).circular.ripple(() {
//             Get.back();
//           }),
//         ),
//         const SizedBox(
//           height: 40,
//         ),
//       ],
//     );
//   }
// }
