import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ordel/utils/constants.dart';
import 'package:ordel/utils/utils.dart';

class WordRow extends StatefulWidget {
  final String answer;
  final String guess;
  final RowState state;
  final List<FlipCardController> controllers;
  final double boxSize;

  const WordRow({
    Key? key,
    this.state = RowState.inactive,
    this.guess = "",
    this.answer = "",
    required this.boxSize,
    required this.controllers,
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
            flipController: widget.controllers[i],
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

  const LetterBox({
    Key? key,
    required this.size,
    this.state = LetterBoxState.inactive,
    this.letter = "",
    this.flipController,
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
        boxColor = Colors.purple;
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
      padding: const EdgeInsets.all(Constants.boxMargin),
      margin: const EdgeInsets.all(Constants.boxMargin),
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
      padding: const EdgeInsets.all(Constants.boxMargin),
      margin: const EdgeInsets.all(Constants.boxMargin),
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
      front: hidden,
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
