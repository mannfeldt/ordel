import 'package:flutter/material.dart';
import 'package:ordel/friends/friends_screen.dart';
import 'package:ordel/home.dart';
import 'package:ordel/keys.dart';
import 'package:ordel/navigation/app_router.dart';

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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: PageView(
        physics: _disablePageScroll
            ? NeverScrollableScrollPhysics()
            : PageScrollPhysics(),
        controller: pageController,
        onPageChanged: (int index) {
          pageChanged(index);
        },
        children: [
          SinglePlayerScreen(
            key: const Key(MainKeys.SINGLEPLAYER_SCREEN),
            userLanguage: Localizations.localeOf(context).languageCode,
          ),
          FriendsScreen(
            key: const Key(MainKeys.MULTIPLAYER_SCREEN),
          ),
          FriendsScreen(
            key: const Key(MainKeys.FRIEND_SCREEN),
          ),
          FriendsScreen(
            key: const Key(MainKeys.LEADERBOARD_SCREEN),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        child: BottomNavigationBar(
          currentIndex: _selectedPageIndex,
          onTap: (int index) => navBarTapped(index),
          selectedItemColor: Colors.cyan,
          // fixa någon liknande hantering som PE labs för färger. ta fram några färger jag vill jobba med.
          //kolla på inspiration till mobile UI med färger. man ska väl typ välja 3-4 färger. sen lite olika nyanser av det som vi gjort i pe labs. hitta mina fräger.
          //PRimary purple? sätt upp det som primary, secondary, third etc? och testa sen med lite färger?
          //hitta en font också?
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text(
                'Single',
                key: Key(MainKeys.SINGLEPLAYER_NAV_BUTTON),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              title: Text(
                'Multi',
                key: Key(MainKeys.MULTIPLAYER_NAV_BUTTON),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_arrow),
              title: Text(
                'Friends',
                key: Key(MainKeys.FRIENDS_NAV_BUTTON),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              title: Text(
                'Leaderboard',
                key: Key(MainKeys.LEADERBOARD_NAV_BUTTON),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
