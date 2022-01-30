import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/utils/colors_helper.dart';

class UserTile extends StatelessWidget {
  final User user;
  final bool dense;
  final Widget? trailing;
  final EdgeInsets? contentPadding;
  final Widget? leading;
  const UserTile(
      {Key? key,
      required this.user,
      this.dense = false,
      this.trailing,
      this.contentPadding,
      this.leading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: dense,
      contentPadding:
          contentPadding ?? const EdgeInsets.symmetric(horizontal: 16.0),
      leading: leading ??
          (user.image != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(user.image!),
                  radius: dense ? 16 : 20,
                )
              : CircleAvatar(
                  backgroundColor: Color(user.colorInt),
                  radius: dense ? 16 : 20,
                  child: Text(
                    user.displayname.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      color: ColorHelpers.blackOrWhiteContrastColor(
                          Color(user.colorInt)),
                      fontSize: dense ? 12 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )),
      title: AutoSizeText(
        user.displayname,
        maxLines: 1,
      ),
      subtitle: Text(user.username),
      trailing: trailing,
    );
  }
}
