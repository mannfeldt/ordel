import 'package:flutter/material.dart';
import 'package:ordel/models/multiplayer_game_model.dart';
import 'package:ordel/models/user_model.dart';

class GameMyTurnSection extends StatelessWidget {
  final List<MultiplayerGame> games;
  final Function onOpenGame;
  final List<User> users;

  const GameMyTurnSection({
    Key? key,
    required this.games,
    required this.onOpenGame,
    required this.users,
  }) : super(key: key);

//TODO denna och activeSection så man kunna expandera och se progress. två kolumner en för varje spelare med 5 rader, en för varje omgång.
//visa poängen för varje rad vad ordet var osv. snyggt. Visa det som grönt om man hade rätt. Visa det som blandadde färger efter finalGuess om man hade fel
//TODO när man klickar play så kommer man direkt till gamePlay.dart med lite annorulnda header bara som visar vilken omgång man är på. kanske visar en mini variant av historiken för tidigare rundor (likt översiken i expenaderbara)
//TODO när man spelat klart sin runda, onfinished. Så får man en dialog om att välja ett ord till motståndaren om det finns rundor kvar att spela.
//TODO ANnars presenteras man med slutresultatet i en dialog och kan välja rematch eller "ok" för att komma tillbaka till gameList.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My turn",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        ...games
            .map(
              (g) => ListTile(
                // key: Key(PlayKeys.gameListItemForid(g.id)),
                title:
                    Text(g.id, style: TextStyle(color: Colors.grey.shade100)),
                subtitle: Row(
                  children: g.playerUids.map((p) {
                    User user = users.firstWhere(
                      (u) => u.uid == p,
                      orElse: () => User.empty(),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Text(user.displayname,
                          style: TextStyle(color: Colors.grey.shade100)),
                    );
                  }).toList(),
                ),
                trailing: IconButton(
                  // key: Key(PlayKeys.OPEN_GAME_BUTTON),
                  onPressed: () => onOpenGame(g),
                  icon: Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                ),
              ),
            )
            .toList(),
        Divider(),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
