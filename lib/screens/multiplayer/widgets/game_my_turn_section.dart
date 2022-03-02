import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ordel/models/language_model.dart';
import 'package:ordel/models/multiplayer_game_model.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/screens/multiplayer/widgets/multiplayer_game_standings.dart';

class GameMyTurnSection extends StatelessWidget {
  final List<MultiplayerGame> games;
  final Function onOpenGame;
  final Function onDeleteGame;
  final List<User> users;
  final User activeUser;
  final List<Language> languages;

  //TODO dialogen när sisa spelaren körs. med rematch val osv. Visa resultet där och om man vann/förlora.

//TODO problem med notis när det är ens tur. händer inget när man klickarp åden. inte ens appen öppnas??
//fixa minst till det att appen öppnas.. helst öppna dueltabben

//TODO hur är det med poängen. blir bara 25 på allt? är det något fel på fold sammanställningen?

//todo FIXA statspage? se taiga. direkt via knapp från singleplayer vyn. Leadrboardtabben kanske ersätts också av knapp inne i gamelist vyn?
//todo något enkelt först. bara sitt egna best streak och % win, total games player,
//todo lägg senare till rank/leaderboard: vilket kräver att vi sparar beststreak på user.

  //TODO släpp detta som en ny release. uppdatera i play store med nya screenshoots på rätt färger nu.
  //TODO också nytt namn så man inte ser ordel... och sätt namnet till det jag vill...
//TODO nytt namn? see keep/events kalender: ordna, ordning++, ordas, ordat, orda
//TODO. Skapa nytt bygge och pushnotis som förklarar mig lite.. och tackar.
//TODO svara också på reviews.
//TODO lägg upp en bättre beskrvining a features osv.
//TODO -unlimited wordle in Swedish or English. -multiplayer duels with friends

  const GameMyTurnSection({
    Key? key,
    required this.games,
    required this.onOpenGame,
    required this.users,
    required this.activeUser,
    required this.languages,
    required this.onDeleteGame,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My turn",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        ...games.map(
          (g) {
            User opponent = users.firstWhere(
              (u) => u.uid != g.currentPlayerUid,
              orElse: () => User.empty(),
            );
            Language language = languages.firstWhere(
                (l) => l.code == g.language,
                orElse: () => Language("", ""));
            return ExpansionTile(
              // key: Key(PlayKeys.gameListItemForid(g.id)),
              title: Text(
                kReleaseMode ? "${language.name} duel" : g.id,
                style: TextStyle(color: Colors.grey.shade100),
              ),
              subtitle: Text("Opponent: ${opponent.displayname}",
                  style: TextStyle(color: Colors.grey.shade100)),
              trailing: IconButton(
                // key: Key(PlayKeys.OPEN_GAME_BUTTON),
                onPressed: () => onOpenGame(g),
                icon: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
              ),
              children: [
                ListView(
                  shrinkWrap: true,
                  children: [
                    MultiplayerGameStandings(
                      game: g,
                      activeUser: activeUser,
                      otherUser: users.firstWhere((u) =>
                          u.uid ==
                          g.playerUids
                              .firstWhere((id) => id != activeUser.uid)),
                      size: Size(
                        mq.size.width,
                        mq.size.height - mq.padding.top,
                      ),
                    ),
                    IconButton(
                      onPressed: () => onDeleteGame(g),
                      icon: Icon(
                        Icons.delete,
                        color: Colors.grey.shade100,
                      ),
                    )
                  ],
                )
              ],
            );
          },
        ).toList(),
        Divider(),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
