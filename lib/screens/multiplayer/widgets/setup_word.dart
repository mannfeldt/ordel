import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/services/multiplayer_provider.dart';
import 'package:ordel/services/user_provider.dart';
import 'package:ordel/utils/utils.dart';
import 'package:ordel/widgets/custom_snackbar.dart';
import 'package:ordel/widgets/word_grid.dart';
import 'package:provider/provider.dart';

class SetupWordScreen extends StatefulWidget {
  final String language;
  final String invite;
  const SetupWordScreen({
    Key? key,
    required this.language,
    required this.invite,
  }) : super(key: key);

  @override
  State<SetupWordScreen> createState() => _SetupWordScreenState();
}

class _SetupWordScreenState extends State<SetupWordScreen> {
  final List<String> _words = [];

  @override
  void initState() {
    List<String> wordList = RemoteConfig.instance
        .getString("answers_${widget.language}")
        .split(",")
        .where((w) => w.length == 5)
        .toList();
    Random _random = Random();
    while (_words.length < 3) {
      String randomWord = wordList[_random.nextInt(wordList.length)];
      if (!_words.contains(randomWord)) {
        _words.add(randomWord);
      }
    }

    super.initState();
  }

  void _createNewGame(String word, BuildContext context) async {
    try {
      User user = Provider.of<UserProvider>(context, listen: false)
          .getUserById(widget.invite);
      Provider.of<MultiplayerProvider>(context, listen: false)
          .createNewGame(word: word, invite: user, language: widget.language);
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    } catch (e) {
      ErrorSnackbar.display(context, "error creating new game");
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);
    double size = ((mq.size.width - 120) / 5);
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade800,
        centerTitle: true,
        title: Text(
          "Select starting word",
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.125,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.chevron_left,
            color: Colors.grey.shade100,
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: _words
            .map(
              (word) => Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  width: double.infinity,
                  child: MaterialButton(
                    elevation: 0,
                    focusElevation: 4,
                    highlightColor: Colors.grey.shade900,
                    splashColor: Colors.grey.shade900,
                    color: Colors.grey.shade900,
                    onPressed: () => _createNewGame(word, context),
                    child: Center(
                      child: IgnorePointer(
                        child: WordRow(
                          boxSize: size,
                          answer: word,
                          guess: word,
                          state: RowState.done,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
