import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ordel/utils/constants.dart';
import 'package:ordel/utils/utils.dart';

//TODO testa att spelet fungerar singleplayer. alla språk..
//TODO--- 2. lägg till cachning av users och/eller ta bort hämtning av alla games helt...
//TODO--- 3. fixa foreceupdate dialog och ett custom meddelande. likt PELabs.
//TODO 4. kanske också ta in ett paket för att pusha meddelande om valfri updatering.
//TODO se över multiplayer. hur fungerar det?
//TODO nytt namn? see keep/events kalender: ordna, ordning, ordas, ordat, orda
//TODO. Skapa nytt bygge och pushnotis som förklarar mig lite.. och tackar.
//TODO svara också på reviews.

class WordRow extends StatefulWidget {
  final String answer;
  final String guess;
  final RowState state;
  final List<FlipCardController>? controllers;
  final double boxSize;
  final bool defaultFlipped;
  final double boxMargin;

  const WordRow({
    Key? key,
    this.state = RowState.inactive,
    this.guess = "",
    this.answer = "",
    required this.boxSize,
    this.controllers,
    this.defaultFlipped = false,
    this.boxMargin = Constants.boxMargin,
  }) : super(key: key);

  @override
  State<WordRow> createState() => _WordRowState();
}

class _WordRowState extends State<WordRow> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int activeLetterIndex = widget.guess.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 5; i++)
          LetterBox(
            size: widget.boxSize,
            boxMargin: widget.boxMargin,
            defaultFlipped: widget.defaultFlipped,
            flipController:
                widget.controllers != null ? widget.controllers![i] : null,
            state: getLetterBoxState(
              i,
              rowState: widget.state,
              activeIndex: activeLetterIndex,
              answer: widget.answer,
              guess: widget.guess,
            ),
            letter: activeLetterIndex > i ? widget.guess[i] : "",
          ),
      ],
    );
  }
}

class LetterBox extends StatelessWidget {
  final LetterBoxState state;
  final String letter;
  final FlipCardController? flipController;
  final double size;
  final bool defaultFlipped;
  final double boxMargin;

  const LetterBox({
    Key? key,
    required this.size,
    this.state = LetterBoxState.inactive,
    this.letter = "",
    this.flipController,
    this.defaultFlipped = false,
    this.boxMargin = Constants.boxMargin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Color boxColor;
    late Color boxColorHidden;
    switch (state) {
      case LetterBoxState.inactive:
        boxColor = Colors.grey.shade600;
        boxColorHidden = Colors.grey.shade600;
        break;
      case LetterBoxState.active:
        boxColor = Colors.black87;
        boxColorHidden = Colors.black87;
        break;
      case LetterBoxState.focused:
        boxColor = Colors.black87;
        boxColorHidden = Colors.black87;

        break;
      case LetterBoxState.wrong:
        boxColor = Colors.blueGrey.shade900;
        boxColorHidden = Colors.black87;

        break;
      case LetterBoxState.included:
        boxColor = Colors.orange;
        boxColorHidden = Colors.black87;

        break;
      case LetterBoxState.correct:
        boxColor = Colors.green;
        boxColorHidden = Colors.black87;

        break;
      default:
    }

    Widget hidden = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: boxColorHidden,
        borderRadius: BorderRadius.all(Radius.circular(2 + (size / 10))),
      ),
      padding: EdgeInsets.all(boxMargin),
      margin: EdgeInsets.all(boxMargin),
      child: state == LetterBoxState.focused
          ? Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.symmetric(
                horizontal: size / 6,
                vertical: size / 12,
              ),
              child: const BlinkingUnderline(),
            )
          : Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: size / 2,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
    Widget revealed = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.all(Radius.circular(2 + (size / 10))),
      ),
      padding: EdgeInsets.all(boxMargin),
      margin: EdgeInsets.all(boxMargin),
      child: state == LetterBoxState.focused
          ? Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.symmetric(
                horizontal: size / 6,
                vertical: size / 12,
              ),
              child: const BlinkingUnderline(),
            )
          : Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: size / 2,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );

    return FlipCard(
      controller: flipController,
      flipOnTouch: !kReleaseMode,
      speed: 500,
      direction: FlipDirection.HORIZONTAL,
      front: defaultFlipped ? revealed : hidden,
      back: revealed,
    );
  }
}

class BlinkingUnderline extends StatefulWidget {
  const BlinkingUnderline({Key? key}) : super(key: key);

  @override
  _BlinkingUnderlineState createState() => _BlinkingUnderlineState();
}

class _BlinkingUnderlineState extends State<BlinkingUnderline>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: Container(
        height: 3,
        color: Colors.white70,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
