import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract class LoadController {
  Future load();
  void retry();
  bool get isEmpty;
  bool get isInitialized;
}

class Loader extends StatelessWidget {
  final Widget waiting;
  final Widget result;
  final Widget empty;
  final Widget error;

  final LoadController controller;

  Loader({
    Key? key,
    required this.controller,
    required this.result,
    waiting,
    empty,
    error,
  })  : error = error ??
            DefaultErrorWidget(retry: controller.retry, fullscreen: true),
        waiting = waiting ?? const DefaultWaitingWidget(),
        empty = empty ?? DefaultEmptyWidget(message: "Ops, no result found"),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.isInitialized) return controller.isEmpty ? empty : result;

    return FutureBuilder(
      future: controller.load(),
      builder: (context, snapshot) {
        return snapshot.connectionState == ConnectionState.done &&
                snapshot.hasError
            ? error
            : waiting;
      },
    );
  }
}

class DefaultWaitingWidget extends StatefulWidget {
  const DefaultWaitingWidget({Key? key}) : super(key: key);

  @override
  _DefaultWaitingWidgetState createState() => _DefaultWaitingWidgetState();
}

class _DefaultWaitingWidgetState extends State<DefaultWaitingWidget>
    with TickerProviderStateMixin {
  late AnimationController animation;
  late Animation<double> _fade;
  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(animation);

    animation.forward();
  }

  @override
  void dispose() {
    animation.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      ),
    );
  }
}

class DefaultEmptyWidget extends StatelessWidget {
  final bool fullscreen;
  String? message;
  String? illustration;

  DefaultEmptyWidget({
    Key? key,
    this.fullscreen = false,
    this.message,
    this.illustration,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (fullscreen) {
      return Center(
        child: Column(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: mq.size.height / 2,
                  maxWidth: max(300, mq.size.width / 2),
                ),
                child: SvgPicture.asset(illustration ??
                    "assets/img/default_empty_illustration.svg"),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(message ?? "Ops, nothing was found"),
                ],
              ),
            )
          ],
        ),
      );
    }
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(message ?? "Ops, nothing was found"),
      ),
    );
  }
}

class DefaultErrorWidget extends StatelessWidget {
  final void Function() retry;
  final bool fullscreen;
  String? message;
  String? illustration;

  DefaultErrorWidget({
    Key? key,
    required this.retry,
    this.fullscreen = false,
    this.message,
    this.illustration,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (fullscreen) {
      return Center(
        child: Column(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                constraints: BoxConstraints(maxHeight: mq.size.height / 2),
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(illustration ??
                    "assets/img/default_error_illustration.svg"),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(message ?? "Ops, something went wrong"),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: RaisedButton(
                      child: const Text("Retry"),
                      onPressed: retry,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );
    }
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(message ?? "Ops, something went wrong"),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: RaisedButton(
                    child: const Text("Retry"),
                    onPressed: retry,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
