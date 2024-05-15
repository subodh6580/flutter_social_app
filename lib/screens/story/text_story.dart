// import 'package:get/get.dart';
// import 'package:foap/helper/imports/common_import.dart';
//
// class TextStoryMaker extends StatefulWidget {
//   const TextStoryMaker({Key? key}) : super(key: key);
//
//   @override
//   State<TextStoryMaker> createState() => _TextStoryMakerState();
// }
//
// class _TextStoryMakerState extends State<TextStoryMaker> {
//   final TextStoryMakerController _textStoryMakerController =
//       TextStoryMakerController();
//   final TextEditingController inputText = TextEditingController();
//
//   List<Font> fontsList = [
//     Font.lato,
//     Font.openSans,
//     Font.poppins,
//     Font.raleway,
//     Font.roboto
//   ];
//
//   List<Color> colorsList = [
//     const Color(0xffffffff),
//     const Color(0xff000000),
//     const Color(0xffecf0f1),
//     const Color(0xff9b59b6),
//     const Color(0xff2980b9),
//     const Color(0xffe74c3c),
//     const Color(0xffd35400),
//     const Color(0xff95a5a6),
//     const Color(0xff7f8c8d),
//     const Color(0xff2c3e50),
//     const Color(0xff1abc9c),
//     const Color(0xfff1c40f),
//     const Color(0xff192a56),
//     const Color(0xff8c7ae6),
//   ];
//
//   @override
//   void initState() {
//     // TODO: implement initState
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     _textStoryMakerController.setBackgroundColor(Colors.black);
//     _textStoryMakerController.setStrokeColor(Colors.white);
//
//     return Obx(() => AppScaffold(
//           backgroundColor:
//               _textStoryMakerController.selectedBackgroundColor.value ??
//                   ColorConstants.backgroundColor,
//           body: Stack(
//             children: [
//               Obx(() {
//                 return SizedBox(
//                   height: Get.height,
//                   width: Get.width,
//                   child: Center(
//                       child: TextField(
//                     controller: inputText,
//                     textAlign: TextAlign.center,
//                     textAlignVertical: TextAlignVertical.center,
//                     onChanged: (value) {
//                       _textStoryMakerController.textChanged(value);
//                     },
//                     style: TextStyle(
//                         color:
//                             _textStoryMakerController.selectedStrokeColor.value,
//                         fontFamily: _textStoryMakerController.fontName.value,
//                         fontSize: _textStoryMakerController
//                                     .inputText.value.length <
//                                 100
//                             ? 35
//                             : _textStoryMakerController.inputText.value.length <
//                                     200
//                                 ? 30
//                                 : _textStoryMakerController
//                                             .inputText.value.length <
//                                         400
//                                     ? 25
//                                     : 20),
//                     maxLines: null,
//                     maxLength: 500,
//                     decoration: InputDecoration(
//                       floatingLabelBehavior: FloatingLabelBehavior.never,
//                       border: InputBorder.none,
//                       contentPadding:
//                           const EdgeInsets.only(left: 10, right: 10),
//                       counterText: "",
//                       hintText: enterTextHere,
//                       // labelText: hintText,
//                       labelStyle: TextStyle(fontSize: FontSizes.b2),
//                       hintStyle: TextStyle(fontSize: FontSizes.h3),
//                     ),
//                   )),
//                 );
//               }),
//               Positioned(
//                   left: DesignConstants.horizontalPadding,
//                   top: 60,
//                   right: DesignConstants.horizontalPadding,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         height: 30,
//                         width: 30,
//                         color: ColorConstants.themeColor,
//                         child: ThemeIconWidget(
//                           ThemeIcon.close,
//                           size: 20,
//                         ),
//                       ).circular.ripple(() {
//                         Get.back();
//                       }),
//                       Container(
//                         height: 30,
//                         width: 30,
//                         color: ColorConstants.themeColor,
//                         child: ThemeIconWidget(
//                           ThemeIcon.send,
//                           size: 20,
//                         ),
//                       ).circular.ripple(() {
//                         _textStoryMakerController.postTextStory(
//                             text: inputText.text,
//                             backgroundColor: _textStoryMakerController
//                                 .selectedBackgroundColor.value!
//                                 .toHex());
//                         Get.back();
//                       }),
//                     ],
//                   )),
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 20,
//                 child: Column(
//                   children: [
//                     _buildFontToolbar(),
//                     const SizedBox(
//                       height: 15,
//                     ),
//                     _buildStrokeColorToolbar(),
//                     const SizedBox(
//                       height: 15,
//                     ),
//                     _buildBackgroundColorToolbar()
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ));
//   }
//
//   Widget _buildFontToolbar() {
//     return SizedBox(
//       height: 30,
//       child: ListView.separated(
//         padding: const EdgeInsets.only(left: DesignConstants.horizontalPadding),
//         itemCount: fontsList.length,
//         scrollDirection: Axis.horizontal,
//         itemBuilder: (ctx, index) {
//           return Obx(() {
//             return Container(
//               color: _textStoryMakerController.fontName.value ==
//                       fontName(fontsList[index])
//                   ? ColorConstants.themeColor
//                   : Colors.white,
//               child: Center(
//                 child: Text(
//                   'Hello',
//                   style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.black,
//                       fontFamily: fontName(fontsList[index])),
//                 ).setPadding(left: 5, right: 5, top: 2, bottom: 2),
//               ),
//             )
//                 .borderWithRadius( value: 1, radius: 5)
//                 .ripple(() {
//               _textStoryMakerController.setFont(fontsList[index]);
//             });
//           });
//         },
//         separatorBuilder: (ctx, index) {
//           return const SizedBox(
//             width: 15,
//           );
//         },
//       ),
//     );
//   }
//
//   String fontName(Font font) {
//     switch (font) {
//       case Font.roboto:
//         return 'Roboto';
//       case Font.raleway:
//         return 'Raleway';
//       case Font.poppins:
//         return 'Poppins';
//       case Font.openSans:
//         return 'OpenSans';
//       case Font.lato:
//         return 'Lato';
//     }
//   }
//
//   Widget _buildStrokeColorToolbar() {
//     return Row(
//       children: [
//         Container(
//           height: 30,
//           width: 30,
//           color: ColorConstants.backgroundColor,
//           child: ThemeIconWidget(ThemeIcon.edit),
//         ).borderWithRadius( value: 5, radius: 1).lP16,
//         SizedBox(
//           width: Get.width - 80,
//           height: 50,
//           child: ListView.builder(
//               padding: const EdgeInsets.only(left: DesignConstants.horizontalPadding),
//               itemCount: 10,
//               scrollDirection: Axis.horizontal,
//               itemBuilder: (ctx, index) {
//                 return _buildStrokeColorButton(context,
//                     color: colorsList[index]);
//               }),
//         )
//       ],
//     );
//   }
//
//   Widget _buildBackgroundColorToolbar() {
//     return Row(
//       children: [
//         Container(
//           height: 30,
//           width: 30,
//           color: Colors.white,
//         ).borderWithRadius( value: 5, radius: 1).lP16,
//         SizedBox(
//           width: Get.width - 80,
//           height: 50,
//           child: ListView.builder(
//               padding: const EdgeInsets.only(left: DesignConstants.horizontalPadding),
//               itemCount: 10,
//               scrollDirection: Axis.horizontal,
//               itemBuilder: (ctx, index) {
//                 return _buildBackgroundColorButton(context,
//                     color: colorsList[index]);
//               }),
//         )
//       ],
//     );
//   }
//
//   Widget _buildStrokeColorButton(
//     BuildContext context, {
//     required Color color,
//   }) {
//     return Obx(() => Container(
//           height: 40,
//           width: _textStoryMakerController.selectedStrokeColor.value == color
//               ? 30
//               : 40,
//           color: color,
//         ).border(
//
//             value: _textStoryMakerController.selectedStrokeColor.value == color
//                 ? 5
//                 : 0,
//             color: ColorConstants.themeColor)).ripple(() {
//       _textStoryMakerController.setStrokeColor(color);
//     });
//   }
//
//   Widget _buildBackgroundColorButton(
//     BuildContext context, {
//     required Color color,
//   }) {
//     return Obx(() => Container(
//           width:
//               _textStoryMakerController.selectedBackgroundColor.value == color
//                   ? 30
//                   : 40,
//           height: 40,
//           color: color,
//         ).border(
//
//             value:
//                 _textStoryMakerController.selectedBackgroundColor.value == color
//                     ? 5
//                     : 0,
//             color: ColorConstants.themeColor)).ripple(() {
//       _textStoryMakerController.setBackgroundColor(color);
//     });
//   }
// }
