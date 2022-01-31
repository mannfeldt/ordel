import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:ordel/models/multiplayer_game_model.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/navigation/app_router.dart';
import 'package:ordel/screens/multiplayer/widgets/my_games_list.dart';
import 'package:ordel/services/multiplayer_provider.dart';
import 'package:ordel/services/user_provider.dart';
import 'package:ordel/widgets/custom_snackbar.dart';
import 'package:ordel/widgets/loader.dart';

class GameList extends StatefulWidget {
  final UserProvider userProvider;
  final MultiplayerProvider multiplayerProvider;
  const GameList(
      {Key? key, required this.userProvider, required this.multiplayerProvider})
      : super(key: key);

  @override
  _GameListState createState() => _GameListState();
}

class _GameListState extends State<GameList> {
  void _openNewGameForm() {
    AppRouter.navigateTo(
      context,
      "AppRouter.NEW_GAME_PLATFORM_SCREEN",
      transition: TransitionType.inFromBottom,
    );
  }

  Future<void> _onAcceptInvite(MultiplayerGame game, User me) async {
    try {
      User? gameHost = widget.userProvider.users?.firstWhere(
        (u) => u.uid == game.host,
        orElse: () => User.empty(),
      );
      await widget.multiplayerProvider.acceptGameInvite(game, me, gameHost);
    } catch (e) {
      ErrorSnackbar.display(context, "error accepting game invite");
    }
  }

  Future<void> _onDeclineInvite(MultiplayerGame game, User me) async {
    try {
      User? gameHost = widget.userProvider.users?.firstWhere(
        (u) => u.uid == game.host,
        orElse: () => User.empty(),
      );
      await widget.multiplayerProvider.declineGameInvite(game, me, gameHost);
    } catch (e) {
      ErrorSnackbar.display(context, "error declining game invite");
    }
  }

  void _onOpenGame(MultiplayerGame game) {
    AppRouter.navigateTo(context, AppRouter.pathForGame(game.id));
  }

  Future<void> _onDeleteGame(MultiplayerGame game) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove game"),
          content: Text("Are you sure you want to remove this game?"),
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
              onPressed: () async {
                try {
                  await widget.multiplayerProvider.deleteGame(game);
                } catch (e) {
                  ErrorSnackbar.display(context, "error deleting game");
                } finally {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onStartGame(MultiplayerGame game) async {
    if (game.hasUnansweredInvites) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Start game"),
            content: Text(
                "There are still ${game.invitees.length} unanswered invites to this game. Do you want to start without them?"),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                // key: Key(FriendKeys.CONFIRM_DELETE_FRIEND),
                child: Text("Start"),
                onPressed: () async {
                  try {
                    await widget.multiplayerProvider.startGame(game);
                  } catch (e) {
                    ErrorSnackbar.display(context, "error starting game");
                  } finally {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      try {
        await widget.multiplayerProvider.startGame(game);
      } catch (e) {
        ErrorSnackbar.display(context, "error starting game");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "My games",
          style: TextStyle(
            color: Colors.black87,
            letterSpacing: 1.125,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        // key: Key(PlayKeys.PULL_TO_REFRESH_GAMES),
        onRefresh: () => widget.multiplayerProvider.getGames().catchError((e) =>
            ErrorSnackbar.display(
                context, "error getting games from database")),
        child: widget.multiplayerProvider.hasGames
            ? MyGamesList(
                // key: Key(PlayKeys.GAME_LIST_VIEW),
                games: widget.multiplayerProvider.games!,
                me: widget.userProvider.activeUser!,
                onAcceptInvite: _onAcceptInvite,
                onDeclineInvite: _onDeclineInvite,
                onDeleteGame: _onDeleteGame,
                onStartGame: _onStartGame,
                onOpenGame: _onOpenGame,
                users: widget.userProvider.users!,
              )
            : DefaultEmptyWidget(
                fullscreen: true,
                message: "You have no active games",
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: TextButton(
        onPressed: _openNewGameForm,
        child: Text("new game"),
      ),
    );
  }
}
