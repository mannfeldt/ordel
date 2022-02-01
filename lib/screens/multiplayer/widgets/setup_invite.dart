import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/navigation/app_router.dart';
import 'package:ordel/screens/multiplayer/widgets/invite_load_controller.dart';
import 'package:ordel/services/user_provider.dart';
import 'package:ordel/widgets/loader.dart';
import 'package:ordel/widgets/user_tile.dart';
import 'package:provider/provider.dart';

class SetupInviteScreen extends StatelessWidget {
  final String language;
  const SetupInviteScreen({
    Key? key,
    required this.language,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) => Loader(
        controller: InviteLoadController(userProvider),
        result: SetupInviteForm(
          userProvider: userProvider,
          language: language,
        ),
      ),
    );
  }
}

class SetupInviteForm extends StatefulWidget {
  final UserProvider userProvider;
  final String language;

  const SetupInviteForm(
      {Key? key, required this.userProvider, required this.language})
      : super(key: key);

  @override
  _SetupInviteFormState createState() => _SetupInviteFormState();
}

class _SetupInviteFormState extends State<SetupInviteForm> {
  final TextEditingController _searchController =
      TextEditingController(text: "");
  FocusNode focusNode1 = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  void _onCloseSearch() {
    setState(() {
      _searchController.clear();
      for (var node in [focusNode1]) {
        node.unfocus();
      }
    });
  }

  Future<void> _nextStep(String invite) async {
    AppRouter.navigateTo(
      context,
      "${AppRouter.SETUP_WORD_SCREEN}?language=${widget.language}&invite=$invite",
      transition: TransitionType.inFromRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<User> filteredUsers = widget.userProvider.users!.where(
      (u) {
        return widget.userProvider.activeUser!.uid != u.uid &&
            (u.username
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ||
                u.displayname
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()));
      },
    ).toList();

    List<User> filteredFriends = filteredUsers
        .where(
            (u) => widget.userProvider.activeUser!.friendsUids.contains(u.uid))
        .toList();

    List<User> filteredAllUsers = filteredUsers
        .where(
            (u) => !widget.userProvider.activeUser!.friendsUids.contains(u.uid))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Select Opponent",
          style: TextStyle(
            color: Colors.black87,
            letterSpacing: 1.125,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.chevron_left,
            color: Colors.blue,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            height: 40,
            margin: EdgeInsets.only(top: 10, bottom: 20),
            child: TextField(
              style: TextStyle(fontSize: 14),
              focusNode: focusNode1,
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
                hintText: "search users...",
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
          NotificationListener(
            onNotification: (t) {
              if (t is ScrollStartNotification) {
                for (var node in [focusNode1]) {
                  node.unfocus();
                }
              }
              return true; //?
            },
            child: Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 10),
                children: [
                  if (filteredFriends.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Friends",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...filteredFriends
                            .map(
                              (u) => UserTile(
                                user: u,
                                trailing: IconButton(
                                  onPressed: () => _nextStep(u.uid),
                                  icon: Icon(Icons.add),
                                ),
                              ),
                            )
                            .toList(),
                        Divider(),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  if (filteredAllUsers.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "All users",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...filteredAllUsers
                            .map(
                              (u) => UserTile(
                                user: u,
                                trailing: IconButton(
                                  onPressed: () => _nextStep(u.uid),
                                  icon: Icon(Icons.add),
                                ),
                              ),
                            )
                            .toList(),
                        Divider(),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
