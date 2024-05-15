import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:foap/controllers/chat_and_call/chat_detail_controller.dart';
import 'package:foap/controllers/chat_and_call/chat_history_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/manager/file_manager.dart';
import 'package:foap/model/chat_message_model.dart';
import 'package:foap/model/chat_room_model.dart';
import 'package:foap/model/story_model.dart';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DBManager {
  final ChatDetailController _chatDetailController = Get.find();
  final ChatHistoryController _chatHistoryController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  late Database database;
  var random = math.Random.secure();

  createDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = p.join(databasesPath, 'socialified.db');

    try {
      await Directory(databasesPath).create(recursive: true);
      database = await openDatabase(path,
          version: 2,
          onCreate: (Database db, int version) async {
            await db.execute(
                'CREATE TABLE StoryViewHistory (storyId INTEGER PRIMARY KEY, time INTEGER)');
            await db.execute(
                'CREATE TABLE ChatRooms (id INTEGER PRIMARY KEY, title TEXT ,status INTEGER,type INTEGER,is_chat_user_online INTEGER, created_by INTEGER,created_at INTEGER,updated_at INTEGER,imageUrl TEXT,description TEXT,chat_access_group INTEGER,last_message_id TEXT,unread_messages_count INTEGER)');
            await db.execute(
                'CREATE TABLE Messages (local_message_id TEXT PRIMARY KEY, id INTEGER, room_id INTEGER,messageType INTEGER, message TEXT,username TEXT, created_by INTEGER,created_at INTEGER,viewed_at INTEGER,isDeleted INTEGER,isStar INTEGER,deleteAfter INTEGER,is_encrypted INTEGER,chat_version INTEGER,current_status INTEGER,encryption_key TEXT,replied_on_message TEXT)');
            await db.execute(
                'CREATE TABLE ChatRoomMembers (id INTEGER PRIMARY KEY, room_id INTEGER, user_id INTEGER,is_admin INTEGER,user TEXT)');
            await db.execute(
                'CREATE TABLE UsersCache (id INTEGER PRIMARY KEY, username TEXT,email TEXT,picture TEXT)');
            await db.execute(
                'CREATE TABLE ChatMessageUser (chat_message_id INTEGER,user_id INTEGER,status INTEGER)');
          },
          onOpen: (db) {},
          onUpgrade: (db, oldVersion, currentVersion) async {
            await db.execute(
                'CREATE TABLE ChatMessageUser (chat_message_id INTEGER,user_id INTEGER,status INTEGER)');
            await db.execute(
                'ALTER TABLE Messages ADD COLUMN is_encrypted INTEGER ');
            await db.execute(
                'ALTER TABLE Messages ADD COLUMN chat_version INTEGER ');
            await db.execute(
                'ALTER TABLE Messages ADD COLUMN current_status INTEGER');
            await db
                .execute('ALTER TABLE Messages ADD COLUMN encryption_key TEXT');
            await db.execute(
                'ALTER TABLE Messages ADD COLUMN replied_on_message TEXT');
          });
    } catch (error) {
      debugPrint('catch');
    }
  }

  storyViewed(StoryMediaModel story) async {
    // check if not viewed already

    //save the item
    await database.transaction((txn) async {
      List<Map> list = await txn.rawQuery(
          'SELECT * FROM StoryViewHistory WHERE storyId = ${story.id}');

      if (list.isEmpty) {
        await txn.rawInsert(
            'INSERT INTO StoryViewHistory(storyId, time) VALUES(${story.id},"${story.createdAtDate}")');
      }
    });
  }

  Future<List<int>> getAllViewedStories() async {
    List<int> ids = [];

    await database.transaction((txn) async {
      List<Map> list = await txn.rawQuery('SELECT * FROM StoryViewHistory');

      // final items = await db.collection('viewedStories').get();
      for (var doc in list) {
        ids.add((doc as Map<String, dynamic>)['storyId']);
      }
    });

    return ids;
  }

  clearOldStories() async {
    // final items = await db.collection('viewedStories').get();
    int currentEpochTime = DateTime.now().millisecondsSinceEpoch;

    await database.transaction((txn) async {
      await txn.rawDelete(
          'DELETE  FROM StoryViewHistory WHERE time > ${currentEpochTime - 86400000}');
    });
  }

  //******************** Chat ************************//

  // Future saveRooms(List<ChatRoomModel> chatRooms) async {
  //   for (ChatRoomModel room in chatRooms) {
  //     saveRoom(room);
  //   }
  // }

  newMessageReceived(ChatMessageModel message) async {
    ChatRoomModel? existingRoom =
        await getIt<DBManager>().getRoomById(message.roomId);

    if (existingRoom == null) {
      // save room in database
      _chatDetailController.getRoomDetail(message.roomId, (chatroom) async {

        await getIt<DBManager>().saveRooms([chatroom]);
        await getIt<DBManager>().saveMessage(chatMessages: [message]);
      });
    } else {
      await getIt<DBManager>().saveMessage(chatMessages: [message]);
    }

    _chatDetailController.newMessageReceived(message);
    _chatHistoryController.newMessageReceived(message);
  }

  Future saveRooms(List<ChatRoomModel> chatRooms) async {
    var batch = database.batch();

    for (ChatRoomModel chatRoom in chatRooms) {
      ChatRoomModel? room = await getRoomById(chatRoom.id);
      if (room == null) {
        batch.rawDelete('DELETE FROM ChatRooms WHERE id = ${chatRoom.id}');

        batch.rawInsert(
            'INSERT INTO ChatRooms(id, title, status,type,is_chat_user_online,created_by,created_at,updated_at,imageUrl,description,chat_access_group) VALUES(${chatRoom.id},"${chatRoom.name}", ${chatRoom.status},${chatRoom.type}, ${chatRoom.isOnline == true ? 1 : 0},${chatRoom.createdBy},${chatRoom.createdAt},${chatRoom.createdAt},"${chatRoom.image}","${chatRoom.description}",${chatRoom.groupAccess})');

        for (ChatRoomMember member in chatRoom.roomMembers) {
          batch.rawDelete(
            'DELETE  FROM ChatRoomMembers WHERE id = ${member.id}',
          );

          batch.rawInsert(
            'INSERT INTO ChatRoomMembers(id, room_id, user_id,is_admin) VALUES(${member.id}, ${member.roomId}, ${member.userId},${member.isAdmin})',
          );

          batch.rawDelete(
            'DELETE  FROM UsersCache WHERE id = ${member.userDetail.id}',
          );

          batch.rawInsert(
            'INSERT INTO UsersCache(id, username,email,picture) VALUES(${member.userDetail.id}, "${member.userDetail.userName}", "${member.userDetail.email}","${member.userDetail.picture}")',
          );
        }
        if (chatRoom.lastMessage != null) {
          saveMessage(
              chatMessages: [chatRoom.lastMessage!], currentBatch: batch);
        }
      } else {
        updateRoom(chatRoom);
      }
    }
    await batch.commit(noResult: true);
  }

  Future updateRoom(ChatRoomModel chatRoom) async {
    // ChatRoomModel? room = await getRoomById(chatRoom.id);
    ChatMessageModel? lastMessage = chatRoom.lastMessage;
    int? updateAt = chatRoom.updatedAt;
    var batch = database.batch();

    // await database.transaction((txn) async {

    if (updateAt != null) {
      batch.rawUpdate('UPDATE ChatRooms '
          'SET title = "${chatRoom.name}",'
          'status = ${chatRoom.status},'
          'type = ${chatRoom.type},'
          'is_chat_user_online = ${chatRoom.isOnline == true ? 1 : 0},'
          'updated_at = $updateAt,'
          'imageUrl = "${chatRoom.image}",'
          'description = "${chatRoom.description}",'
          'chat_access_group = ${chatRoom.groupAccess},'
          'last_message_id = "${lastMessage?.localMessageId}" '
          'WHERE id = ${chatRoom.id}');
    } else {
      batch.rawUpdate('UPDATE ChatRooms '
          'SET title = "${chatRoom.name}",'
          'status = ${chatRoom.status},'
          'type = ${chatRoom.type},'
          'is_chat_user_online = ${chatRoom.isOnline == true ? 1 : 0},'
          'imageUrl = "${chatRoom.image}",'
          'description = "${chatRoom.description}",'
          'chat_access_group = ${chatRoom.groupAccess},'
          'last_message_id = "${lastMessage?.localMessageId}" '
          'WHERE id = ${chatRoom.id}');
    }

    batch.rawDelete(
        'DELETE  FROM ChatRoomMembers WHERE room_id = ${chatRoom.id}');
    for (ChatRoomMember member in chatRoom.roomMembers) {
      batch.rawInsert(
        'INSERT INTO ChatRoomMembers(id, room_id, user_id,is_admin) VALUES(${member.id}, ${member.roomId}, ${member.userId},${member.isAdmin})',
      );

      batch.rawDelete(
        'DELETE  FROM UsersCache WHERE id = ${member.userDetail.id}',
      );

      batch.rawInsert(
        'INSERT INTO UsersCache(id, username,email,picture) VALUES(${member.userDetail.id}, "${member.userDetail.userName}", "${member.userDetail.email}","${member.userDetail.picture}")',
      );
    }
    await batch.commit(noResult: true);
  }

  Future updateRoomUpdateAtTime(int chatRoomId) async {
    int? updateAt = DateTime.now().millisecondsSinceEpoch;

    await database.transaction((txn) async {
      txn.rawUpdate(
          'UPDATE ChatRooms SET updated_at = $updateAt WHERE id = $chatRoomId');
    });
  }

  Future<List<ChatRoomMember>> getAllMembersInRoom(int roomId) async {
    List<ChatRoomMember> membersArr = [];

    await database.transaction((txn) async {
      List<Map> list = await txn
          .rawQuery('SELECT * FROM ChatRoomMembers WHERE room_id = $roomId');

      for (var user in list) {
        List<Map> userData = await txn
            .rawQuery('SELECT * FROM UsersCache WHERE id = ${user["user_id"]}');

        Map<String, dynamic> userDetail = Map<String, dynamic>.from(user);

        userDetail['user'] = userData.first;
        ChatRoomMember userModel = ChatRoomMember.fromJson(userDetail);
        membersArr.add(userModel);
      }
    });

    return membersArr;
  }

  Future<List<ChatMessageUser>> getAllMembersInMessage(
      int messageId, Transaction txn) async {
    List<ChatMessageUser> membersArr = [];

    // await database.transaction((txn) async {
    List<Map> users = await txn.rawQuery(
        'SELECT * FROM ChatMessageUser WHERE chat_message_id = $messageId');
    membersArr = users.map((e) => ChatMessageUser.fromJson(e)).toList();
    // });

    return membersArr;
  }

  insertChatMessageUsers({required List<ChatMessageUser> users}) async {
    var batch = database.batch();
    for (ChatMessageUser user in users) {
      batch.rawInsert(
          'INSERT INTO ChatMessageUser( chat_message_id,user_id,status) VALUES(${user.messageId}, ${user.userId}, ${user.status})');
    }

    batch.commit();
  }

  updateChatMessageUserStatus(
      {required ChatMessageUser user, required int status}) async {
    await database.transaction((txn) async {
      txn.rawUpdate(
          'UPDATE ChatMessageUser set status = "$status" WHERE user_id == ${user.userId} AND chat_message_id == ${user.messageId}');
    });
  }

  Future<List<ChatRoomMember>> fetchAllMembersInRoom(
      int roomId, Transaction txn) async {
    List<ChatRoomMember> membersArr = [];

    List<Map> list = await txn
        .rawQuery('SELECT * FROM ChatRoomMembers WHERE room_id = $roomId');

    for (var user in list) {
      List<Map> userData = await txn
          .rawQuery('SELECT * FROM UsersCache WHERE id = ${user["user_id"]}');

      Map<String, dynamic> userDetail = Map<String, dynamic>.from(user);

      userDetail['user'] = userData.first;
      ChatRoomMember userModel = ChatRoomMember.fromJson(userDetail);
      membersArr.add(userModel);
    }

    return membersArr;
  }

  Future<UserModel> fetchUser(int userId, Transaction txn) async {
    // List<Map> list = await txn
    //     .rawQuery('SELECT * FROM ChatRoomMembers WHERE room_id = $roomId');
    //
    // Map user = list.first;
    // for (var user in list) {
    List<Map> userData =
        await txn.rawQuery('SELECT * FROM UsersCache WHERE id = $userId');

    // Map<String, dynamic> userDetail = Map<String, dynamic>.from(user);

    // userDetail['user'] = userData.first;
    return UserModel.fromJson(userData.first);
    // }

    // return membersArr;
  }

  // saveAsLastMessageInRoom(
  //     {required int roomId,
  //     required ChatMessageModel chatMessage,
  //     required Batch batch}) async {
  //   // await database.transaction((txn) async {
  //
  //   batch.rawUpdate('UPDATE ChatRooms '
  //       'SET '
  //       'updated_at = ${chatMessage.createdAt},'
  //       'last_message_id = "${chatMessage.localMessageId}" '
  //       'WHERE id = $roomId');
  //   // });
  // }

  Future<List<ChatRoomModel>> getAllRooms() async {
    // Directory dir = await getApplicationDocumentsDirectory();
    List<ChatRoomModel> rooms = [];

    await database.transaction((txn) async {
      List<Map> dbRooms = await txn.rawQuery('SELECT * FROM ChatRooms');
      List<Map> updateAbleRoomJson = List<Map>.from(dbRooms);

      for (Map roomJson in updateAbleRoomJson) {
        List<Map> userData = await txn.rawQuery(
            'SELECT * FROM UsersCache WHERE id = ${roomJson["created_by"]}');

        Map<String, dynamic> updateAbleRoomJson =
            Map<String, dynamic>.from(roomJson);

        if (userData.isNotEmpty) {
          updateAbleRoomJson['createdByUser'] = userData.first;
          ChatRoomModel room = ChatRoomModel.fromJson(updateAbleRoomJson);
          List<ChatRoomMember> usersInRoom =
              await fetchAllMembersInRoom(room.id, txn);

          List<ChatMessageModel> lastMessages =
              await getLastMessageFromRoom(roomId: room.id, txn: txn);
          if (lastMessages.isNotEmpty) {
            room.lastMessage = lastMessages.first;
          }

          room.roomMembers = usersInRoom;

          // if (room.amIMember) {
          rooms.add(room);
          // }
        }
      }
    });

    rooms.sort((a, b) {
      if (b.updatedAt == null || a.updatedAt == null) {
        return 0;
      }
      return b.updatedAt!.compareTo(a.updatedAt!);
    });

    return rooms;
  }

  Future<ChatRoomModel?> fetchRoom(int roomId, Transaction txn) async {
    ChatRoomModel? chatRoom;
    List<Map> dbRooms =
        await txn.rawQuery('SELECT * FROM ChatRooms WHERE id = $roomId');

    if (dbRooms.isNotEmpty) {
      Map<String, dynamic> roomJson = dbRooms.first as Map<String, dynamic>;

      List<Map> userData = await txn.rawQuery(
          'SELECT * FROM UsersCache WHERE id = ${roomJson["created_by"]}');

      Map<String, dynamic> updatedRoomJson =
          Map<String, dynamic>.from(roomJson);

      if (userData.isNotEmpty) {
        updatedRoomJson['createdByUser'] = userData.first;
      } else {
        updatedRoomJson['createdByUser'] = {'id': roomJson["created_by"]};
      }
      chatRoom = ChatRoomModel.fromJson(updatedRoomJson);
      chatRoom.roomMembers = await fetchAllMembersInRoom(chatRoom.id, txn);
    }

    return chatRoom;
  }

  Future<ChatRoomModel?> getRoomById(int roomId) async {
    ChatRoomModel? room;
    await database.transaction((txn) async {
      room = await fetchRoom(roomId, txn);
    });
    return room;
  }

  saveMessage(
      {required List<ChatMessageModel> chatMessages,
      Batch? currentBatch}) async {
    var batch = currentBatch ?? database.batch();

    for (ChatMessageModel chatMessage in chatMessages) {
      if (chatMessage.isMineMessage) {
        chatMessage.viewedAt = DateTime.now().millisecondsSinceEpoch;
      }

      batch.rawDelete(
          'DELETE FROM Messages WHERE local_message_id = "${chatMessage.localMessageId}"');

      batch.rawInsert('INSERT INTO Messages(local_message_id, '
          'id,'
          'is_encrypted,'
          'chat_version,'
          'room_id,'
          'current_status,'
          'messageType, '
          'message,'
          'replied_on_message,'
          'username, '
          'created_by,'
          'created_at,'
          'viewed_at,'
          'isDeleted,'
          'isStar,'
          'deleteAfter) VALUES('
          '"${chatMessage.localMessageId}",'
          '${chatMessage.id},'
          '${chatMessage.isEncrypted}, '
          '${chatMessage.chatVersion}, '
          '"${chatMessage.roomId}", '
          '"${chatMessage.status}", '
          '${chatMessage.messageType},'
          '"${chatMessage.messageContent}", '
          '"${chatMessage.repliedOnMessageContent}", '
          '"${chatMessage.userName}",'
          '${chatMessage.senderId},'
          '${chatMessage.createdAt},'
          '${chatMessage.viewedAt},'
          '"${chatMessage.isDeleted}",'
          '"${chatMessage.isStar}",'
          '${chatMessage.deleteAfter})');

      if (chatMessage.isDateSeparator == false &&
          chatMessage.messageContentType != MessageContentType.groupAction) {
        updateRoomUpdateAtTime(chatMessage.roomId);
      }

      saveUserInCache(
          user: chatMessage.sender ?? _userProfileManager.user.value!,
          batch: batch);

      // if (chatMessage.id != 0) {
      // print('insert chat message user = ${chatMessage.chatMessageUser.length}');
      // insertChatMessageUsers(users: chatMessage.chatMessageUser, batch: batch);
      // }
    }
    if (currentBatch == null) {
      await batch.commit(noResult: true);
    }
  }

  Future saveUserInCache(
      {required UserModel user, required Batch batch}) async {
    batch.rawDelete(
      'DELETE  FROM UsersCache WHERE id = ${user.id}',
    );

    batch.rawInsert(
      'INSERT INTO UsersCache(id, username,email,picture) VALUES(${user.id}, "${user.userName}", "${user.email}","${user.picture}")',
    );
  }

  Future<List<ChatMessageModel>> getAllMessages(
      {required int roomId, required int offset, int? limit}) async {
    List<ChatMessageModel> messages = [];
    List<ChatMessageModel> messagesToDelete = [];
    List<ChatMessageModel> messagesToUpdate = [];

    List<Map> dbMessages = [];

    await database.transaction((txn) async {
      if (limit == null) {
        dbMessages = await txn.rawQuery(
            'SELECT * FROM Messages WHERE room_id = $roomId ORDER BY created_at DESC');
      } else {
        dbMessages = await txn.rawQuery(
            'SELECT * FROM Messages WHERE room_id = $roomId ORDER BY created_at DESC LIMIT $limit OFFSET $offset');
      }

      if (dbMessages.isNotEmpty) {
        List<Map> updateAbleDbMessages = List<Map>.from(dbMessages);

        updateAbleDbMessages
            .sort((a, b) => a['created_at'].compareTo(b['created_at']));

        for (var doc in updateAbleDbMessages) {
          ChatMessageModel message =
              ChatMessageModel.fromJson((doc as Map<String, dynamic>));
          int timeDifference = 0;

          message.sender = await fetchUser(message.senderId, txn);
          if (message.viewedAt != null) {
            final date2 = DateTime.now();
            DateTime viewAtDateTime =
                DateTime.fromMillisecondsSinceEpoch(message.viewedAt!);
            timeDifference = date2.difference(viewAtDateTime).inSeconds;
          } else {
            messagesToUpdate.add(message);
          }

          if (timeDifference < _userProfileManager.user.value!.chatDeleteTime) {
            messages.add(message);
          } else {
            messagesToDelete.add(message);
          }
          List<ChatMessageUser> usersInMessage =
              await getAllMembersInMessage(message.id, txn);

          message.chatMessageUser = usersInMessage;
        }

        ChatRoomModel? chatRoom = await fetchRoom(roomId, txn);

        if (chatRoom != null) {
          hardDeleteMessages(messages: messagesToDelete);
        }
        if (messagesToUpdate.isNotEmpty) {
          updateMessageViewedTime(messagesToUpdate);
        }
      }
    });
    return messages;
  }

  updateMessageContent(
      {required int roomId,
      required String localMessageId,
      required String content}) async {
    await database.transaction((txn) async {
      await txn.rawUpdate('UPDATE Messages '
          'SET '
          'message = "$content" '
          'WHERE local_message_id = "$localMessageId"');
    });
  }

  updateMessageViewedTime(List<ChatMessageModel> messages) async {
    for (ChatMessageModel message in messages) {
      await database.transaction((txn) async {
        await txn.rawUpdate('UPDATE Messages '
            'SET '
            'viewed_at = ${DateTime.now().millisecondsSinceEpoch} '
            'WHERE local_message_id = "${message.localMessageId}"');
      });
    }
  }

  updateMessageStatus(
      {required int roomId,
      required String localMessageId,
      required int id,
      required int status}) async {
    await database.transaction((txn) async {
      await txn.rawUpdate('UPDATE Messages '
          'SET '
          'current_status = $status,'
          'id = $id '
          'WHERE local_message_id = "$localMessageId"');
    });
  }

  starUnStarMessage(
      {required int roomId,
      required String localMessageId,
      required int isStar}) async {
    await database.transaction((txn) async {
      await txn.rawUpdate('UPDATE Messages '
          'SET '
          'isStar = $isStar '
          'WHERE local_message_id = "$localMessageId"');
    });
  }

  Future<List<ChatMessageModel>> getMessages(
      {required int roomId, required MessageContentType contentType}) async {
    List<ChatMessageModel> messages = [];

    await database.transaction((txn) async {
      List<Map> dbMessages =
          await txn.rawQuery('SELECT * FROM Messages WHERE room_id = $roomId');

      for (var doc in dbMessages) {
        messages.add(ChatMessageModel.fromJson((doc as Map<String, dynamic>)));
      }
      messages = messages
          .where((element) =>
              element.messageContentType == contentType &&
              element.messageContent.isNotEmpty)
          .toList();
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });

    return messages;
  }

  Future<List<ChatMessageModel>> getStarredMessages(
      {required int roomId}) async {
    List<ChatMessageModel> messages = [];
    await database.transaction((txn) async {
      List<Map> dbMessages =
          await txn.rawQuery('SELECT * FROM Messages WHERE room_id = $roomId');

      for (var doc in dbMessages) {
        messages.add(ChatMessageModel.fromJson((doc as Map<String, dynamic>)));
      }
      messages = messages.where((element) => element.isStar == 1).toList();
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });

    return messages;
  }

  Future<List<ChatMessageModel>> getMessagesById(
      {required int messageId, required int roomId}) async {
    List<ChatMessageModel> messages = [];

    await database.transaction((txn) async {
      List<Map> dbMessages = await txn.rawQuery(
          'SELECT * FROM Messages WHERE room_id = $roomId AND id = $messageId');

      for (var doc in dbMessages) {
        ChatMessageModel message =
            ChatMessageModel.fromJson((doc as Map<String, dynamic>));
        if (message.id == messageId) {
          messages.add(message);
        }
      }
    });

    return messages;
  }

  Future<List<ChatMessageModel>> getLastMessageFromRoom(
      {required int roomId, required Transaction txn}) async {
    List<ChatMessageModel> messages = [];
    // await database.transaction((txn) async {
    List<Map> dbMessages = await txn.rawQuery(
        'SELECT * FROM Messages WHERE room_id = "$roomId" ORDER BY id DESC LIMIT 1');

    if (dbMessages.isNotEmpty) {
      ChatMessageModel message =
          ChatMessageModel.fromJson((dbMessages.first as Map<String, dynamic>));
      messages.add(message);
    }
    // });

    return messages;
  }

  Future<List<ChatMessageModel>> getMediaMessages({required int roomId}) async {
    List<ChatMessageModel> messages = [];

    await database.transaction((txn) async {
      List<Map> dbMessages = await txn.rawQuery(
          'SELECT * FROM Messages WHERE room_id = $roomId AND (type = 2 || type = 3 || type = 4)');

      for (var doc in dbMessages) {
        messages.add(ChatMessageModel.fromJson((doc as Map<String, dynamic>)));
      }

      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });

    return messages;
  }

  deleteMessagesInRoom(ChatRoomModel chatRoom) async {
    await database.transaction((txn) async {
      await txn
          .rawDelete('DELETE FROM Messages WHERE room_id = ${chatRoom.id}');
    });

    getIt<FileManager>().deleteRoomMedia(chatRoom);
  }

  deleteRooms(List<ChatRoomModel> chatRooms) async {
    await database.transaction((txn) async {
      for (ChatRoomModel chatRoom in chatRooms) {
        await txn.rawDelete('DELETE FROM ChatRooms WHERE id = ${chatRoom.id}');
        await txn
            .rawDelete('DELETE FROM Messages WHERE room_id = ${chatRoom.id}');
      }
    });

    for (ChatRoomModel chatRoom in chatRooms) {
      await getIt<FileManager>().deleteRoomMedia(chatRoom);
    }
  }

  hardDeleteMessages({required List<ChatMessageModel> messages}) async {
    var batch = database.batch();

    for (ChatMessageModel message in messages) {
      batch.rawDelete(
          'DELETE FROM Messages WHERE local_message_id = "${message.localMessageId}"');

      if (message.isMediaMessage) {
        getIt<FileManager>().deleteMessageMedia(message);
      }
    }
    await batch.commit(noResult: true);
  }

  softDeleteMessages({required List<ChatMessageModel> messagesToDelete}) async {
    var batch = database.batch();

    for (ChatMessageModel message in messagesToDelete) {
      batch.rawUpdate('UPDATE Messages '
          'SET '
          'isDeleted = 1 '
          'WHERE id = ${message.id} OR local_message_id = "${message.localMessageId}"');

      // updateMessageContent(
      //     roomId: message.roomId,
      //     localMessageId: message.localMessageId,
      //     content: message.messageContent);
    }
  }

  updateUnReadCount({required int roomId}) async {
    await database.transaction((txn) async {
      ChatRoomModel? room = await fetchRoom(roomId, txn);
      if (room != null) {
        await txn.rawUpdate('UPDATE ChatRooms '
            'SET '
            'unread_messages_count = ${room.unreadMessages + 1} '
            'WHERE id = $roomId');
      }
    });
  }

  Future<int> roomsWithUnreadMessages() async {
    List<Map> rooms = [];
    await database.transaction((txn) async {
      rooms = await txn
          .rawQuery('SELECT * FROM ChatRooms WHERE unread_messages_count > 0');
    });

    return rooms.length;
  }

  clearUnReadCount({required int roomId}) async {
    await database.transaction((txn) async {
      await txn.rawUpdate('UPDATE ChatRooms '
          'SET '
          'unread_messages_count = 0 '
          'WHERE id = $roomId');
    });
  }

  clearAllUnreadCount() async {
    await database.transaction((txn) async {
      await txn.rawUpdate('UPDATE ChatRooms '
          'SET '
          'unread_messages_count = 0');
    });
  }

  deleteAllChatHistory() async {
    List<ChatRoomModel> allRooms = await getAllRooms();

    deleteRooms(allRooms);
  }
}
