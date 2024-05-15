enum RecordType {
  profile,
  post,
  hashtag,
  location,
}

enum SearchFrom {
  username,
  email,
  phone,
}

enum PostSource { posts, mentions, videos, saved }

enum PostingStatus { none, posting, posted, error }

enum PostType { basic, competition, club, reel, reshare }

enum PostContentType { text, media, location }

enum PostMediaType { all, photo, video, audio }

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
}

enum MessageContentType {
  text,
  photo,
  video,
  audio,
  gif,
  sticker,
  contact,
  file,
  location,
  reply,
  forward,
  post,
  story,
  drawing,
  profile,
  group,
  groupAction,
  gift,
  textReplyOnStory,
  reactedOnStory,
}

enum UploadMediaType {
  shop,
  storyOrHighlights,
  chat,
  club,
  verification,
  uploadResume,
}

///Media picker selection type
enum GalleryMediaType {
  ///make picker to select only image file
  photo,
  gif,

  ///make picker to select only video file
  video,

  ///make picker to select only audio file
  audio,

  ///make picker to select only pdf file
  pdf,

  ///make picker to select only ppt file
  ppt,

  ///make picker to select only doc file
  doc,

  ///make picker to select only xls file
  xls,

  ///make picker to select only txt file
  txt,

  ///make picker to select any media file
  all,
}

enum ChatMessageActionMode { none, reply, forward, star, delete, edit }

enum AgoraCallType {
  audio,
  video,
}

enum PaymentGateway {
  creditCard,
  // applePay,
  paypal,
  razorpay,
  wallet,
  stripe,
  // googlePay,
  inAppPurchase,
  // flutterWave
}

enum BookingStatus { confirmed, cancelled }

enum EventStatus { upcoming, active, completed }

enum TvBannerType { tv, show }

enum PodcastBannerType { host, show }

enum RelationsRevealSetting { none, followers, all }

enum GenderType { male, female, other }

enum NotificationType {
  like,
  comment,
  follow,
  followRequest,
  gift,
  clubInvitation,
  competitionAdded,
  relationInvite,
  none,
  verification,
  supportRequest
}

enum CommentType { text, image, video, gif }

enum LiveBattleResultType { winner, draw }

enum BattleStatus { none, accepted, started, completed }

enum OfferSource { normal, fav }

enum GoalType { profile, website, message }

enum ItemViewSource { normal, promotion }

enum UserViewSourceType { post, reel, story }

enum TransactionType {
  credit,
  debit,
}

enum PaymentType {
  withdrawal,
  gift,
  redeemCoin,
}

enum PaymentMode {
  inAppPurchase,
  paypal,
  wallet,
  stripe,
  razorpay,
  flutterWave
}

enum DatingActions {
  liked,
  rejected,
  undoLiked,
}

enum FollowingStatus {
  notFollowing,
  requested,
  following,
}

enum PlayStateState { paused, playing, loading, idle }
