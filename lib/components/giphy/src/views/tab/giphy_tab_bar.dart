import 'package:flutter/material.dart';
import 'package:foap/components/giphy/l10n.dart';
import 'package:foap/components/giphy/src/client/models/type.dart';
import 'package:foap/components/giphy/src/providers/tab_provider.dart';
import 'package:provider/provider.dart';

class GiphyTabBar extends StatefulWidget {
  final TabController tabController;
  const GiphyTabBar({
    Key? key,
    required this.tabController,
    this.showEmojis = true,
    this.showGIFs = true,
    this.showStickers = true,
  }) : super(key: key);

  final bool showGIFs;
  final bool showStickers;
  final bool showEmojis;

  @override
  GiphyTabBarState createState() => GiphyTabBarState();
}

class TabWithType {
  final Tab tab;
  final String type;

  TabWithType({
    required this.tab,
    required this.type,
  });
}

class GiphyTabBarState extends State<GiphyTabBar> {
  late TabProvider _tabProvider;
  late List<TabWithType> _tabs;

  @override
  void initState() {
    super.initState();

    // TabProvider
    _tabProvider = Provider.of<TabProvider>(context, listen: false);

    //  Listen Tab Controller
    widget.tabController.addListener(() {
      _setTabType(widget.tabController.index);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setTabType(0);
    });
  }

  @override
  void didChangeDependencies() {
    // Set TabList
    final l = GiphyGetUILocalizations.labelsOf(context);
    _tabs = [
      if (widget.showGIFs)
        TabWithType(tab: Tab(text: l.gifsLabel), type: GiphyType.gifs),
      if (widget.showStickers)
        TabWithType(tab: Tab(text: l.stickersLabel), type: GiphyType.stickers),
      if (widget.showEmojis)
        TabWithType(tab: Tab(text: l.emojisLabel), type: GiphyType.emoji),
    ];

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    //Dispose tabController
    widget.tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tabProvider = Provider.of<TabProvider>(context);

    if (_tabs.length == 1) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: TabBar(
        indicatorColor: _tabProvider.tabColor,
        labelColor: _tabProvider.textSelectedColor,
        unselectedLabelColor: _tabProvider.textUnselectedColor,
        indicatorSize: TabBarIndicatorSize.label,
        controller: widget.tabController,
        tabs: _tabs.map((e) => e.tab).toList(),
        onTap: _setTabType,
      ),
    );
  }

  _setTabType(int pos) {
    _tabProvider.tabType = _tabs[pos].type;
  }
}
