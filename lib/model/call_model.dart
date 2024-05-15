import 'package:foap/helper/imports/common_import.dart';

class Call {
  final String uuid;

  final String channelName;
  final bool isOutGoing;
  final UserModel opponent;
  final String token;
  final int callId;
  final int callType;

  Call(
      {required this.uuid,
      required this.channelName,
      required this.isOutGoing,
      required this.opponent,
      required this.token,
      required this.callType,
      required this.callId});
}

class Live {
  UserProfileManager userProfileManager = Get.find();
  final String channelName;

  // List<LiveCallHostUser> battleUsers = [];
  UserModel? invitedUserDetail;
  UserModel mainHostUserDetail;
  BattleDetail? battleDetail;

  final String token;
  final int id;

  Live({
    required this.channelName,
    required this.mainHostUserDetail,
    // required this.battleUsers,
    this.invitedUserDetail,
    required this.token,
    required this.id,
  });

  bool isPendingInvitation() {
    return invitedUserDetail != null;
  }

  bool get amIMainHostInLive {
    return mainHostUserDetail.id == userProfileManager.user.value!.id;
  }

  bool get amIHostInLive {
    if ((battleDetail?.battleUsers ?? []).isNotEmpty) {
      return battleDetail!.amIHostInLive;
    }
    return mainHostUserDetail.id == userProfileManager.user.value!.id;
  }

  BattleStatus get battleStatus {
    if (battleDetail == null) {
      return BattleStatus.none;
    }
    return battleDetail!.battleStatus;
  }

  bool get canInvite {
    return invitedUserDetail == null && battleStatus == BattleStatus.none;
  }

  clearBattleData() {
    battleDetail = null;
    invitedUserDetail = null;
  }
}

class BattleDetail {
  UserProfileManager userProfileManager = Get.find();

  final int id;
  final int mainHostId;
  final int opponentHostId;
  final int timeRemainingInBattle;
  final int totalBattleTime;

  List<LiveCallHostUser> battleUsers = [];
  BattleStatus battleStatus = BattleStatus.none;

  BattleDetail({
    required this.id,
    required this.mainHostId,
    required this.opponentHostId,
    required this.timeRemainingInBattle,
    required this.totalBattleTime
  });

  factory BattleDetail.fromJson(Map<String, dynamic> json) => BattleDetail(
      id: json["id"],
      mainHostId: json["super_host_user_id"],
      opponentHostId: json["host_user_id"],
      timeRemainingInBattle: json["timeToEnd"],
      totalBattleTime: json["total_allowed_time"]);

  bool get amIMainHostInLive {
    return mainHost.userDetail.id == userProfileManager.user.value!.id;
  }

  bool get amIHostInLive {
    if (battleUsers.isEmpty) {
      return (mainHost.userDetail.id == userProfileManager.user.value!.id);
    }
    return battleUsers
            .where((element) =>
                element.userDetail.id == userProfileManager.user.value!.id)
            .isNotEmpty ||
        amIMainHostInLive;
  }

  LiveCallHostUser get mainHost {
    return battleUsers.where((element) => element.isMainHost == true).first;
  }

  LiveCallHostUser get opponentHost {
    return battleUsers.where((element) => element.isMainHost == false).first;
  }

  LiveCallHostUser get otherHost {
    return battleUsers
        .where((element) =>
            element.userDetail.id != userProfileManager.user.value!.id)
        .first;
  }

  LiveCallHostUser get loggedInHost {
    return battleUsers
        .where((element) =>
            element.userDetail.id == userProfileManager.user.value!.id)
        .first;
  }

  bool isMainHost(int userId) {
    return mainHost.userDetail.id == userProfileManager.user.value!.id;
  }

  bool isHost(int userId) {
    return battleUsers
        .where((element) => element.userDetail.id == userId)
        .isNotEmpty;
  }

  double percentageOfCoinsFor(LiveCallHostUser host) {
    if (battleUsers.isEmpty) {
      return 0.5;
    }
    LiveCallHostUser otherHost = battleUsers
        .where((element) => element.userDetail.id != host.userDetail.id)
        .first;
    if (host.totalCoins == 0 && otherHost.totalCoins == 0) {
      return 0.5;
    }

    return (host.totalCoins / (host.totalCoins + otherHost.totalCoins));
  }

  LiveCallHostUser get winnerHost {
    LiveCallHostUser userWithHighestCoins = battleUsers[0];

    for (int i = 1; i < battleUsers.length; i++) {
      if (battleUsers[i].totalCoins > userWithHighestCoins.totalCoins) {
        userWithHighestCoins = battleUsers[i];
      }
    }

    return userWithHighestCoins;
  }

  LiveBattleResultType get resultType {
    if (battleUsers[0].totalCoins == battleUsers[1].totalCoins) {
      return LiveBattleResultType.draw;
    }
    return LiveBattleResultType.winner;
  }
}

