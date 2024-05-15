import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import '../../util/constant_util.dart';

class DrawingScreen extends StatefulWidget {
  final Function(Media)? drawingCompleted;

  const DrawingScreen({Key? key, this.drawingCompleted}) : super(key: key);

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final DrawingController _drawingController = DrawingController();
  final ChatDetailController _chatDetailController = Get.find();
  final DrawingBoardController _drawingBoardController =
  DrawingBoardController();
  late String filePath;

  List<Color> colorsList = [
    const Color(0xffffffff),
    const Color(0xff000000),
    const Color(0xffecf0f1),
    const Color(0xff9b59b6),
    const Color(0xff2980b9),
    const Color(0xffe74c3c),
    const Color(0xffd35400),
    const Color(0xff95a5a6),
    const Color(0xff7f8c8d),
    const Color(0xff2c3e50),
    const Color(0xff1abc9c),
    const Color(0xfff1c40f),
    const Color(0xff192a56),
    const Color(0xff8c7ae6),
  ];

  @override
  void initState() {
    initiatePath();
    super.initState();
  }

  initiatePath() async {
    Directory directory = await getTemporaryDirectory();
    filePath = '${directory.path}/drawing.png';
    File file = File(filePath);
    // print(filePath);
    if (file.existsSync()) {
      // print('deleted');
      file.delete();
    }
  }

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Obx(() => DrawingBoard(
              controller: _drawingController,
              background: Container(
                  width: Get.width,
                  height: Get.height,
                  // height: double.infinity,
                  color: _drawingBoardController
                      .selectedBackgroundColor.value),
            )),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildActionsToolBar(),
              const SizedBox(
                height: 10,
              ),
              _buildStrokeColorToolbar(context),
              const SizedBox(
                height: 10,
              ),
              _buildBackgroundColorToolbar(context),
              const SizedBox(
                height: 10,
              ),
              _buildStrokeToolbar(context),
            ],
          ).hp(DesignConstants.horizontalPadding),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  Widget _buildStrokeToolbar(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final w in [2, 4, 6, 8, 10, 12, 14, 16, 18, 20])
          _buildStrokeButton(
            context,
            strokeWidth: w.toDouble(),
          ),
      ],
    );
  }

  Widget _buildStrokeButton(
      BuildContext context, {
        required double strokeWidth,
      }) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: InkWell(
        onTap: () {
          _drawingController.setStyle(strokeWidth: strokeWidth);
          _drawingBoardController.setStrokeWidth(strokeWidth);
        },
        customBorder: const CircleBorder(),
        child: Obx(() => AnimatedContainer(
          duration: kThemeAnimationDuration,
          width: strokeWidth * 2,
          height: strokeWidth * 2,
          color: Colors.black,
        ).borderWithRadius(
            value: _drawingBoardController.selectedStrokeWidth.value ==
                strokeWidth
                ? 5
                : 0,
            color: AppColorConstants.themeColor,
            radius: strokeWidth + 5)),
      ),
    );
  }

  Widget _buildActionsToolBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildUndoButton(context),
        const SizedBox(
          width: 4.0,
        ),
        _buildRedoButton(context),
        const SizedBox(
          width: 4.0,
        ),
        _buildClearButton(context),
        const SizedBox(
          width: 4.0,
        ),
        _buildEraserButton(context),
        const SizedBox(
          width: 4.0,
        ),
        // _buildPointerModeSwitcher(context,
        //     penMode: state.allowedPointersMode == ScribblePointerMode.penOnly),
        // const SizedBox(
        //   width: 4.0,
        // ),
        _buildSendImageButton(context),
      ],
    );
  }

  Widget _buildStrokeColorToolbar(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 30,
          width: 30,
          color: AppColorConstants.backgroundColor,
          child: const ThemeIconWidget(ThemeIcon.edit),
        ).borderWithRadius(value: 5, radius: 1),
        SizedBox(
          width: Get.width - 80,
          height: 50,
          child: ListView.builder(
              padding:  EdgeInsets.only(left: DesignConstants.horizontalPadding),
              itemCount: 10,
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, index) {
                return _buildStrokeColorButton(context,
                    color: colorsList[index]);
              }),
        )
      ],
    );
  }

  Widget _buildBackgroundColorToolbar(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 30,
          width: 30,
          color: Colors.white,
        ).borderWithRadius(value: 5, radius: 1),
        SizedBox(
          width: Get.width - 80,
          height: 50,
          child: ListView.builder(
              padding:  EdgeInsets.only(left: DesignConstants.horizontalPadding),
              itemCount: 10,
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, index) {
                return _buildBackgroundColorButton(context,
                    color: colorsList[index]);
              }),
        )
      ],
    );
  }

  Widget _buildEraserButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Obx(() => FloatingActionButton.small(
        tooltip: "Erase",
        backgroundColor: const Color(0xFFF7FBFF),
        elevation: _drawingBoardController.isErasing.value == true ? 10 : 2,
        shape: const CircleBorder(),
        onPressed: () {
          if (_drawingBoardController.isErasing.value == true) {
            _drawingController.setPaintContent = SimpleLine();
          } else {
            _drawingController.setPaintContent = Eraser(
                color:
                _drawingBoardController.selectedBackgroundColor.value);
          }

          _drawingBoardController.eraseToggle();
        },
        child: const Icon(Icons.cleaning_services, color: Colors.blueGrey),
      )),
    );
  }

  Widget _buildStrokeColorButton(
      BuildContext context, {
        required Color color,
      }) {
    return Obx(() => Container(
      height: 40,
      width: _drawingBoardController.selectedStrokeColor.value == color
          ? 30
          : 40,
      color: color,
    ).border(
        value: _drawingBoardController.selectedStrokeColor.value == color
            ? 5
            : 0,
        color: AppColorConstants.themeColor)).ripple(() {
      _drawingController.setStyle(color: color);
      _drawingBoardController.setStrokeColor(color);
    });
  }

  Widget _buildBackgroundColorButton(
      BuildContext context, {
        required Color color,
      }) {
    return Obx(() => Container(
      width: _drawingBoardController.selectedBackgroundColor.value == color
          ? 30
          : 40,
      height: 40,
      color: color,
    ).border(
        value:
        _drawingBoardController.selectedBackgroundColor.value == color
            ? 5
            : 0,
        color: AppColorConstants.themeColor)).ripple(() {
      // print('background color');
      _drawingBoardController.setBackgroundColor(color);
    });
  }

  Widget _buildUndoButton(
      BuildContext context,
      ) {
    return FloatingActionButton.small(
      tooltip: "Undo",
      onPressed: () {
        if (_drawingController.currentIndex > 0) {
          _drawingController.undo();
        }
      },
      disabledElevation: 0,
      backgroundColor:
      _drawingController.currentIndex > 0 ? Colors.blueGrey : Colors.grey,
      child: const Icon(
        Icons.undo_rounded,
        color: Colors.white,
      ),
    );
  }

  Widget _buildRedoButton(
      BuildContext context,
      ) {
    return FloatingActionButton.small(
      tooltip: "Redo",
      onPressed: () {
        if (_drawingController.currentIndex <
            _drawingController.getHistory.length) {
          _drawingController.redo();
        }
      },
      disabledElevation: 0,
      backgroundColor:
      _drawingController.currentIndex < _drawingController.getHistory.length
          ? Colors.blueGrey
          : Colors.grey,
      child: const Icon(
        Icons.redo_rounded,
        color: Colors.white,
      ),
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return FloatingActionButton.small(
      tooltip: "Clear",
      onPressed: () {
        _drawingController.clear();
      },
      disabledElevation: 0,
      backgroundColor: Colors.blueGrey,
      child: const Icon(Icons.clear),
    );
  }

  Widget _buildSendImageButton(BuildContext context) {
    return FloatingActionButton.small(
      tooltip: "Send",
      onPressed: () {
        sendImage();
      },
      disabledElevation: 0,
      backgroundColor: Colors.blueGrey,
      child: const Icon(Icons.send),
    );
  }

  sendImage() async {
    Uint8List? imageBytes =
    (await _drawingController.getImageData())?.buffer.asUint8List();
    if (imageBytes != null) {
      File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      // print(filePath);
      Media media = Media(
          id: randomId(),
          file: file,
          fileSize: imageBytes.length,
          mainFileBytes: imageBytes,
          mediaType: GalleryMediaType.photo,
          creationTime: DateTime.now());
      if (widget.drawingCompleted != null) {
        widget.drawingCompleted!(media);
      } else {
        _chatDetailController.sendImageMessage(
          // context: context,
            media: media,
            mode: ChatMessageActionMode.none,
            room: _chatDetailController.chatRoom.value!);
      }
      Get.back();
    }
  }
}
