import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:native_updater/native_updater.dart';
import 'package:ordel/screens/friends/friends_screen.dart';
import 'package:ordel/screens/multiplayer/multiplayer_index.dart';
import 'package:ordel/screens/singleplayer/singleplayer_index.dart';
import 'package:ordel/services/session_provider.dart';
import 'package:ordel/utils/keys.dart';
import 'package:ordel/navigation/app_router.dart';
import 'package:ordel/utils/version_checker.dart';
import 'package:provider/provider.dart';

class MainPages extends StatefulWidget {
  final int initialPageIndex;

  const MainPages({
    Key? key,
    this.initialPageIndex = 0,
  }) : super(key: key);

  @override
  _MainPagesState createState() => _MainPagesState();
}

class _MainPagesState extends State<MainPages> {
  late int _selectedPageIndex;
  final bool _disablePageScroll = false;
  late PageController pageController;
  final bool _versionCheckerDialogIsOpen = false;
  @override
  void initState() {
    _selectedPageIndex = widget.initialPageIndex;
    pageController = PageController(
      initialPage: widget.initialPageIndex,
      keepPage: true,
    );

    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }

  void pageChanged(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void navBarTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
      pageController.jumpToPage(index);
    });
    AppRouter.handleTabNavigation(index);
  }

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      VersionChecker.run(context);
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: PageView(
        physics: _disablePageScroll
            ? NeverScrollableScrollPhysics()
            : PageScrollPhysics(),
        controller: pageController,
        onPageChanged: (int index) {
          pageChanged(index);
        },
        children: [
          SingleplayerScreen(
            key: const Key(MainKeys.SINGLEPLAYER_SCREEN),
            sessionLanguageCode:
                Provider.of<SessionProvider>(context, listen: false)
                        .languageCode ??
                    Localizations.localeOf(context).languageCode,
          ),
          MultiplayerScreen(
            key: const Key(MainKeys.MULTIPLAYER_SCREEN),
          ),
          FriendsScreen(
            key: const Key(MainKeys.FRIEND_SCREEN),
          ),
          //TODO tar bort leadboard tillsvidare. behöver lägga in cachning osv på den..
          // LeaderboardScreen(
          //   key: const Key(MainKeys.LEADERBOARD_SCREEN),
          // ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        child: BottomNavigationBar(
          backgroundColor: Colors.grey.shade900,
          currentIndex: _selectedPageIndex,
          onTap: (int index) => navBarTapped(index),
          selectedItemColor: Colors.cyan,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.play_arrow),
              label: 'Singleplayer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_mma),
              label: 'Duel',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Friends',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.list),
            //   label: 'Leaderboard',
            // ),
          ],
        ),
      ),
    );
  }
}
