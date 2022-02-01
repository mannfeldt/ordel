import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:ordel/models/language_model.dart';
import 'package:ordel/navigation/app_router.dart';

class SetupLanguageScreen extends StatefulWidget {
  const SetupLanguageScreen({Key? key}) : super(key: key);

  @override
  State<SetupLanguageScreen> createState() => _SetupLanguageScreenState();
}

class _SetupLanguageScreenState extends State<SetupLanguageScreen> {
  late List<Language> _supportedLanguages;

  @override
  void initState() {
    _supportedLanguages = RemoteConfig.instance
        .getString("supported_languages")
        .split(",")
        .toList()
        .map((l) => Language(l.split(":").first, l.split(":").last))
        .toList();

    super.initState();
  }

  void _nextStep(Language language, BuildContext context) {
    AppRouter.navigateTo(
      context,
      "${AppRouter.SETUP_INVITE_SCREEN}?language=${language.code}",
      transition: TransitionType.inFromRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Select language",
          style: TextStyle(
            color: Colors.black87,
            letterSpacing: 1.125,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.chevron_left,
            color: Colors.blue,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20),
          itemCount: _supportedLanguages.length,
          itemBuilder: (BuildContext ctx, index) {
            Language language = _supportedLanguages[index];
            return GestureDetector(
              onTap: () => _nextStep(language, context),
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(language.name),
                    FractionallySizedBox(
                      widthFactor: 0.4,
                      child: Image.asset(
                        "assets/img/${language.code}.png",
                        errorBuilder: (context, error, stackTrace) =>
                            SizedBox(),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
