import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:ordel/models/game_round_model.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/screens/leaderboards/score_loading_controller.dart';
import 'package:ordel/services/game_provider.dart';
import 'package:ordel/services/user_provider.dart';
import 'package:ordel/widgets/loader.dart';
import 'package:provider/provider.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, UserProvider>(
      builder: (context, gameProvider, userProvider, child) => Loader(
        controller: ScoreLoadingController(gameProvider),
        result: Material(
          type: MaterialType.transparency,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  color: Colors.black87,
                ),
                child: Column(
                  children: [
                    Text(
                      "total games played: ${gameProvider.allGames.length}",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "my games played: ${gameProvider.myGames.length}",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    GameStreakList(gameProvider
                        .getUserLeaderBoard(gameProvider.currentUser!.uid)),
                    const SizedBox(height: 10),
                    LeaderBoard(gameProvider.leaderboard, userProvider.users!,
                        gameProvider.currentUser!.uid),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("close"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameStreakList extends StatelessWidget {
  final List<List<SingleplayerGameRound>> streaks;
  const GameStreakList(this.streaks, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text(
        "My top streaks",
        style: TextStyle(color: Colors.white),
      ),
      ...streaks
          .map(
            (streak) => ListTile(
              title: Text(
                "${streak.length}",
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Text(
                DateFormat(DateFormat.YEAR_MONTH_DAY).format(streak.last.date),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )
          .toList(),
    ]);
  }
}

class LeaderBoard extends StatelessWidget {
  final List<List<SingleplayerGameRound>> leaderboard;
  final List<User> users;

  final String activeUser;
  const LeaderBoard(this.leaderboard, this.users, this.activeUser, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int activeUserTopRanking =
        leaderboard.indexWhere((streak) => streak.first.user == activeUser);
    List<SingleplayerGameRound> activeUserTopGame =
        leaderboard[activeUserTopRanking];
    final List<List<SingleplayerGameRound>> cut =
        leaderboard.sublist(0, min(10, leaderboard.length));

    return ListView(
      shrinkWrap: true,
      children: [
        const Text(
          "Leaderboard",
          style: TextStyle(color: Colors.white),
        ),
        ...cut
            .map(
              (streak) => ListTile(
                selected: streak.first.user == activeUser,
                title: Text(
                  "${streak.length} ${users.firstWhere((u) => u.uid == streak.first.user, orElse: () => User.empty(displayname: "Unknown")).displayname}",
                  style: TextStyle(
                      color: streak.first.user == activeUser
                          ? Colors.green
                          : Colors.white),
                ),
                trailing: Text(
                  DateFormat(DateFormat.YEAR_MONTH_DAY)
                      .format(streak.last.date),
                  style: TextStyle(
                      color: streak.first.user == activeUser
                          ? Colors.green
                          : Colors.white),
                ),
              ),
            )
            .toList(),
        if (activeUserTopRanking > 9)
          Column(
            children: [
              const Divider(color: Colors.white),
              ListTile(
                tileColor: Colors.green,
                leading: Text("..${activeUserTopRanking + 1}"),
                title: Text(
                  "${activeUserTopGame.length} $activeUser",
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  activeUserTopGame.last.date.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
