import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foap/util/app_config_constants.dart';

enum ThemeIcon {
  home,
  cart,
  setting,
  account,
  group,
  camera,
  gallery,
  mention,
  wallpaper,
  // cameraFront,
  // cameraRear,
  cameraSwitch,
  videoCameraOff,
  videoCamera,
  emptyCheckbox,
  selectedCheckbox,
  search,
  downArrow,
  arrowUp,
  star,
  filledStar,
  checkMark,
  sending,
  sent,
  delivered,
  read,
  edit,
  eye,
  filterIcon,
  sort,
  logout,
  review,
  circle,
  circleOutline,
  multiplePosts,
  fav,
  favFilled,
  close,
  sticker,
  gif,
  gift,
  checkMarkWithCircle,
  security,
  bike,
  clock,
  calendar,
  offer,
  orders,
  privacyPolicy,
  info,
  terms,
  add,
  selectedRadio,
  more,
  moreVertical,
  wallet,
  dashboard,
  nextArrow,
  download,
  pause,
  backArrow,
  menuIcon,
  password,
  email,
  hidePwd,
  mobile,
  callEnd,
  invite,
  name,
  showPwd,
  notification,
  language,
  discount,
  share,
  addressType,
  addressPin,
  plus,
  minus,
  avatar,
  card,
  thumbsUp,
  mic,
  micOff,
  book,
  helpHand,
  about,
  contacts,
  files,
  location,
  drawing,
  fullScreen,
  play,
  stop,
  videoPost,
  reels,
  delete,
  message,
  chat,
  chatBordered,
  randomChat,
  closeCircle,
  bed,
  map,
  news,
  buildings,
  bathTub,
  area,
  send,
  fwd,
  reply,
  bookMark,
  bookMarked,
  lock,
  selectionType,
  report,
  hide,
  addCircle,
  userGroup,
  public,
  request,
  unSelectedRadio,
  diamond,
  music,
  dating,
  acceptCall,
  declineCall
}

class ThemeIconWidget extends StatelessWidget {
  final ThemeIcon icon;
  final double? size;
  final Color? color;

  const ThemeIconWidget(this.icon, {Key? key, this.size, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return getIcon();
  }

  Widget getIcon() {
    switch (icon) {
      case ThemeIcon.home:
        return Icon(
          Icons.home,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.cart:
        return Icon(
          Icons.shopping_cart_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.setting:
        return Icon(
          Icons.settings_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.search:
        return Icon(
          Icons.search,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.downArrow:
        return Icon(
          Icons.keyboard_arrow_down,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.arrowUp:
        return SvgPicture.asset(
          'assets/svg/outline/Arrow - Up 2.svg',
          height: size ?? 20,
          // color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.star:
        return Icon(
          Icons.star_border,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.filledStar:
        return Icon(
          Icons.star,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.diamond:
        return Icon(
          Icons.diamond,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );

      case ThemeIcon.checkMark:
        return Icon(
          Icons.check,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.edit:
        return Icon(
          Icons.edit_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.filterIcon:
        return Icon(
          Icons.filter_alt_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.sort:
        return Icon(
          Icons.sort,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.logout:
        return Icon(
          Icons.logout_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.review:
        return Icon(
          Icons.library_books_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );

      case ThemeIcon.circle:
        return Icon(
          Icons.circle,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.circleOutline:
        return Icon(
          Icons.circle_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.fav:
        return Icon(
          Icons.favorite_border_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.favFilled:
        return Icon(
          Icons.favorite,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.close:
        return Icon(
          Icons.close,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.checkMarkWithCircle:
        return Icon(
          Icons.check_circle_outline,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.security:
        return Icon(
          Icons.security,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.bike:
        return Icon(
          Icons.delivery_dining_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.clock:
        return Icon(
          Icons.timer,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.calendar:
        return Icon(
          Icons.calendar_month,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.offer:
        return Icon(
          Icons.local_offer_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.orders:
        return Icon(
          Icons.list_alt_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.account:
        return Icon(
          Icons.person_outline,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.group:
        return Icon(
          Icons.group,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.privacyPolicy:
        return Icon(
          Icons.policy_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.info:
        return Icon(
          Icons.info,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.terms:
        return Icon(
          Icons.verified_user_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.add:
        return Icon(
          Icons.add,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.selectedRadio:
        return Icon(
          Icons.radio_button_checked,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.unSelectedRadio:
        return Icon(
          Icons.radio_button_off_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.more:
        return Icon(
          Icons.more_horiz,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.moreVertical:
        return Icon(
          Icons.more_vert,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.wallet:
        return Icon(
          Icons.account_balance_wallet,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.dashboard:
        return Icon(
          Icons.dashboard,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.nextArrow:
        return Icon(
          Icons.arrow_forward_ios,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.backArrow:
        return Icon(
          Icons.arrow_back_ios,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.menuIcon:
        return Icon(
          Icons.menu,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.eye:
        return Icon(
          Icons.remove_red_eye,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.password:
        return Icon(
          Icons.password_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.email:
        return Icon(
          Icons.email_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.showPwd:
        return Icon(
          Icons.visibility_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.hidePwd:
        return Icon(
          Icons.visibility_off_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.mobile:
        return Icon(
          Icons.phone_enabled_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );

      case ThemeIcon.name:
        return Icon(
          Icons.person_outline,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );

      case ThemeIcon.notification:
        return Icon(
          Icons.notifications_none,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.language:
        return Icon(
          Icons.language,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.discount:
        return Icon(
          Icons.local_offer_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.share:
        return Icon(
          Icons.share_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );

      case ThemeIcon.addressType:
        return Icon(
          Icons.location_city_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.plus:
        return Icon(
          Icons.add,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.minus:
        return Icon(
          Icons.remove,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );

      case ThemeIcon.addressPin:
        return Icon(
          Icons.location_on_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.avatar:
        return Icon(
          Icons.person_outline,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.card:
        return Icon(
          Icons.credit_card,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );

      case ThemeIcon.thumbsUp:
        return Icon(
          Icons.thumb_up_alt_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.mic:
        return Icon(
          Icons.mic_none_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.micOff:
        return Icon(
          Icons.mic_off,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.book:
        return Icon(
          Icons.library_books_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.helpHand:
        return Icon(
          Icons.live_help_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.about:
        return Icon(
          Icons.info_outline,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );

      case ThemeIcon.videoPost:
        return Icon(
          Icons.video_library_rounded,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.reels:
        return Icon(
          Icons.play_arrow_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );

      case ThemeIcon.delete:
        return Icon(
          Icons.delete_outline,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.message:
        return Icon(
          Icons.add_comment_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.chat:
        return Icon(
          Icons.chat,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.chatBordered:
        return Icon(
          Icons.messenger_outline,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.closeCircle:
        return Icon(
          Icons.highlight_remove_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );

      case ThemeIcon.bathTub:
        return Icon(
          Icons.bathtub_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.bed:
        return Icon(
          Icons.bed_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.area:
        return Icon(
          Icons.calculate_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.send:
        return Icon(
          Icons.send,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.bookMark:
        return Icon(
          Icons.bookmark_border_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.bookMarked:
        return Icon(
          Icons.bookmark,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.buildings:
        return Icon(
          Icons.home_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.lock:
        return Icon(
          Icons.lock_open_rounded,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );

      case ThemeIcon.news:
        return Icon(
          Icons.list_alt_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.camera:
        return Icon(
          Icons.camera_alt_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.cameraSwitch:
        return Icon(
          Icons.switch_camera_rounded,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.play:
        return Icon(
          Icons.play_arrow_rounded,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.multiplePosts:
        return Icon(
          Icons.collections_rounded,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.sticker:
        return Icon(
          Icons.emoji_emotions_rounded,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.gif:
        return Icon(
          Icons.gif_box,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.stop:
        return Icon(
          Icons.stop_circle,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.sending:
        return Icon(
          Icons.error_outline_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.sent:
        return Icon(
          Icons.done,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.delivered:
        return Icon(
          Icons.done_all,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.read:
        return Icon(
          Icons.done_all,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.fwd:
        return Icon(
          Icons.send,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );

      case ThemeIcon.reply:
        return Icon(
          Icons.reply,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.videoCamera:
        return Icon(
          Icons.videocam,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.videoCameraOff:
        return Icon(
          Icons.videocam_off,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.callEnd:
        return Icon(
          Icons.call_end,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.emptyCheckbox:
        return Icon(
          Icons.check_box_outline_blank,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.selectedCheckbox:
        return Icon(
          Icons.check_box,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.gallery:
        return Icon(
          Icons.photo,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.mention:
        return Icon(
          Icons.switch_account_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.wallpaper:
        return Icon(
          Icons.wallpaper,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.selectionType:
        return Icon(
          Icons.file_copy_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.contacts:
        return Icon(
          Icons.contact_phone_rounded,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.location:
        return Icon(
          Icons.location_on,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.drawing:
        return Icon(
          Icons.draw,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.report:
        return Icon(
          Icons.report_problem_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.hide:
        return Icon(
          Icons.visibility_off_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.addCircle:
        return Icon(
          Icons.add_circle,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.userGroup:
        return Icon(
          Icons.supervisor_account_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.public:
        return Icon(
          Icons.public,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.request:
        return Icon(
          Icons.task_sharp,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.files:
        return Icon(
          Icons.file_copy_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.fullScreen:
        return Icon(
          Icons.open_in_full_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.randomChat:
        return Icon(
          Icons.person_search,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.download:
        return Icon(
          Icons.file_download,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.pause:
        return Icon(
          Icons.pause,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.map:
        return Icon(
          Icons.map,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.music:
        return Icon(
          Icons.music_note,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.gift:
        return Icon(
          Icons.card_giftcard,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.dating:
        return Icon(
          Icons.local_fire_department_outlined,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.invite:
        return Icon(
          Icons.alternate_email,
          size: size ?? 20,
          color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.acceptCall:
        return SvgPicture.asset(
          'assets/svg/bold/Call.svg',
          height: size ?? 20,
          // color: color ?? AppColorConstants.iconColor,
        );
      case ThemeIcon.declineCall:
        return SvgPicture.asset(
          'assets/svg/bold/Close Square.svg',
          height: size ?? 20,
          // color: color ?? AppColorConstants.iconColor,
        );
    }
  }
}
