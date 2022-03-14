import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/navigation/app_router.dart';
import 'package:ordel/screens/friends/widgets/my_friends_list.dart';
import 'package:ordel/screens/friends/widgets/users_list.dart';
import 'package:ordel/services/user_provider.dart';
import 'package:ordel/widgets/custom_snackbar.dart';

class FriendList extends StatefulWidget {
  final UserProvider userProvider;
  const FriendList({Key? key, required this.userProvider}) : super(key: key);

  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<User> friends = [];
  List<User> allUsers = [];
  List<User> followers = [];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  void _removeFriend(User u, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove friend"),
          content: Text("Are you sure you want to remove ${u.displayname}?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              // key: Key(FriendKeys.CONFIRM_DELETE_FRIEND),
              child: Text("Remove"),
              onPressed: () {
                setState(() {
                  friends.remove(u);
                  widget.userProvider.removeFriend(u);
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _addFriend(User u) {
    setState(() {
      friends.add(u);
      widget.userProvider.addFriend(u);
    });
  }

  @override
  Widget build(BuildContext context) {
    friends = widget.userProvider.users!
        .where(
            (u) => widget.userProvider.activeUser!.friendsUids.contains(u.uid))
        .toList();
    allUsers = widget.userProvider.users!
        .where((u) => u.uid != widget.userProvider.activeUser!.uid)
        .toList();
    followers = widget.userProvider.users!
        .where((u) =>
            widget.userProvider.followers != null &&
            widget.userProvider.followers!.any((f) => f.uid == u.uid))
        .toList();
    return DefaultTabController(
      length: _tabController.length,
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade800,
          bottom: TabBar(
            indicatorColor: Colors.grey.shade100,
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade600,
            tabs: [
              Tab(
                // key: Key(FriendKeys.FRIEND_LIST_TAB),
                child: Text("${friends.length} Friends"),
              ),
              Tab(
                // key: Key(FriendKeys.FOLLOWER_LIST_TAB),
                child: Text("${followers.length} Followers"),
              ),
              Tab(
                // key: Key(FriendKeys.USER_LIST_TAB),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.public),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text("All users"),
                    )
                  ],
                ),
              ),
            ],
          ),
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userProvider.activeUser!.displayname,
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.125,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        widget.userProvider.activeUser!.username,
                        style: TextStyle(
                            color: Colors.grey.shade100,
                            letterSpacing: 0.5,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  IconButton(
                      onPressed: () => AppRouter.navigateTo(
                            context,
                            AppRouter.PROFILE_SCREEN,
                            transition: TransitionType.inFromBottom,
                          ),
                      icon: Icon(Icons.edit))
                ],
              ),
              IconButton(
                onPressed: () => widget.userProvider.refreshUsers(),
                icon: Icon(Icons.refresh),
              )
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            RefreshIndicator(
              // key: Key(FriendKeys.PULL_TO_REFRESH_FRIENDS),
              onRefresh: () => widget.userProvider.getUsers().catchError((e) =>
                  ErrorSnackbar.display(
                      context, "error getting users from database")),
              child: MyFriendsList(
                // key: Key(FriendKeys.FRIEND_LIST_VIEW),
                removeFriend: _removeFriend,
                friends: friends,
              ),
            ),
            RefreshIndicator(
              // key: Key(FriendKeys.PULL_TO_REFRESH_FOLLOWERS),
              onRefresh: () => widget.userProvider.getUsers().catchError((e) =>
                  ErrorSnackbar.display(
                      context, "error getting users from database")),
              child: UsersList(
                // key: Key(FriendKeys.FOLLOWER_LIST_VIEW),
                hintText: "Search followers...",
                addFriend: _addFriend,
                friends: friends,
                users: followers,
              ),
            ),
            RefreshIndicator(
              // key: Key(FriendKeys.PULL_TO_REFRESH_USERS),
              onRefresh: () => widget.userProvider.getUsers().catchError((e) =>
                  ErrorSnackbar.display(
                      context, "error getting users from database")),
              child: UsersList(
                // key: Key(FriendKeys.USER_LIST_VIEW),
                hintText: "Search users...",
                addFriend: _addFriend,
                friends: friends,
                users: allUsers,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
