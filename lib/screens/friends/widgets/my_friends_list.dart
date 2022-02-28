import 'package:flutter/material.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/widgets/loader.dart';
import 'package:ordel/widgets/user_tile.dart';

class MyFriendsList extends StatefulWidget {
  final List<User> friends;
  final Function removeFriend;

  const MyFriendsList(
      {Key? key, required this.friends, required this.removeFriend})
      : super(key: key);

  @override
  _MyFriendsListState createState() => _MyFriendsListState();
}

class _MyFriendsListState extends State<MyFriendsList> {
  final TextEditingController _searchController =
      TextEditingController(text: "");
  FocusNode focusNode = FocusNode();

  void _onCloseSearch() {
    setState(() {
      _searchController.clear();
      focusNode.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<User> filteredFriends = widget.friends
        .where((f) =>
            f.username
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            f.displayname
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
        .toList();
    return widget.friends.isEmpty
        ? DefaultEmptyWidget(
            // key: Key(FriendKeys.NO_FRIENDS_MESSAGE),
            fullscreen: true,
            message:
                "You don't have any friends yet. Swipe right to find some!",
          )
        : NotificationListener(
            onNotification: (t) {
              if (t is ScrollStartNotification) {
                focusNode.unfocus();
              }
              return true; //TODO vad är detta?
            },
            child: ListView(
              children: [
                Container(
                  height: 40,
                  margin: EdgeInsets.only(top: 10, bottom: 20),
                  child: TextField(
                    style: TextStyle(fontSize: 14),
                    focusNode: focusNode,
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 8),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () => _onCloseSearch(),
                              icon: Icon(
                                Icons.close,
                                size: 22,
                              ),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              color: Colors.grey.shade500,
                            )
                          : null,
                      prefixIcon: Icon(
                        Icons.search,
                        size: 22,
                        color: Colors.grey.shade500,
                      ),
                      hintText: "Search friends...",
                      hintStyle:
                          TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade500),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade500),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                ...filteredFriends
                    .map((u) => UserTile(
                          // key: Key(FriendKeys.userListItemForUid(u.uid)),
                          user: u,
                          trailing: IconButton(
                            onPressed: () => widget.removeFriend(u, context),
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ))
                    .toList(),
                filteredFriends.isEmpty
                    ? DefaultEmptyWidget(
                        fullscreen: false,
                        message: "No matching friend",
                      )
                    : SizedBox(
                        height: 100,
                      ),
              ],
            ),
          );
  }
}
