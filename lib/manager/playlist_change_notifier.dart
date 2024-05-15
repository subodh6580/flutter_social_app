import 'package:foap/helper/imports/common_import.dart';

import '../model/chat_message_model.dart';

class PlaylistChangeNotifier extends ValueNotifier<List<ChatMessageModel>> {
  PlaylistChangeNotifier() : super(_initialValue);
  static final _initialValue = [
    ChatMessageModel()
  ];
}
