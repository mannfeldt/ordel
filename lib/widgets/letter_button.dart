import 'package:flutter/material.dart';
import 'package:ordel/utils/constants.dart';
import 'package:ordel/utils/utils.dart';

class LetterButton extends StatelessWidget {
  final String letter;
  final KeyState state;
  final void Function(String) onTap;
  final double size;
  const LetterButton({
    Key? key,
    required this.onTap,
    required this.letter,
    required this.size,
    this.state = KeyState.unknow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Color color;
    switch (state) {
      case KeyState.unknow:
        color = Colors.grey.shade600;
        break;
      case KeyState.wrong:
        color = Colors.blueGrey.shade900;
        break;
      case KeyState.included:
        color = Colors.purple;
        break;
      case KeyState.correct:
        color = Colors.green;
        break;
      default:
    }
    return Container(
      margin: const EdgeInsets.all(Constants.keyMargin),
      height: size * 1.4,
      width: size,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: color,
          primary: Colors.white,
          textStyle: TextStyle(
            fontSize: size / 2,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(letter),
        onPressed: state != KeyState.wrong ? () => onTap(letter) : () {},
      ),
    );
  }
}
