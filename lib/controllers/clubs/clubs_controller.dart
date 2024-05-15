import 'package:foap/apiHandler/apis/club_api.dart';
import 'package:foap/helper/imports/club_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../model/category_model.dart';
import 'package:foap/helper/list_extension.dart';

class ClubsController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();

  RxList<ClubModel> clubs = <ClubModel>[].obs;
  RxList<ClubModel> topClubs = <ClubModel>[].obs;
  RxList<ClubModel> trendingClubs = <ClubModel>[].obs;

  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxList<ClubMemberModel> members = <ClubMemberModel>[].obs;
  RxList<ClubInvitation> invitations = <ClubInvitation>[].obs;

  RxBool isLoadingCategories = false.obs;

  int clubsPage = 1;
  bool canLoadMoreClubs = true;
  RxBool isLoadingClubs = false.obs;

  int topClubsPage = 1;
  bool canLoadMoreTopClubs = true;
  RxBool isLoadingTopClubs = false.obs;

  int trendingClubsPage = 1;
  bool canLoadMoreTrendingClubs = true;
  RxBool isLoadingTrendingClubs = false.obs;

  int invitationsPage = 1;
  bool canLoadMoreInvitations = true;
  RxBool isLoadingInvitations = false.obs;

  int membersPage = 1;
  bool canLoadMoreMembers = true;
  bool isLoadingMembers = false;

  RxInt segmentIndex = (0).obs;

  String? _name;
  int? _categoryId;
  int? _userId;
  int? _isJoined;

  clear() {
    isLoadingClubs.value = false;
    clubs.clear();
    clubsPage = 1;
    canLoadMoreClubs = true;

    invitationsPage = 1;
    canLoadMoreInvitations = true;
    isLoadingInvitations.value = false;
    invitations.clear();

    topClubsPage = 1;
    canLoadMoreTopClubs = true;
    isLoadingTopClubs.value = false;
    topClubs.clear();

    trendingClubsPage = 1;
    canLoadMoreTrendingClubs = true;
    isLoadingTrendingClubs.value = false;
    trendingClubs.clear();

    segmentIndex.value = 0;

    _name = null;
    _categoryId = null;
    _userId = null;
    _isJoined = null;

  }

  clearMembers() {
    isLoadingMembers = false;
    members.value = [];
    membersPage = 1;
    canLoadMoreMembers = true;
  }

  refreshClubs() {
    clear();
    getClubs();
  }

  setSearchText(String? name) {
    clear();
    _name = name;
    getClubs();
  }

  setCategoryId(int? categoryId) {
    clear();

    _categoryId = categoryId;
    getClubs();
  }

  setIsJoined(int? isJoined) {
    clear();
    _isJoined = isJoined;
    getClubs();
  }

  setUserId(int? userId) {
    clear();
    _userId = userId;
    getClubs();
  }

  selectedSegmentIndex({required int index}) {
    if (isLoadingClubs.value == true) {
      return;
    }
    update();
    if (index == 0 && (segmentIndex.value != index)) {
      clear();
      getClubs();
    } else if (index == 1 && (segmentIndex.value != index)) {
      clear();
      setIsJoined(1);
    } else if (index == 2 && (segmentIndex.value != index)) {
      clear();
      setUserId(_userProfileManager.user.value!.id);
    } else if (index == 3 && (segmentIndex.value != index)) {
      getClubInvitations();
    }

    segmentIndex.value = index;
  }

  getClubs() {
    if (canLoadMoreClubs) {
      ClubApi.getClubs(
          name: _name,
          categoryId: _categoryId,
          userId: _userId,
          isJoined: _isJoined,
          page: clubsPage,
          resultCallback: (result, metadata) {
            clubs.addAll(result);
            clubs.unique((e) => e.id);
            isLoadingClubs.value = false;

            canLoadMoreClubs = result.length >= metadata.perPage;

            clubsPage += 1;
            update();
          });
    }
  }

  getTopClubs() {
    if (canLoadMoreTopClubs) {
      ClubApi.getTopClubs(
          page: topClubsPage,
          resultCallback: (result, metadata) {
            topClubs.addAll(result);
            topClubs.unique((e) => e.id);
            isLoadingTopClubs.value = false;

            canLoadMoreTopClubs = result.length >= metadata.perPage;

            topClubsPage += 1;
            update();
          });
    }
  }

  getTrendingClubs() {
    if (canLoadMoreTrendingClubs) {
      ClubApi.getTrendingClubs(
          page: trendingClubsPage,
          resultCallback: (result, metadata) {
            trendingClubs.addAll(result);
            trendingClubs.unique((e) => e.id);
            isLoadingTrendingClubs.value = false;

            canLoadMoreTrendingClubs = result.length >= metadata.perPage;

            trendingClubsPage += 1;
            update();
          });
    }
  }

  getClubInvitations() {
    if (canLoadMoreInvitations) {
      isLoadingInvitations.value = true;
      ClubApi.getClubInvitations(
          page: invitationsPage,
          resultCallback: (result, metadata) {
            invitations.addAll(result);
            invitations.unique((e) => e.id);

            isLoadingInvitations.value = false;

            invitationsPage += 1;
            canLoadMoreInvitations = result.length >= metadata.perPage;

            update();
          });
    }
  }

  clubDeleted(ClubModel club) {
    clubs.removeWhere((element) => element.id == club.id);
    clubs.refresh();
  }

  getMembers({int? clubId}) {
    if (canLoadMoreMembers) {
      isLoadingMembers = true;
      ClubApi.getClubMembers(
          clubId: clubId,
          page: membersPage,
          resultCallback: (result, metadata) {
            members.addAll(result);
            members.unique((e) => e.id);

            isLoadingMembers = false;

            membersPage += 1;
            canLoadMoreMembers = result.length >= metadata.perPage;

            update();
          });
    }
  }

  getCategories() {
    isLoadingCategories.value = true;
    ClubApi.getClubCategories(resultCallback: (result) {
      categories.value = result;
      isLoadingCategories.value = false;

      update();
    });
  }

  joinClub(ClubModel club) {
    if (club.isRequestBased == true) {
      clubs.value = clubs.map((element) {
        if (element.id == club.id) {
          element.isRequested = true;
        }
        return element;
      }).toList();

      clubs.refresh();

      ClubApi.sendClubJoinRequest(clubId: club.id!);
    } else {
      clubs.value = clubs.map((element) {
        if (element.id == club.id) {
          element.isJoined = true;
        }
        return element;
      }).toList();

      clubs.refresh();

      ClubApi.joinClub(clubId: club.id!, resultCallback: () {});
    }
  }

  leaveClub(ClubModel club) {
    clubs.value = clubs.map((element) {
      if (element.id == club.id) {
        element.isJoined = false;
      }
      return element;
    }).toList();

    clubs.refresh();
    ClubApi.leaveClub(clubId: club.id!);
  }

  acceptClubInvitation(ClubInvitation invitation) {
    invitations.remove(invitation);
    invitations.refresh();
    ClubApi.acceptDeclineClubInvitation(
        invitationId: invitation.id!, replyStatus: 10);
  }

  declineClubInvitation(ClubInvitation invitation) {
    invitations.remove(invitation);
    invitations.refresh();
    ClubApi.acceptDeclineClubInvitation(
        invitationId: invitation.id!, replyStatus: 3);
  }

  removeMemberFromClub(ClubModel club, ClubMemberModel member) {
    members.remove(member);
    update();

    ClubApi.removeMemberFromClub(clubId: club.id!, userId: member.id);
  }

  deleteClub({required ClubModel club, required VoidCallback callback}) {
    ClubApi.deleteClub(
      club.id!,
    );
    Get.back();
    callback();

  }
}
