import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:foap/components/place_picker/place_picker.dart';
import 'package:foap/helper/file_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/chat/drawing_screen.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:giphy_get/giphy_get.dart';

import '../../components/giphy/giphy_get.dart';
import '../../model/location.dart';
import '../../util/constant_util.dart';
import '../settings_menu/settings_controller.dart';

class SharingMediaType {
  ThemeIcon icon;
  String text;
  MessageContentType contentType;

  SharingMediaType(
      {required this.icon, required this.text, required this.contentType});
}

class ChatMediaSharingOptionPopup extends StatefulWidget {
  const ChatMediaSharingOptionPopup({Key? key}) : super(key: key);

  @override
  State<ChatMediaSharingOptionPopup> createState() =>
      _ChatMediaSharingOptionPopupState();
}

class _ChatMediaSharingOptionPopupState
    extends State<ChatMediaSharingOptionPopup> {
  final ChatDetailController _chatDetailController = Get.find();
  final SettingsController _settingsController = Get.find();

  List<SharingMediaType> mediaTypes = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    loadChatSharingOptions();
    super.initState();
  }

  loadChatSharingOptions() {
    if (_settingsController.setting.value!.enablePhotoSharingInChat) {
      mediaTypes.add(SharingMediaType(
          icon: ThemeIcon.camera,
          text: cameraString.tr,
          contentType: MessageContentType.photo));
    }
    if (_settingsController.setting.value!.enablePhotoSharingInChat) {
      mediaTypes.add(SharingMediaType(
          icon: ThemeIcon.gallery,
          text: photoString.tr,
          contentType: MessageContentType.photo));
    }
    if (_settingsController.setting.value!.enableVideoSharingInChat) {
      mediaTypes.add(SharingMediaType(
          icon: ThemeIcon.videoCamera,
          text: photoString.tr,
          contentType: MessageContentType.video));
    }
    if (_settingsController.setting.value!.enableFileSharingInChat) {
      mediaTypes.add(SharingMediaType(
          icon: ThemeIcon.files,
          text: filesString.tr,
          contentType: MessageContentType.file));
    }
    if (_settingsController.setting.value!.enableGifSharingInChat) {
      mediaTypes.add(SharingMediaType(
          icon: ThemeIcon.gif,
          text: gifString.tr,
          contentType: MessageContentType.gif));
    }
    if (_settingsController.setting.value!.enableContactSharingInChat) {
      mediaTypes.add(SharingMediaType(
          icon: ThemeIcon.contacts,
          text: contactString.tr,
          contentType: MessageContentType.contact));
    }
    if (_settingsController.setting.value!.enableLocationSharingInChat) {
      mediaTypes.add(SharingMediaType(
          icon: ThemeIcon.location,
          text: locationString.tr,
          contentType: MessageContentType.location));
    }
    if (_settingsController.setting.value!.enableAudioSharingInChat) {
      mediaTypes.add(SharingMediaType(
          icon: ThemeIcon.mic,
          text: audioString.tr,
          contentType: MessageContentType.audio));
    }
    if (_settingsController.setting.value!.enableDrawingSharingInChat) {
      mediaTypes.add(SharingMediaType(
          icon: ThemeIcon.drawing,
          text: drawingString.tr,
          contentType: MessageContentType.drawing));
    }
    if (_settingsController.setting.value!.enableProfileSharingInChat) {
      mediaTypes.add(SharingMediaType(
          icon: ThemeIcon.account,
          text: userString.tr,
          contentType: MessageContentType.profile));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: AppColorConstants.backgroundColor,
            child: GridView.builder(
                itemCount: mediaTypes.length,
                padding: EdgeInsets.only(
                    top: 20,
                    left: DesignConstants.horizontalPadding,
                    right: DesignConstants.horizontalPadding),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                    childAspectRatio: 0.8),
                itemBuilder: (ctx, index) {
                  return Column(
                    children: [
                      Container(
                          height: 40,
                          width: 40,
                          color: AppColorConstants.cardColor.darken(),
                          child: ThemeIconWidget(
                            mediaTypes[index].icon,
                            size: 18,
                          )).circular,
                      const SizedBox(
                        height: 10,
                      ),
                      BodyMediumText(
                        mediaTypes[index].text,
                      )
                    ],
                  ).ripple(() {
                    handleAction(mediaTypes[index]);
                  });
                }),
          ).round(20).p16,
        ),
        const SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 50,
            width: 50,
            color: AppColorConstants.backgroundColor,
            child: Center(
              child: ThemeIconWidget(
                ThemeIcon.close,
                color: AppColorConstants.iconColor,
                size: 25,
              ),
            ),
          ).circular.ripple(() {
            Get.back();
          }),
        ),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }

  handleAction(SharingMediaType mediaType) {
    if (mediaType.contentType == MessageContentType.photo) {
      Get.back();

      if (mediaType.text == cameraString.tr) {
        openCamera();
      } else {
        openPhotoPicker();
      }
    } else if (mediaType.contentType == MessageContentType.video) {
      Get.back();
      openVideoPicker();
    } else if (mediaType.contentType == MessageContentType.gif) {
      Get.back();
      openGiphy();
    } else if (mediaType.contentType == MessageContentType.location) {
      Get.back();
      openLocationPicker();
    } else if (mediaType.contentType == MessageContentType.contact) {
      Get.back();
      openContactList();
    } else if (mediaType.contentType == MessageContentType.audio) {
      Get.back();
      openVoiceRecord();
    } else if (mediaType.contentType == MessageContentType.drawing) {
      Get.back();
      openDrawingBoard();
    } else if (mediaType.contentType == MessageContentType.profile) {
      Get.back();
      openUsersList();
    } else if (mediaType.contentType == MessageContentType.group) {
      Get.back();
      openGroups();
    } else if (mediaType.contentType == MessageContentType.file) {
      openFilePicker();
    }
  }

  openGiphy() async {
    String randomId = 'hsvcewd78djhbejkd';

    GiphyGif? gif = await GiphyGet.getGif(
      context: context,

      //Required
      apiKey: _settingsController.setting.value!.giphyApiKey!,
      //Required.
      lang: GiphyLanguage.english,
      //Optional - Language for query.
      randomID: randomId,
      // Optional - An ID/proxy for a specific user.
      tabColor: Colors.teal, // Optional- default accent color.
    );

    if (gif != null) {
      _chatDetailController.sendGifMessage(
          gif: gif.images!.original!.url,
          mode: _chatDetailController.actionMode.value,
          room: _chatDetailController.chatRoom.value!);
    }
  }

  void openVoiceRecord() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => VoiceRecord(
              recordingCallback: (media) {
                _chatDetailController.sendAudioMessage(
                    media: media,
                    mode: _chatDetailController.actionMode.value,
                    room: _chatDetailController.chatRoom.value!);
              },
            ));
  }

  void openContactList() {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => FractionallySizedBox(
              heightFactor: 1,
              child: ContactList(
                selectedContactsHandler: (contacts) {
                  for (Contact contact in contacts) {
                    _chatDetailController.sendContactMessage(
                        contact: contact,
                        mode: _chatDetailController.actionMode.value,
                        room: _chatDetailController.chatRoom.value!);
                  }
                },
              ),
            ));
  }

  void openLocationPicker() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) => FractionallySizedBox(
            heightFactor: 0.9,
            child: PlacePicker(
              apiKey: AppConfigConstants.googleMapApiKey,
              displayLocation: null,
            ))).then((location) {
      if (location != null) {
        LocationResult result = location as LocationResult;
        LocationModel locationModel = LocationModel(
            latitude: result.latLng!.latitude,
            longitude: result.latLng!.longitude,
            name: result.name!);

        _chatDetailController.sendLocationMessage(
            location: locationModel,
            mode: _chatDetailController.actionMode.value,
            room: _chatDetailController.chatRoom.value!);
      }
    });
  }

  void openDrawingBoard() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,

        // isDismissible: false,
        isScrollControlled: true,
        enableDrag: false,
        builder: (context) => const FractionallySizedBox(
            heightFactor: 0.9, child: DrawingScreen()));
  }

  void openCamera() async {
    XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      Media media = await photo.toMedia(GalleryMediaType.photo);

      _chatDetailController.sendImageMessage(
          media: media,
          mode: _chatDetailController.actionMode.value,
          room: _chatDetailController.chatRoom.value!);
    }
  }

  void openPhotoPicker() async {
    List<XFile> images = await _picker.pickMultiImage();
    List<Media> medias = [];
    for (XFile image in images) {
      Media media = await image.toMedia(GalleryMediaType.photo);
      medias.add(media);
    }

    for (Media media in medias) {
      if (media.mediaType == GalleryMediaType.photo) {
        _chatDetailController.sendImageMessage(
            media: media,
            mode: _chatDetailController.actionMode.value,
            room: _chatDetailController.chatRoom.value!);
      } else {
        _chatDetailController.sendVideoMessage(
            media: media,
            mode: _chatDetailController.actionMode.value,
            room: _chatDetailController.chatRoom.value!);
      }
    }
  }

  void openVideoPicker() async {
    XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      Media media = await video.toMedia(GalleryMediaType.video);

      _chatDetailController.sendVideoMessage(
          media: media,
          mode: _chatDetailController.actionMode.value,
          room: _chatDetailController.chatRoom.value!);
    }
  }

  void openUsersList() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) =>
            SelectFollowingUserForMessageSending(sendToUserCallback: (user) {
              _chatDetailController.sendUserProfileAsMessage(
                  user: user,
                  room: _chatDetailController.chatRoom.value!,
                  mode: _chatDetailController.actionMode.value);
            }));
  }

  void openGroups() {
    // showModalBottomSheet(
    //     backgroundColor: Colors.transparent,
    //     context: context,
    //
    //     builder: (context) => VoiceRecord(
    //       recordingCallback: (media) {
    //         _chatDetailController.sendAudioMessage(
    //             media: media,
    //             mode: _chatDetailController.actionMode.value,
    //             room: _chatDetailController.chatRoom.value!);
    //       },
    //     ));
  }

  void openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'mp3',
        'mp4',
        'pdf',
        'doc',
        'docx',
        'pptx',
        'ppt',
        'xlsx',
        'xls',
        'txt'
      ],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      Uint8List data = file.readAsBytesSync();
      int sizeInBytes = data.length;

      String fileName = result.files.single.name;

      Media media = Media();
      media.id = randomId();
      media.file = file;
      media.mainFileBytes = data;
      media.fileSize = sizeInBytes;

      // media.thumbnail = thumbnailData!;
      // media.size = size;
      media.creationTime = DateTime.now();
      media.title = fileName;
      media.mediaType = file.mediaType;

      if (file.mediaType == GalleryMediaType.photo) {
        _chatDetailController.sendImageMessage(
            media: media,
            mode: _chatDetailController.actionMode.value,
            room: _chatDetailController.chatRoom.value!);
      } else if (file.mediaType == GalleryMediaType.video) {
        _chatDetailController.sendVideoMessage(
            media: media,
            mode: _chatDetailController.actionMode.value,
            room: _chatDetailController.chatRoom.value!);
      } else if (file.mediaType == GalleryMediaType.audio) {
        _chatDetailController.sendAudioMessage(
            media: media,
            mode: _chatDetailController.actionMode.value,
            room: _chatDetailController.chatRoom.value!);
      } else {
        _chatDetailController.sendFileMessage(
            media: media,
            mode: _chatDetailController.actionMode.value,
            room: _chatDetailController.chatRoom.value!);
      }
      Get.back();
    } else {
      // User canceled the picker
    }
  }
}
