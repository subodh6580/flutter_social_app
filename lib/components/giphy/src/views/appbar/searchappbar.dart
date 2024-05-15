import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foap/components/giphy/giphy_get.dart';
import 'package:foap/components/giphy/src/client/models/type.dart';
import 'package:foap/components/giphy/src/l10n/l10n.dart';
import 'package:foap/components/giphy/src/providers/app_bar_provider.dart';
import 'package:foap/components/giphy/src/providers/sheet_provider.dart';
import 'package:foap/components/giphy/src/providers/tab_provider.dart';
import 'package:foap/components/giphy/src/tools/debouncer.dart';
import 'package:provider/provider.dart';

class SearchAppBar extends StatefulWidget {
  // Scroll Controller
  final ScrollController scrollController;

  const SearchAppBar({Key? key, required this.scrollController}) : super(key: key);

  @override
  SearchAppBarState createState() => SearchAppBarState();
}

class SearchAppBarState extends State<SearchAppBar> {
  // Tab Provider
  late TabProvider _tabProvider;

  // AppBar Provider
  late AppBarProvider _appBarProvider;

  // Sheet Provider
  late SheetProvider _sheetProvider;

  // Input controller
  late TextEditingController _textEditingController;

  // Input Focus
  final FocusNode _focus =  FocusNode();

  @override
  void initState() {
    // Focus
    _focus.addListener(_focusListener);

    //Set Texfield Controller
    _textEditingController =  TextEditingController(
        text: Provider.of<AppBarProvider>(context, listen: false).queryText);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Establish the debouncer
      final debouncer = Debouncer(
        delay: Duration(
          milliseconds: _appBarProvider.debounceTimeInMilliseconds,
        ),
      );

      // Listener TextField
      _textEditingController.addListener(() {
        debouncer.call(() {
          if (_appBarProvider.queryText != _textEditingController.text) {
            _appBarProvider.queryText = _textEditingController.text;
          }
        });
      });
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // Providers
    _tabProvider = Provider.of<TabProvider>(context);

    _sheetProvider = Provider.of<SheetProvider>(context);

    // AppBar Provider
    _appBarProvider = Provider.of<AppBarProvider>(context);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
      child: _searchWidget(),
    );
  }

  Widget _searchWidget() {
    final l = GiphyGetUILocalizations.labelsOf(context);
    return Column(
      children: [
        _tabProvider.tabType == GiphyType.emoji
            ? Container()
            : SizedBox(
                height: 40,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      autofocus: _sheetProvider.initialExtent ==
                          SheetProvider.maxExtent,
                      focusNode: _focus,
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        prefixIcon: _searchIcon(),
                        hintText: l.searchInputLabel,
                        suffixIcon: IconButton(
                            icon: Icon(
                              Icons.clear,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color!,
                            ),
                            onPressed: () {
                              setState(() {
                                _textEditingController.clear();
                              });
                            }),
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      autocorrect: false,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _searchIcon() {
    if (kIsWeb) {
      return const Icon(Icons.search);
    } else {
      return ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFFF6666),
            Color(0xFF9933FF),
          ],
        ).createShader(bounds),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(pi),
          child: const Icon(
            Icons.search,
            color: Colors.white,
          ),
        ),
      );
    }
  }

  void _focusListener() {
    // Set to max extent height if Textfield has focus
    if (_focus.hasFocus &&
        _sheetProvider.initialExtent == SheetProvider.minExtent) {
      _sheetProvider.initialExtent = SheetProvider.maxExtent;
    }
  }
}
