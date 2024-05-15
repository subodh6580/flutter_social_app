import 'dart:async';

import 'package:flutter/material.dart';

import '../../giphy_get.dart';

//Builder
typedef GiphyGetWrapperBuilder = Widget Function(
    Stream<GiphyGif>, GiphyGetWrapper);

class GiphyGetWrapper extends StatelessWidget {
  final String giphyApiKey;
  final GiphyGetWrapperBuilder builder;
  final StreamController<GiphyGif> streamController =
       StreamController.broadcast();

  GiphyGetWrapper({
    Key? key,
    required this.giphyApiKey,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(streamController.stream, this);
  }

  getGif(
    String queryText,
    BuildContext context, {
    bool showGIFs = true,
    bool showStickers = true,
    bool showEmojis = true,
  }) async {
    GiphyGif? gif = await GiphyGet.getGif(
      queryText: queryText,
      context: context,
      apiKey: giphyApiKey, //YOUR API KEY HERE
      lang: GiphyLanguage.spanish,
      showGIFs: showGIFs,
      showStickers: showStickers,
      showEmojis: showEmojis,
      debounceTimeInMilliseconds: 350,
    );
    if (gif != null) streamController.add(gif);
  }
}
