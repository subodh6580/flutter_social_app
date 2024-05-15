import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:foap/helper/enum.dart';
import 'package:foap/helper/file_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/chat_message_model.dart';
import 'package:foap/model/chat_room_model.dart';
import 'package:foap/screens/chat/media.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileManager {
  deleteMessageMedia(ChatMessageModel message) async {
    final tempDir = await getApplicationDocumentsDirectory();

    String messageMediaDirectoryPath =
        '${tempDir.path}/${message.roomId.toString()}/${message.localMessageId}';

    try {
      if (await Directory(messageMediaDirectoryPath).exists()) {
        await Directory(messageMediaDirectoryPath).delete(recursive: true);
      } else {}
    } catch (e) {
      // print(e);
      // Error in getting access to the file.
    }
  }

  multipleDeleteMessageMedia(List<ChatMessageModel> messages) async {
    for (ChatMessageModel message in messages) {
      if (message.isMediaMessage) {
        final tempDir = await getApplicationDocumentsDirectory();

        String messageMediaDirectoryPath =
            '${tempDir.path}/${message.roomId.toString()}/${message.localMessageId}';

        try {
          if (await Directory(messageMediaDirectoryPath).exists()) {
            await Directory(messageMediaDirectoryPath).delete(recursive: true);
          } else {}
        } catch (e) {
          // print(e);
          // Error in getting access to the file.
        }
      }
    }
  }

  deleteRoomMedia(ChatRoomModel chatRoom) async {
    final tempDir = await getApplicationDocumentsDirectory();
    String localPath = '${tempDir.path}/${chatRoom.id.toString()}';

    try {
      if (await Directory(localPath).exists()) {
        await Directory(localPath).delete(recursive: true);
      }
    } catch (e) {
      // Error in getting access to the file.
    }
  }

  Future<String?> localImagePathForMessage(ChatMessageModel message) async {
    String? filePath;

    final docDir = await getApplicationDocumentsDirectory();

    String localPath =
        '${docDir.path}/${message.roomId.toString()}/${message.localMessageId}/${message.localMessageId}.png';

    if (File(localPath).existsSync()) {
      filePath = localPath;
    } else {}

    return filePath;
  }

  Future<String?> localFilePathForMessage(ChatMessageModel message) async {
    String? filePath;
    String extension = '';

    if (message.messageContentType == MessageContentType.photo) {
      extension = p.extension(message.mediaContent.image!);
    }
    if (message.messageContentType == MessageContentType.video) {
      extension = p.extension(message.mediaContent.video!);
    }
    if (message.messageContentType == MessageContentType.audio) {
      extension = p.extension(message.mediaContent.audio!);
    }
    if (message.messageContentType == MessageContentType.file) {
      extension = p.extension(message.mediaContent.file!.path);
    }
    final docDir = await getApplicationDocumentsDirectory();

    String localPath =
        '${docDir.path}/${message.roomId.toString()}/${message.localMessageId}/${message.localMessageId}$extension';

    if (File(localPath).existsSync()) {
      filePath = localPath;
    } else {}

    return filePath;
  }

  static Future<File> saveChatMediaToDirectory(
      Media media, String messageId, bool isThumbnail, int chatRoomId) async {
    String extension = '';
    Uint8List mainFileData;
    String messageMediaDirectoryPath =
        await messageMediaDirectory(messageId, chatRoomId);

    if (isThumbnail) {
      String thumbnailPath = '$messageMediaDirectoryPath/$messageId.png';
      File videoThumbnail = await File(thumbnailPath).create();
      videoThumbnail.writeAsBytesSync(media.thumbnail!);
      return videoThumbnail;
    }

    if (media.mediaType == GalleryMediaType.photo) {
      extension = '.png';
      if (media.mainFileBytes == null) {
        mainFileData = await media.file!.compress();
      } else {
        mainFileData = media.mainFileBytes!;
      }
    } else if (media.mediaType == GalleryMediaType.video) {
      extension = '.mp4';

      if (media.mainFileBytes == null) {
        mainFileData = media.file!.readAsBytesSync();
      } else {
        mainFileData = media.mainFileBytes!;
      }
    } else if (media.mediaType == GalleryMediaType.audio) {
      extension = '.mp3';

      if (media.mainFileBytes == null) {
        mainFileData = media.file!.readAsBytesSync();
      } else {
        mainFileData = media.mainFileBytes!;
      }
    } else {
      if (media.mainFileBytes == null) {
        mainFileData = media.file!.readAsBytesSync();
      } else {
        mainFileData = media.mainFileBytes!;
      }
      // file
      extension = p.extension(media.file!.path);
    }

    String imagePath = '$messageMediaDirectoryPath/$messageId$extension';
    File file = await File(imagePath).create();
    file.writeAsBytesSync(mainFileData);
    return file;
  }

  //create chat room directory
  static Future<String> messageMediaDirectory(
      String localMessageId, int chatRoomId) async {
    final appDir = await getApplicationDocumentsDirectory();

    final Directory chatRoomDirectory =
        Directory('${appDir.path}/$chatRoomId/$localMessageId');

    if (await chatRoomDirectory.exists()) {
      //if folder already exists return path
      return chatRoomDirectory.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory newFolder =
          await chatRoomDirectory.create(recursive: true);
      return newFolder.path;
    }
  }

}
