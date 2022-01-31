import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class ErrorSnackbar {
  static display(BuildContext context, String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      duration: Duration(milliseconds: 2000 + (message.length * 25)),
    ));
  }
}

class SuccessSnackbar {
  static display(BuildContext context, String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    Flushbar(
      message: message,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: const EdgeInsets.only(bottom: 60, right: 20, left: 20),
      blockBackgroundInteraction: false,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      boxShadows: const [
        BoxShadow(
          color: Colors.grey,
          offset: Offset(0.0, 1.0), //(x,y)
          blurRadius: 6.0,
        )
      ],
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
    ).show(context);
  }
}

class NotificationSnackbar {
  static display(BuildContext context, String message,
      {required String title, Function? onClick, Function? onNavigate}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    Flushbar(
      message: message,
      flushbarStyle: FlushbarStyle.GROUNDED,
      blockBackgroundInteraction: false,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      onTap: (flushbar) => onClick != null ? onClick() : flushbar.dismiss(),
      title: title,
      boxShadows: const [
        BoxShadow(
          color: Colors.grey,
          offset: Offset(0.0, 1.0),
          blurRadius: 6.0,
        )
      ],
      mainButton: onNavigate != null
          ? TextButton(
              onPressed: () => onNavigate(),
              child: Text(
                "Go to",
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.blueGrey,
      duration: Duration(seconds: 5),
    ).show(context);
  }
}
