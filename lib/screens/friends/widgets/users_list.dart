import 'package:flutter/material.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/widgets/loader.dart';
import 'package:ordel/widgets/user_tile.dart';

class UsersList extends StatefulWidget {
  final List<User> users;
  final List<User> friends;
  final Function addFriend;
  final String hintText;

  const UsersList(
      {Key? key,
      required this.users,
      required this.friends,
      required this.addFriend,
      required this.hintText})
      : super(key: key);

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
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
    List<User> filteredUsers = widget.users
        .where((u) =>
            u.username
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            u.displayname
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
        .toList();
    return NotificationListener(
      onNotification: (t) {
        if (t is ScrollStartNotification) {
          focusNode.unfocus();
        }
        return true;
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
                        color: Colors.grey.shade100,
                      )
                    : null,
                prefixIcon: Icon(
                  Icons.search,
                  size: 22,
                  color: Colors.grey.shade100,
                ),
                hintText: widget.hintText,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade100),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          ...filteredUsers
              .map((u) => UserTile(
                    // key: Key(FriendKeys.userListItemForUid(u.uid)),
                    user: u,
                    trailing: !widget.friends.contains(u)
                        ? IconButton(
                            onPressed: () => widget.addFriend(u),
                            icon: Icon(
                              Icons.person_add,
                              color: Colors.white,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Icon(
                              Icons.done,
                              color: Colors.white,
                            ),
                          ),
                  ))
              .toList(),
          filteredUsers.isEmpty
              ? DefaultEmptyWidget(
                  // key: Key(FriendKeys.NO_USER_MESSAGE),
                  fullscreen: false,
                  message: "No matching user",
                )
              : SizedBox(
                  height: 100,
                ),
        ],
      ),
    );
  }
}
