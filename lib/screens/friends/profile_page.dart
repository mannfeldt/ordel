import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/navigation/app_router.dart';
import 'package:ordel/services/game_provider.dart';
import 'package:ordel/services/multiplayer_provider.dart';
import 'package:ordel/services/user_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ordel/utils/colors_helper.dart';
import 'package:ordel/widgets/custom_snackbar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class ProfilePageScreen extends StatelessWidget {
  const ProfilePageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) =>
          ProfilePage(userProvider: userProvider),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final UserProvider userProvider;
  const ProfilePage({Key? key, required this.userProvider}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController displayNameController;
  FocusNode focusNode = FocusNode();
  late Color myColor;
  late String myDisplayname;
  late bool _pushNotification;

  bool editModeDisplayName = false;

  bool profileHasChanges = false;

  @override
  void initState() {
    displayNameController = TextEditingController(
        text: widget.userProvider.activeUser!.displayname);
    myColor = Color(widget.userProvider.activeUser!.colorInt);
    myDisplayname = widget.userProvider.activeUser!.displayname;
    _pushNotification = widget.userProvider.hasActivePushNotifications;
    super.initState();
  }

  void _onColorPressed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Pick a color!',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: myColor,
            onColorChanged: _onColorChanged,
            availableColors: Colors.primaries,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Got it'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _onColorChanged(Color color) {
    setState(() {
      myColor = color;
      profileHasChanges = true;
    });
  }

  void _onDisplayNameChanged(String newName, String oldName) {
    setState(() {
      editModeDisplayName = false;
      myDisplayname = newName;
      if (myDisplayname != oldName) {
        profileHasChanges = true;
      }
    });
  }

  void _onSaveProfile() async {
    try {
      String colorString = ColorHelpers.toHexString(myColor);
      await widget.userProvider
          .updateProfile(myDisplayname, colorString, _pushNotification);

      SuccessSnackbar.display(context, "Profile saved");
      setState(() {
        profileHasChanges = false;
      });
    } catch (e) {
      ErrorSnackbar.display(context, "Error saving profile");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userProvider.activeUser == null) return Container();
    User me = widget.userProvider.activeUser!;

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: profileHasChanges
          ? TextButton(
              onPressed: () => _onSaveProfile(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.save),
                  SizedBox(
                    width: 5,
                  ),
                  Text("Save profile"),
                ],
              ),
            )
          : null,
      body: NotificationListener(
        onNotification: (t) {
          if (t is ScrollStartNotification && t.metrics.axis == Axis.vertical) {
            focusNode.unfocus();
            if (editModeDisplayName) {
              _onDisplayNameChanged(displayNameController.text, me.displayname);
            }
          }
          return true;
        },
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          children: [
            Row(
              children: [
                me.image != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: CircleAvatar(
                          radius: 28.0,
                          backgroundImage: NetworkImage(me.image!),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: CircleAvatar(
                          backgroundColor: myColor,
                          radius: 28.0,
                          child: Text(
                            myDisplayname.substring(0, 2).toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: ColorHelpers.blackOrWhiteContrastColor(
                                  myColor),
                            ),
                          ),
                        ),
                      ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 52,
                        child: editModeDisplayName
                            ? TextField(
                                onSubmitted: (value) => _onDisplayNameChanged(
                                    value, me.displayname),
                                controller: displayNameController,
                                maxLength: 20,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(bottom: 0),
                                  border: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade100),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade100),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                focusNode: focusNode,
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: AutoSizeText(
                                      myDisplayname,
                                      maxFontSize: 22,
                                      maxLines: 1,
                                      minFontSize: 10,
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(() {
                                      editModeDisplayName = true;
                                      focusNode.requestFocus();
                                    }),
                                    icon: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      Text(
                        "game-tag",
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade100),
                      ),
                      Text(
                        me.username,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade100),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            TextButton(
              onPressed: () => _onColorPressed(),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: myColor,
                    radius: 14,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text("Color")
                ],
              ),
            ),
            CheckboxListTile(
              checkColor: Colors.white,
              title: Text(
                "Push notifications",
                style: TextStyle(color: Colors.white),
              ),
              secondary: Icon(
                Icons.notifications,
                color: Colors.white,
              ),
              value: _pushNotification,
              onChanged: (value) => setState(() {
                _pushNotification = value ?? false;
                profileHasChanges = true;
              }),
            ),
            TextButton(
              onPressed: () async {
                await widget.userProvider.clearLocalStorage();
                SuccessSnackbar.display(context, "storage cleared");
              },
              child: Row(
                children: const [
                  Icon(
                    Icons.storage,
                    size: 28,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text("Clear local storage")
                ],
              ),
            ),
            TextButton(
              // key: Key(ProfileKeys.LOGOUT_BUTTON),
              onPressed: () async {
                await widget.userProvider.signOut();
                Provider.of<GameProvider>(context, listen: false).resetGames();
                Provider.of<MultiplayerProvider>(context, listen: false)
                    .resetGames();

                AppRouter.navigateTo(
                  context,
                  "/",
                  clearStack: true,
                  transition: TransitionType.fadeIn,
                  transitionDuration: Duration(milliseconds: 50),
                );
              },
              child: Row(
                children: const [
                  Icon(
                    Icons.exit_to_app,
                    size: 28,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text("Logout")
                ],
              ),
            ),
            FutureBuilder(
              future: PackageInfo.fromPlatform(),
              initialData: PackageInfo(
                  appName: "appname",
                  version: "0",
                  buildNumber: "nr",
                  packageName: "packagename"),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return Text(
                  "version ${snapshot.data.version}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
