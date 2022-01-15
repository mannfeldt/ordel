import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _word = "kamel";
  String _currentGuess = "";
  final List<String> _guesses = [
    "",
    "",
    "",
    "",
    "",
    "",
  ];

  int get activeRow => _guesses.indexWhere((g) => g.isEmpty);

  //hantera när vi lägger till en bokstav så läggs det till här max 5 chars per sträng då.
  //klickar man på delte så försvinner den senaste char.

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 6; i++)
              WordRow(
                guess: _guesses[i].isNotEmpty
                    ? _guesses[i]
                    : activeRow == i
                        ? _currentGuess
                        : "",
                word: _word,
                state: activeRow == i
                    ? RowState.active
                    : activeRow > i
                        ? RowState.done
                        : RowState.inactive,
              ),

            //en rad kan ha 3 states. inactive, active, used,
            //en ruta kan ha 3 states. empty, focused, filled,
            //
            //lägg en grid 5 rutor per rad 6 rader. sen ett custom tangentbord. som jag kan syra alla knappar etc.
            //kolla paket för det eller fixa det helt själv custom med knappar bäst kanske. ska kunna vara olika tangentbord per språk
            //en tangentbordknapp har en bokstav kopplad till sig. layout är per språk.
            //https://ordel.se/
            //1. fixa helt offline att själva spelet fungerar. ta några manuellt handplockade ord https://doon.se/ordl%C3%A4ngd/5
            //2. lägg till coola animationer. allt ska vara responsivt. höjden är det känsliga. behöver inte visa alla 6 rader samtidigt? om det blir tight.
            //3. lägg till funktion för pågående streak, nollställs helt när man failar. inget sparas historiskt.
            //2. lägg till möjlighet att loggain, se firebase fltuter 2.8 widgeten? då sparar man sina spel och kan se streaks etc.
            //3. är man inte inloggad så kan man bara spela sessionsbasis. man kan kanske fortfarande se pågående streak men inte sina rekord osv.
            //4. lägg till highscorelist/lite mer statistik om vilken rank man är, vilken procenttile man är av alla spelare.
            //5. det är streak som gäller. man kan ha flera olika typer av steaks. 1. klarade ord 2. klarade ord på under x rader etc.
            //6. Lägg till möjlighet till matchmaking/duel där man tävlar likt quizkampen. man får välja 1 av 3 ord till den andra spelaren
            //   den ska då spela och sen väljer den tillbaka ett ord osv. bäst av 5 kanske. man får poäng beronde på hur få gissningar man behövde.
            //   det kan bli lika? eller tiebreak är tiden? man har max 1 minut per omgång och den med mest tid kvar vinner om det blev lika.
            //   Det kan vara auto matchmaking (ranked) eller casual (invite friend).
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

enum RowState { inactive, active, done }

class WordRow extends StatelessWidget {
  final String word;
  final String guess;
  final RowState state;
  const WordRow({
    Key? key,
    this.state = RowState.inactive,
    this.guess = "",
    this.word = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int activeLetterIndex = guess.length;
    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          LetterBox(
            active: state == RowState.active,
            focused: activeLetterIndex == i,
            letter: activeLetterIndex > i ? guess[i] : "",
          ),
      ],
    );
  }
}

class LetterBox extends StatelessWidget {
  final bool focused;
  final bool active;
  final String letter;

  const LetterBox({
    Key? key,
    this.active = false,
    this.focused = false,
    this.letter = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          color: active ? Colors.white : Colors.grey.shade300,
          padding: const EdgeInsets.all(4.0),
          child: Center(
            child: Text(
              letter,
              style:
                  focused ? TextStyle(fontSize: 14) : TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
