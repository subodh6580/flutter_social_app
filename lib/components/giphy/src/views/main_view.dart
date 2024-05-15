import 'package:flutter/material.dart';
import 'package:foap/components/giphy/src/providers/sheet_provider.dart';
import 'package:foap/components/giphy/src/views/appbar/searchappbar.dart';
import 'package:foap/components/giphy/src/views/tab/giphy_tab_bar.dart';
import 'package:foap/components/giphy/src/views/tab/giphy_tab_bottom.dart';
import 'package:foap/components/giphy/src/views/tab/giphy_tab_top.dart';
import 'package:foap/components/giphy/src/views/tab/giphy_tab_view.dart';
import 'package:provider/provider.dart';

class MainView extends StatefulWidget {
  const MainView({
    Key? key,
    this.showEmojis = true,
    this.showGIFs = true,
    this.showStickers = true,
  }) : super(key: key);

  final bool showGIFs;
  final bool showStickers;
  final bool showEmojis;

  @override
  MainViewState createState() => MainViewState();
}

class MainViewState extends State<MainView>
    with SingleTickerProviderStateMixin {
  // Scroll Controller
  late ScrollController _scrollController;

  // Sheet Provider
  late SheetProvider _sheetProvider;

  // Tab Controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: [
        widget.showGIFs,
        widget.showEmojis,
        widget.showStickers,
      ].where((isShown) => isShown).length,
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    _sheetProvider = Provider.of<SheetProvider>(context, listen: false);

    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return _draggableScrollableSheet();
  }

  Widget _draggableScrollableSheet() => DraggableScrollableSheet(
      expand: _sheetProvider.isExpanded,
      minChildSize: SheetProvider.minExtent,
      maxChildSize: SheetProvider.maxExtent,
      initialChildSize: _sheetProvider.initialExtent,
      builder: (ctx, scrollController) {
        // Set ScrollController

        _scrollController = scrollController;
        return _bottomSheetBody();
      });

  Widget _bottomSheetBody() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const GiphyTabTop(),
          GiphyTabBar(
            tabController: _tabController,
            showGIFs: widget.showGIFs,
            showStickers: widget.showStickers,
            showEmojis: widget.showEmojis,
          ),
          SearchAppBar(
            scrollController: _scrollController,
          ),
          Expanded(
            child: GiphyTabView(
              tabController: _tabController,
              scrollController:_scrollController,
              showGIFs: widget.showGIFs,
              showStickers: widget.showStickers,
              showEmojis: widget.showEmojis,
            ),
          ),
          const GiphyTabBottom()
        ],
      );
}
