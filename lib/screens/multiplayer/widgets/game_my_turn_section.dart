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

//TODO lägg till attribution. i playstore lägnst nser under credits/attributiion lägger jag länkarna.
//TODO <a href="https://www.flaticon.com/free-icons/germany" title="germany icons">Germany icons created by Freepik - Flaticon</a>
//TODO <a href="https://www.flaticon.com/free-icons/sweden" title="sweden icons">Sweden icons created by Freepik - Flaticon</a>
//TODO <a href="https://www.flaticon.com/free-icons/uk" title="uk icons">Uk icons created by Freepik - Flaticon</a>
//TODO <a href="https://www.flaticon.com/free-icons/world" title="world icons">World icons created by turkkub - Flaticon</a>
//TODO <a href="https://www.flaticon.com/free-icons/swear" title="swear icons">Swear icons created by Darius Dan - Flaticon</a>
//TODO funkar det lägga in länken såhär i google play? kan man skapa länkar? annars skriv bara ut den i klartext.

  //TODO släpp detta som en ny release. uppdatera i play store med nya screenshoots på rätt färger nu.
  //TODO också nytt namn så man inte ser ordel... och sätt namnet till det jag vill...
//TODO nytt namn? see keep/events kalender: ordna, ordning++, ordas, ordat, orda

// Ändra adance settings i plays tore cnosole: publish
//när det är i prod nu testa själv lite. och kolla store precense. sen fixa pusnotis osv. nedan.

//TODO. Skapa pushnotis som förklarar mig lite.. och tackar.
//TODO meddela att ny version finns tillgänglig som fungerar mycket bättre och där multiplayer är fixat.
//TODO skicka ut notisen på två språk.
//TODO rensa alla users och games i prod. Förklara det i pushnotisen också. eller separat pushnotis.
//eller ta bara bort alla anonyma konton? de som saknar
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
              trailing: TextButton(
                // key: Key(PlayKeys.OPEN_GAME_BUTTON),
                onPressed: () => onOpenGame(g),
                child: Container(
                  child: Text(
                    "Play",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      border: Border.all(color: Colors.white, width: 2.0)),
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
