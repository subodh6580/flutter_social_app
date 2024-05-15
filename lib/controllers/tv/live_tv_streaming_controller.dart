import 'package:foap/apiHandler/apis/tv_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/manager/socket_manager.dart';
import 'package:foap/model/category_model.dart';
import 'package:foap/model/live_tv_model.dart';
import 'package:foap/model/tv_banner_model.dart';
import 'package:foap/screens/settings_menu/packages_screen.dart';
import 'package:foap/util/constant_util.dart';
import '../../helper/enum_linking.dart';
import '../../model/chat_message_model.dart';
import '../../model/tv_show_model.dart';
import 'package:foap/helper/list_extension.dart';

class TvStreamingController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();

  RxInt currentPage = 0.obs;
  RxMap<String, List<ChatMessageModel>> messagesMap =
      <String, List<ChatMessageModel>>{}.obs;

  RxBool showChatMessages = false.obs;
  RxList<TVBannersModel> banners = <TVBannersModel>[].obs;
  RxList<TvModel> tvs = <TvModel>[].obs;

  RxList<TvCategoryModel> categories = <TvCategoryModel>[].obs;
  RxList<TVShowModel> tvShows = <TVShowModel>[].obs;
  RxList<TVShowEpisodeModel> tvEpisodes = <TVShowEpisodeModel>[].obs;
  Rx<TvModel?> currentViewingTv = Rx<TvModel?>(null);

  RxInt currentBannerIndex = 0.obs;
  Rx<TVShowEpisodeModel?> selectedEpisode = Rx<TVShowEpisodeModel?>(null);

  RxInt currentSegment = (0).obs;
  Rx<TVShowModel?> showDetail = Rx<TVShowModel?>(null);
  Rx<TvModel?> tvChannelDetail = Rx<TvModel?>(null);

  RxBool showTopBar = true.obs;

  bool isLoadingFavTvs = false;
  int favTvsCurrentPage = 1;
  bool canLoadMoreFavTvs = true;

  bool isLoadingSubscribedTvs = false;
  int subscribedTvsCurrentPage = 1;
  bool canLoadMoreSubscribedTvs = true;

  bool isLoadingTvs = false;
  int tvsCurrentPage = 1;
  bool canLoadMoreTvs = true;

  bool isLoadingLiveTvs = false;
  int liveTvsCurrentPage = 1;
  bool canLoadMoreLiveTvs = true;

  clearCategories() {
    categories.clear();
    update();
  }

  clearTvs() {
    tvs.clear();

    currentViewingTv.value = null;

    isLoadingFavTvs = false;
    favTvsCurrentPage = 1;
    canLoadMoreFavTvs = true;

    isLoadingSubscribedTvs = false;
    subscribedTvsCurrentPage = 1;
    canLoadMoreSubscribedTvs = true;

    isLoadingTvs = false;
    tvsCurrentPage = 1;
    canLoadMoreTvs = true;

    isLoadingLiveTvs = false;
    liveTvsCurrentPage = 1;
    canLoadMoreLiveTvs = true;
  }

  setCurrentViewingTv(TvModel tvModel) {
    currentViewingTv.value = tvModel;
    update();
  }

  segmentChanged(int segment) {
    currentSegment.value = segment;
  }

  updateBannerSlider(int index) {
    currentBannerIndex.value = index;
  }

  toggleTopBar() {
    showTopBar.value = !showTopBar.value;
  }

  getTvCategories() {
    TVModuleApi.getTVCategories(resultCallback: (result) {
      categories.value =
          result.where((element) => element.tvs.isNotEmpty).toList();
      categories.refresh();
      update();
    });
  }

  getTvBanners() {
    TVModuleApi.getTvBanners(resultCallback: (result) {
      banners.value = result;
      update();
    });
  }

  getLiveTv({required VoidCallback callback}) {
    if (canLoadMoreLiveTvs) {
      TVModuleApi.getTvs(
          page: liveTvsCurrentPage,
          resultCallback: (result, metaData) {
            tvs.addAll(result);
            tvs.unique((e) => e.id);

            canLoadMoreLiveTvs = tvs.length >= metaData.perPage;
            if (canLoadMoreLiveTvs) {
              liveTvsCurrentPage += 1;
            }
            update();
          });
    }
  }

  getTvs({int? categoryId, String? name, required VoidCallback callback}) {
    if (canLoadMoreTvs) {
      TVModuleApi.getTvs(
          page: tvsCurrentPage,
          categoryId: categoryId,
          name: name,
          resultCallback: (result, metaData) {
            tvs.addAll(result);
            tvs.unique((e) => e.id);

            canLoadMoreTvs = tvs.length >= metaData.perPage;
            if (canLoadMoreTvs) {
              tvsCurrentPage += 1;
            }
            update();
          });
    }
  }

  getFavTvs() {
    if (canLoadMoreFavTvs == true) {
      isLoadingFavTvs = true;

      TVModuleApi.getFavLiveTvs(
          page: favTvsCurrentPage,
          resultCallback: (result, metadata) {
            tvs.addAll(result);
            tvs.unique((e) => e.id);

            canLoadMoreFavTvs = tvs.length >= metadata.perPage;
            isLoadingFavTvs = false;
            favTvsCurrentPage += 1;

            update();
          });
    }
  }

  getSubscribedTvs() {
    if (canLoadMoreSubscribedTvs == true) {
      isLoadingSubscribedTvs = true;

      TVModuleApi.getSubscribedLiveTvs(
          page: subscribedTvsCurrentPage,
          resultCallback: (result, metadata) {
            tvs.addAll(result);
            tvs.unique((e) => e.id);

            isLoadingSubscribedTvs = false;
            subscribedTvsCurrentPage += 1;
            canLoadMoreSubscribedTvs = tvs.length >= metadata.perPage;

            update();
          });
    }
  }

  getTvShows({int? liveTvId, String? name}) {
    TVModuleApi.getTVShows(resultCallback: (result) {
      tvShows.value = result;
      tvShows.refresh();
      update();
    });
  }

  getTvShowById(int showId, Function() completionCallBack) {
    TVModuleApi.getTVShowById(
        showId: showId,
        resultCallback: (result) {
          showDetail.value = result;
          update();
          completionCallBack();
        });
  }

  getTvChannelById(int tvId, Function() completionCallBack) {
    TVModuleApi.getTVChannelById(
        tvId: tvId,
        resultCallback: (result) {
          tvChannelDetail.value = result;
          update();
          completionCallBack();
        });
  }

  getTvShowEpisodes({int? showId, String? name}) {
    TVModuleApi.getTVShowEpisodes(
        showId: showId,
        name: name,
        resultCallback: (result) {
          tvEpisodes.value = result;
          tvEpisodes.refresh();
          playEpisode(tvEpisodes.first);
          update();
        });
  }

  playEpisode(TVShowEpisodeModel episode) {
    selectedEpisode.value = episode;
    selectedEpisode.refresh();
  }

  subscribeTv(TvModel tvModel, Function(bool) completionCallBack) {
    getTvChannelById(tvModel.id, () {
      if (_userProfileManager.user.value!.coins >=
          tvChannelDetail.value!.coinsNeededToUnlock) {
        TVModuleApi.subscribeTv(
            tvModel: tvModel, resultCallback: completionCallBack);
      } else {
        Get.to(() => const PackagesScreen());
      }
    });
  }

  stopWatchingTv(TvModel tvModel, Function(bool) completionCallBack) {
    TVModuleApi.stopWatchingTv(
        tvModel: tvModel, resultCallback: completionCallBack);
  }

  joinTv(int id) {
    var liveTvId = 'tv_$id';

    var message = {
      'userId': _userProfileManager.user.value!.id,
      'liveTvId': liveTvId,
    };

    getIt<SocketManager>().emit(SocketConstants.joinLiveTv, message);
  }

  favUnfavTv(TvModel tv) {
    currentViewingTv.value?.isFav = tv.isFav == 1 ? 0 : 1;
    tv.isFav = currentViewingTv.value!.isFav;

    currentViewingTv.refresh();

    categories.value = categories.map((category) {
      var tvs = category.tvs.map((currentTvInIteration) {
        if (tv.id == currentTvInIteration.id) {
          currentTvInIteration.isFav = tv.isFav;
        }
        return currentTvInIteration;
      }).toList();
      category.tvs = tvs;
      return category;
    }).toList();

    tvs.value = tvs.map((currentTvInIteration) {
      if (tv.id == currentTvInIteration.id) {
        currentTvInIteration.isFav = tv.isFav;
      }
      return currentTvInIteration;
    }).toList();

    // update();

    TVModuleApi.likeUnlikeTv(currentViewingTv.value?.isFav == 1 ? true : false,
        currentViewingTv.value!.id);
  }

  hideMessagesView() {
    showChatMessages.value = false;
    showChatMessages.refresh();
  }

  showMessagesView() {
    showChatMessages.value = true;
    showChatMessages.refresh();
  }

  // currentPageChanged(int index) {
  //   currentPage.value = index;
  //   currentPage.refresh();
  // }

  newMessageReceived(ChatMessageModel message) {
    addNewMessage(message, int.parse(message.liveTvId.split('_').last));
  }

  sendTextMessage(String messageText, int id) {
    String localMessageId = randomId();
    var liveTvId = 'tv_$id';
    String encrtyptedMessage = messageText; //.encrypted();

    var message = {
      'userId': _userProfileManager.user.value!.id,
      'liveTvId': liveTvId,
      'local_message_id': localMessageId,
      'messageType': messageTypeId(MessageContentType.text),
      'message': encrtyptedMessage,
      'picture': _userProfileManager.user.value!.picture,
      'username': _userProfileManager.user.value!.userName,
      'created_at': (DateTime.now().millisecondsSinceEpoch / 1000).round()
    };

    //save message to socket server
    getIt<SocketManager>().emit(SocketConstants.sendMessageInLiveTv, message);

    ChatMessageModel localMessageModel = ChatMessageModel();
    localMessageModel.localMessageId = localMessageId;
    localMessageModel.roomId = id;
    localMessageModel.userName = youString.tr;
    localMessageModel.senderId = _userProfileManager.user.value!.id;
    localMessageModel.messageType = messageTypeId(MessageContentType.text);
    localMessageModel.messageContent = messageText;

    localMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();

    addNewMessage(localMessageModel, id);
  }

  addNewMessage(ChatMessageModel message, int tvId) {
    List<ChatMessageModel> messages = (messagesMap[tvId.toString()] ?? []);

    messages.add(message);
    messagesMap[tvId.toString()] = messages;
    messagesMap.refresh();
    update();
  }
}
