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

  const GameMyTurnSection({
    Key? key,
    required this.games,
    required this.onOpenGame,
    required this.users,
    required this.activeUser,
    required this.languages,
    required this.onDeleteGame,
  }) : super(key: key);

//TODO denna och activeSection så man kunna expandera och se progress. två kolumner en för varje spelare med 5 rader, en för varje omgång.
//visa poängen för varje rad vad ordet var osv. snyggt. Visa det som grönt om man hade rätt. Visa det som blandadde färger efter finalGuess om man hade fel
//TODO när man klickar play så kommer man direkt till gamePlay.dart med lite annorulnda header bara som visar vilken omgång man är på. kanske visar en mini variant av historiken för tidigare rundor (likt översiken i expenaderbara)
//TODO när man spelat klart sin runda, onfinished. Så får man en dialog om att välja ett ord till motståndaren om det finns rundor kvar att spela.
//TODO ANnars presenteras man med slutresultatet i en dialog och kan välja rematch eller "ok" för att komma tillbaka till gameList.
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
