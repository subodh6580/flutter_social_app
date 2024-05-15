import 'package:foap/helper/imports/common_import.dart';
import 'package:collection/collection.dart';
import 'package:foap/model/post_model.dart';

class CompetitionPositionModel {
  int id = 0;
  int competitionId = 0;
  String title = '';
  int awardValue = 0;
  int? winnerUserId;

  int? winnerPostId;

  int? awardedAt;
  PostModel? post;

  CompetitionPositionModel();

  factory CompetitionPositionModel.fromJson(dynamic json) {
    CompetitionPositionModel model = CompetitionPositionModel();
    model.id = json['id'];
    model.title = json['title'];
    model.competitionId = json['competition_id'];
    model.awardValue = json['award_value'];
    model.winnerUserId = json['winner_user_id'];
    model.winnerPostId = json['winner_post_id'];
    model.awardedAt = json['awarded_at'];
    model.post = json['post'] == null ? null : PostModel.fromJson(json['post']);

    return model;
  }
}

class CompetitionModel {
  int id = 0;
  String title = '';
  String photo = '';
  String description = '';

  int awardType = 0;

  int joiningFee = 0;
  int isJoined = 0;
  int competitionMediaType = 0;

  bool isWinner = false;
  bool isOngoing = false;
  bool isPast = false;
  String timeLeft = '';

  List<String> exampleImages = [];
  List<PostModel> posts = [];

  String winnerId = '';
  List<PostModel> winnerPost = [];
  List<CompetitionPositionModel> competitionPositions = [];

  CompetitionModel();

  factory CompetitionModel.fromJson(dynamic json) {
    CompetitionModel model = CompetitionModel();
    model.id = json['id'];
    model.title = json['title'];
    model.photo = json['imageUrl'];
    model.description = json['description'] ?? '';

    model.awardType = json['award_type'];
    // model.awardPrice = json['award_type'] == 1 ? json['price'] : 0;
    // model.awardCoin = json['award_type'] == 1 ? 0 : json['coin'];
    model.joiningFee = json['joining_fee'] ?? 0;
    model.isJoined = json['is_joined'];
    model.competitionMediaType = json['competition_media_type'];

    var startDate =
        DateTime.fromMillisecondsSinceEpoch(json['start_date'] * 1000).toUtc();
    var endDate =
        DateTime.fromMillisecondsSinceEpoch(json['end_date'] * 1000).toUtc();

    // model.isUpcoming = startDate.isAfter(DateTime.now());

    // if (model.isUpcoming) {
    //   model.timeLeft =
    //       '${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('startingIn_text')} ${getCompetitionTimeString(startDate, DateTime.now())}';
    // } else

    model.exampleImages = [];
    if (json['expampleImages'] != null && json['expampleImages'].length > 0) {
      model.exampleImages =
          List<String>.from(json['expampleImages'].map((x) => x));
    }

    model.posts = [];
    if (json['post'] != null && json['post'].length > 0) {
      model.posts =
          List<PostModel>.from(json['post'].map((x) => PostModel.fromJson(x)));
    }

    model.competitionPositions = [];
    if (json['competitionPosition'] != null &&
        json['competitionPosition'].length > 0) {
      model.competitionPositions = List<CompetitionPositionModel>.from(
          json['competitionPosition']
              .map((x) => CompetitionPositionModel.fromJson(x)));
    }

    model.isOngoing =
        startDate.isBefore(DateTime.now()) && endDate.isAfter(DateTime.now());
    model.isPast = endDate.isBefore(DateTime.now());
    model.isWinner = json['winner_id'] != null;

    if (model.isOngoing) {
      model.timeLeft = '${getCompetitionTimeString(DateTime.now(), endDate)} ${leftString.tr}';
    } else if (model.isPast) {
      model.timeLeft =
          '${endedString.tr} ${getCompetitionTimeString(endDate, DateTime.now())} ${agoString.tr}';
    }

    model.winnerId =
        json['winner_id'] == null ? '' : json['winner_id'].toString();
    model.winnerPost = [];
    if (json['winnerPost'] != null && json['winnerPost'].length > 0) {
      model.winnerPost = List<PostModel>.from(
          json['winnerPost'].map((x) => PostModel.fromJson(x)));
    }
    return model;
  }

  int totalAwardValue() {
    return competitionPositions.map((e) => e.awardValue).sum;
  }

  int awardedValueForUser(int userId) {
    return competitionPositions
        .where((e) => e.winnerUserId == userId)
        .first
        .awardValue;
  }

  bool winnerAnnounced() {
    return competitionPositions
        .where((element) => element.winnerUserId != null)
        .isNotEmpty;
  }

  int mainWinnerId() {
    return competitionPositions
        .where((element) => element.winnerUserId != null)
        .first
        .winnerUserId!;
  }
}

String getCompetitionTimeString(DateTime date1, DateTime date2) {
  DateTime earliest = date1.isBefore(date2) ? date1 : date2;
  DateTime latest = earliest == date1 ? date2 : date1;

  final days = latest.difference(earliest).inDays;
  if (days == 0) {
    final hours = latest.difference(earliest).inHours;
    if (hours == 0) {
      final minutes = latest.difference(earliest).inMinutes;
      return minutes == 0
          ? feMinutesString.tr
          : '$minutes ${minutesString.tr}';
    } else {
      return '$hours ${hoursString.tr}';
    }
  } else {
    return '$days ${daysString.tr}';
  }
}
