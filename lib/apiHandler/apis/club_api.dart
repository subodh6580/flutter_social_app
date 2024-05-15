import 'package:foap/apiHandler/api_wrapper.dart';
import '../../helper/imports/common_import.dart';
import '../../model/api_meta_data.dart';
import '../../model/category_model.dart';
import '../../model/club_invitation.dart';
import '../../model/club_join_request.dart';
import '../../model/club_member_model.dart';
import '../../model/club_model.dart';

class ClubApi {
  static getClubCategories(
      {required Function(List<CategoryModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.getClubCategories;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['category'];

        resultCallback(List<CategoryModel>.from(
            items.map((x) => CategoryModel.fromJson(x))));
      }
    });
  }

  static createClub(
      {required int categoryId,
      required int privacyMode,
      required int isOnRequestType,
      required int enableChatRoom,
      required String name,
      required String image,
      required String description,
      required Function(int) resultCallback}) async {
    var url = NetworkConstantsUtil.createClub;

    ApiWrapper().postApi(url: url, param: {
      "category_id": categoryId.toString(),
      'privacy_type': privacyMode.toString(),
      'is_request_based': isOnRequestType.toString(),
      'is_chat_room': enableChatRoom.toString(),
      'name': name,
      'image': image,
      'description': description
    }).then((result) {
      if (result?.success == true) {
        resultCallback(result!.data['club_id']);
      }
    });
  }

  static updateClub(
      {required int categoryId,
      required int clubId,
      required int privacyMode,
      required String name,
      required String image,
      required String description}) async {
    var url = NetworkConstantsUtil.updateClub + clubId.toString();

    ApiWrapper().putApi(url: url, param: {
      "category_id": categoryId.toString(),
      'privacy_type': privacyMode.toString(),
      'name': name,
      'image': image,
      'description': description
    }).then((result) {
      if (result?.success == true) {}
    });
  }

  static deleteClub(int clubId) async {
    var url = NetworkConstantsUtil.deleteClub + clubId.toString();
    EasyLoading.show(status: loadingString.tr);

    ApiWrapper().deleteApi(url: url).then((result) {
      EasyLoading.dismiss();
      if (result?.success == true) {}
    });
  }

  static sendClubInvite({
    required int clubId,
    required String userIds,
    required String message,
  }) async {
    var url = NetworkConstantsUtil.sendClubInvite;

    ApiWrapper().postApi(url: url, param: {
      "club_id": clubId.toString(),
      'user_ids': userIds,
      'message': message,
    }).then((result) {
      if (result?.success == true) {}
    });
  }

  static getClubInvitations(
      {int page = 1,
      required Function(List<ClubInvitation>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.clubJoinInvites;
    url = '$url&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['invitation']['items'];
        resultCallback(
            List<ClubInvitation>.from(
                items.map((x) => ClubInvitation.fromJson(x))),
            APIMetaData.fromJson(result.data['invitation']['_meta']));
      }
    });
  }

  static acceptDeclineClubInvitation(
      {required int invitationId, required int replyStatus}) async {
    var url = NetworkConstantsUtil.replyOnInvitation;

    ApiWrapper().postApi(url: url, param: {
      'id': invitationId.toString(),
      'status': replyStatus.toString()
    }).then((result) {
      if (result?.success == true) {}
    });
  }

  static sendClubJoinRequest({
    required int clubId,
  }) async {
    var url = NetworkConstantsUtil.sendClubJoinRequest;

    ApiWrapper().postApi(url: url, param: {
      "club_id": clubId.toString(),
      'message': '',
    }).then((result) {
      if (result?.success == true) {}
    });
  }

  static getClubJoinRequests(
      {required int clubId,
      int page = 1,
      required Function(List<ClubJoinRequest>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.clubJoinRequestList;
    url = url.replaceAll('{{club_id}}', clubId.toString());
    url = '$url&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['join_request']['items'];
        resultCallback(
            List<ClubJoinRequest>.from(
                items.map((x) => ClubJoinRequest.fromJson(x))),
            APIMetaData.fromJson(result.data['join_request']['_meta']));
      }
    });
  }

  static acceptDeclineClubJoinRequest(
      {required int requestId, required int replyStatus}) async {
    var url = NetworkConstantsUtil.clubJoinRequestReply;

    ApiWrapper().postApi(url: url, param: {
      'id': requestId.toString(),
      'status': replyStatus.toString()
    }).then((result) {
      if (result?.success == true) {}
    });
  }

  static getClubs(
      {String? name,
      int? categoryId,
      int? userId,
      int? isJoined,
      int page = 1,
      required Function(List<ClubModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.searchClubs;
    if (userId != null) {
      url = '$url&user_id=$userId';
    }
    if (categoryId != null) {
      url = '$url&category_id=$categoryId';
    }
    if (name != null && name.isNotEmpty) {
      url = '$url&name=$name';
    }
    if (isJoined != null) {
      url = '$url&my_joined_club=$isJoined';
    }
    url = '$url&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['club']['items'];
        resultCallback(
            List<ClubModel>.from(items.map((x) => ClubModel.fromJson(x))),
            APIMetaData.fromJson(result.data['club']['_meta']));
      }
    });
  }

  static getTopClubs(
      {String? name,
      int? categoryId,
      int? userId,
      int? isJoined,
      int page = 1,
      required Function(List<ClubModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.topClubs;
    if (userId != null) {
      url = '$url&user_id=$userId';
    }
    if (categoryId != null) {
      url = '$url&category_id=$categoryId';
    }
    if (name != null && name.isNotEmpty) {
      url = '$url&name=$name';
    }
    if (isJoined != null) {
      url = '$url&my_joined_club=$isJoined';
    }
    url = '$url&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['club']['items'];
        resultCallback(
            List<ClubModel>.from(items.map((x) => ClubModel.fromJson(x))),
            APIMetaData.fromJson(result.data['club']['_meta']));
      }
    });
  }

  static getTrendingClubs(
      {String? name,
      int? categoryId,
      int? userId,
      int? isJoined,
      int page = 1,
      required Function(List<ClubModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.trendingClubs;
    if (userId != null) {
      url = '$url&user_id=$userId';
    }
    if (categoryId != null) {
      url = '$url&category_id=$categoryId';
    }
    if (name != null && name.isNotEmpty) {
      url = '$url&name=$name';
    }
    if (isJoined != null) {
      url = '$url&my_joined_club=$isJoined';
    }
    url = '$url&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['club']['items'];
        resultCallback(
            List<ClubModel>.from(items.map((x) => ClubModel.fromJson(x))),
            APIMetaData.fromJson(result.data['club']['_meta']));
      }
    });
  }

  static getClubMembers(
      {int? clubId,
      int page = 1,
      required Function(List<ClubMemberModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.clubMembers + clubId.toString();
    url = '$url&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['userList']['items'];
        resultCallback(
            List<ClubMemberModel>.from(
                items.map((x) => ClubMemberModel.fromJson(x))),
            APIMetaData.fromJson(result.data['userList']['_meta']));
      }
    });
  }

  static joinClub(
      {required int clubId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.joinClub;

    ApiWrapper()
        .postApi(url: url, param: {'id': clubId.toString()}).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static leaveClub({
    required int clubId,
  }) async {
    var url = NetworkConstantsUtil.leaveClub;

    ApiWrapper()
        .postApi(url: url, param: {'id': clubId.toString()}).then((result) {
      if (result?.success == true) {}
    });
  }

  static removeMemberFromClub({
    required int clubId,
    required int userId,
  }) async {
    var url = NetworkConstantsUtil.removeUserFromClub;

    ApiWrapper().postApi(url: url, param: {
      "club_user_id": userId.toString(),
      'id': clubId.toString(),
    }).then((result) {
      if (result?.success == true) {}
    });
  }
}
