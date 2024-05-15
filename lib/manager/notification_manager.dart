import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:foap/apiHandler/apis/chat_api.dart';
import 'package:foap/apiHandler/apis/users_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/call_model.dart';
import 'package:foap/screens/chat/chat_detail.dart';
import 'package:foap/screens/profile/other_user_profile.dart';
import 'package:overlay_support/overlay_support.dart';
import '../controllers/chat_and_call/agora_call_controller.dart';
import '../controllers/live/agora_live_controller.dart';
import '../main.dart';
import '../screens/calling/accept_call.dart';
import '../screens/competitions/competition_detail_screen.dart';
import '../screens/home_feed/comments_screen.dart';
import '../util/shared_prefs.dart';

class NotificationManager {
  static final NotificationManager _singleton = NotificationManager._internal();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _firebaseMessaging = FirebaseMessaging.instance;

  factory NotificationManager() {
    return _singleton;
  }

  NotificationManager._internal();

  initializeFCM() async {
    await FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen(
      (message) async {
        NotificationManager().parseNotificationMessage(message.data);
      },
    );
    // With this token you can test it easily on your phone
    _firebaseMessaging.getToken().then((fcmToken) {
      if (fcmToken != null) {
        SharedPrefs().setFCMToken(fcmToken);
      }
    });

    _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    _firebaseMessaging.onTokenRefresh.listen((fcmToken) {
      SharedPrefs().setFCMToken(fcmToken);
    }).onError((err) {});
  }

  initialize() async {
    initializeFCM();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    var initializationSettings = const InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (response) {
      handleNotificationAction(response);
    }, onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
  }

  parseNotificationMessage(Map<String?, Object?> message) {
    String? callType = message['callType'] as String?;

    if (callType != null) {
      showHideCallNotifications(message);
    } else {
      if (Platform.isAndroid) {
        // handleAndroidNotifications(message);
      } else {
        FGBGEvents.stream.listen((event) {
          handleSimpleNotificationBannerTap(
              message, event == FGBGType.foreground ? true : false);
        });
      }
    }
  }

  showHideCallNotifications(Map<String?, Object?> data) async {
    int notificationType = int.parse(data['notification_type'] as String);

    if (notificationType == 104) {
      flutterLocalNotificationsPlugin.cancelAll();
      // AwesomeNotifications().dismissAllNotifications();
    } else {
      // new call
      String channelName = data['channelName'] as String;
      String token = data['token'] as String;
      String id = data['callType'] as String;
      String uuid = data['uuid'] as String;
      String callerId = data['callerId'] as String;
      String username = data['username'] as String;
      String callType = data['callType'] as String;

      var acceptAction = const AndroidNotificationAction(
        'accept_action', // ID of the action
        'Accept', // Title of the action
        showsUserInterface: true,
        // icon: 'accept_icon', // Optional: Icon name for Android (located in the drawable folder)
        // onPressed: _acceptCall, // Callback when the action is pressed
      );

      var declineAction = const AndroidNotificationAction(
        'decline_action',
        'Decline',
        showsUserInterface: true,
        // icon: 'decline_icon', // Optional: Icon name for Android (located in the drawable folder)
        // onPressed: _declineCall,
      );

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'call_channel_id', 'call_notification',
        priority: Priority.max,
        category: AndroidNotificationCategory.call,
        importance: Importance.max,
        fullScreenIntent: true,

        actions: [
          acceptAction,
          declineAction
        ], // Add the actions to the notification
      );
      NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);
      await flutterLocalNotificationsPlugin.show(
          0,
          callType == '1' ? 'Audio call' : 'Video call',
          'Call from $username',
          notificationDetails,
          payload: jsonEncode({
            "channelName": channelName,
            "token": token,
            "callerId": callerId.toString(),
            "callType": callType,
            "id": id,
            "uuid": uuid
          }));

      // AwesomeNotifications().createNotification(
      //     content: NotificationContent(
      //       //simple notification
      //       id: 123,
      //       channelKey: 'calls',
      //       //set configuration wuth key "basic"
      //       title
      //       :,
      //       body: 'Call from $username',
      //       payload: {
      //         "channelName": channelName,
      //         "token": token,
      //         "callerId": callerId.toString(),
      //         "callType": callType,
      //         "id": id,
      //         "uuid": uuid
      //       },
      //       category: NotificationCategory.Call,
      //       displayOnBackground: true,
      //       wakeUpScreen: true,
      //       fullScreenIntent: true,
      //       displayOnForeground: true,
      //       autoDismissible: false,
      //     ),
      //     actionButtons: [
      //       NotificationActionButton(
      //         key: "answer",
      //         label: "Answer",
      //       ),
      //       NotificationActionButton(
      //         key: "decline",
      //         label: "Decline",
      //       )
      //     ]);
    }
  }

  handleNotificationAction(NotificationResponse response) {
    var payload = jsonDecode(response.payload!);
    String? callType = payload['callType'] as String?;
    if (callType != null) {
      if (response.actionId == 'accept_action') {
        performActionOnCallNotificationBanner(
            jsonDecode(response.payload!), true, false);
      } else if (response.actionId == 'decline_action') {
        performActionOnCallNotificationBanner(
            jsonDecode(response.payload!), false, false);
      } else {
        performActionOnCallNotificationBanner(
            jsonDecode(response.payload!), false, true);
      }
    } else {
      FGBGEvents.stream.listen((event) {
        handleSimpleNotificationBannerTap(jsonDecode(response.payload!),
            event == FGBGType.foreground ? true : false);
      });
    }
  }

  handleSimpleNotificationBannerTap(dynamic data, bool isInForeground) {
    final AgoraLiveController agoraLiveController = Get.find();

    int notificationType =
        int.parse(data['notification_type'] as String? ?? '0');

    if (isInForeground) {
      // show banner
      if (notificationType == 1) {
        int referenceId = int.parse(data['reference_id'] as String);
        String message = data['body'];

        // following notification

        UsersApi.getOtherUser(
            userId: referenceId,
            resultCallback: (result) {
              showOverlayNotification((context) {
                return Container(
                  color: Colors.transparent,
                  child: Card(
                    color: AppColorConstants.cardColor,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                      leading: UserAvatarView(
                        size: 40,
                        user: result,
                      ),
                      title: Heading5Text(
                        newFollowerString.tr,
                        weight: TextWeight.bold,
                        color: AppColorConstants.themeColor,
                      ),
                      subtitle: Heading6Text(
                        message,
                      ),
                    ).vp(12).ripple(() {
                      OverlaySupportEntry.of(context)!.dismiss();
                      Get.to(() => OtherUserProfile(userId: referenceId));
                    }),
                  ).setPadding(top: 50, left: 8, right: 8).round(10),
                );
              }, duration: const Duration(milliseconds: 4000));
            });
      } else if (notificationType == 2) {
        int referenceId = int.parse(data['reference_id'] as String);
        String message = data['title'];

        // comment notification
        showOverlayNotification((context) {
          return Container(
            color: Colors.transparent,
            child: Card(
              color: AppColorConstants.cardColor,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ListTile(
                title: Heading5Text(
                  newCommentString.tr,
                  weight: TextWeight.bold,
                  color: AppColorConstants.themeColor,
                ),
                subtitle: Heading6Text(
                  message,
                ),
              ).vp(12).ripple(() {
                OverlaySupportEntry.of(context)!.dismiss();
                Get.to(() => CommentsScreen(
                      postId: referenceId,
                      handler: () {},
                      commentPostedCallback: () {},
                      commentDeletedCallback: () {},
                    ));
              }),
            ).setPadding(top: 50, left: 8, right: 8).round(10),
          );
        }, duration: const Duration(milliseconds: 4000));
      } else if (notificationType == 4) {
        // new competition added notification
      } else if (notificationType == 100) {
      } else if (notificationType == 101) {
        int liveId = int.parse(data['liveCallId'] as String);
        String channelName = data['channelName'];
        String agoraToken = data['token'];
        int userId = int.parse(data['userId'] as String);
        String body = data['body'];

        UsersApi.getOtherUser(
            userId: userId,
            resultCallback: (result) {
              showOverlayNotification((context) {
                return Container(
                  color: Colors.transparent,
                  child: Card(
                    color: AppColorConstants.cardColor,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                      leading: UserAvatarView(
                        size: 40,
                        user: result,
                      ),
                      title: Heading5Text(
                        liveString.tr,
                        weight: TextWeight.bold,
                        color: AppColorConstants.themeColor,
                      ),
                      subtitle: Heading6Text(
                        body,
                      ),
                    ).vp(12).ripple(() {
                      OverlaySupportEntry.of(context)!.dismiss();

                      Live live = Live(
                          channelName: channelName,
                          mainHostUserDetail: result,
                          token: agoraToken,
                          id: liveId);

                      agoraLiveController.joinAsAudience(live: live);
                    }),
                  ).setPadding(top: 50, left: 8, right: 8).round(10),
                );
              }, duration: const Duration(milliseconds: 4000));
            });
      }
    } else {
      // go to screen
      if (notificationType == 1) {
        int referenceId = int.parse(data['reference_id'] as String);
        // following notification
        Get.to(() => OtherUserProfile(userId: referenceId));
      } else if (notificationType == 2) {
        int referenceId = int.parse(data['reference_id'] as String);
        // comment notification
        Get.to(() => CommentsScreen(
              postId: referenceId,
              handler: () {},
              commentPostedCallback: () {},
              commentDeletedCallback: () {},
            ));
      } else if (notificationType == 4) {
        int referenceId = int.parse(data['reference_id'] as String);
        // new competition added notification
        Get.to(() => CompetitionDetailScreen(
              competitionId: referenceId,
              refreshPreviousScreen: () {},
            ));
      } else if (notificationType == 100) {
        int? roomId = data['room'] as int?;
        if (roomId != null) {
          ChatApi.getChatRoomDetail(roomId, resultCallback: (result) {
            Get.to(() => ChatDetail(chatRoom: result));
          });
        }
      } else if (notificationType == 101) {
        int liveId = int.parse(data['liveCallId'] as String);
        String channelName = data['channelName'];
        String agoraToken = data['token'];
        int userId = int.parse(data['userId'] as String);

        UsersApi.getOtherUser(
            userId: userId,
            resultCallback: (result) {
              Live live = Live(
                  channelName: channelName,
                  // isHosting: false,
                  mainHostUserDetail: result,
                  token: agoraToken,
                  id: liveId);

              agoraLiveController.joinAsAudience(live: live);
            });
      }
    }
  }
}

performActionOnCallNotificationBanner(
    Map<String, dynamic> data, bool accept, bool askConfirmation) {
  final AgoraCallController agoraCallController = Get.find();
  String channelName = data['channelName'] as String;
  String token = data['token'] as String;
  String callType = data['callType'] as String;
  String id = data['id'] as String;
  String uuid = data['uuid'] as String;
  String callerId = data['callerId'] as String;

  UsersApi.getOtherUser(
      userId: int.parse(callerId),
      resultCallback: (user) {
        Call call = Call(
            uuid: uuid,
            channelName: channelName,
            isOutGoing: true,
            opponent: user,
            token: token,
            callType: int.parse(callType),
            callId: int.parse(id));

        if (askConfirmation) {
          if (Get.context == null) {
            runApp(Phoenix(
                child: SocialifiedApp(
              startScreen: AcceptCallScreen(
                call: call,
              ),
            )));
          } else {
            Get.to(() => AcceptCallScreen(
                  call: call,
                ));
          }
        } else {
          if (accept) {
            agoraCallController.initiateAcceptCall(call: call);
          } else {
            agoraCallController.declineCall(call: call);
          }
        }
      });
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action

  if (notificationResponse.actionId == 'accept_action') {
    performActionOnCallNotificationBanner(
        jsonDecode(notificationResponse.payload!), true, false);
  } else if (notificationResponse.actionId == 'decline_action') {
    performActionOnCallNotificationBanner(
        jsonDecode(notificationResponse.payload!), false, false);
  } else {
    performActionOnCallNotificationBanner(
        jsonDecode(notificationResponse.payload!), false, true);
  }
}
