import 'package:flutter/material.dart';

/// RestartWidget.restartApp(context)
class RestartWidget extends StatefulWidget {
  const RestartWidget(this.child, {super.key});

  final Widget child;

  static restartApp(BuildContext context) {
    context.findAncestorStateOfType<RestartWidgetState>()!.restartApp();
  }

  @override
  RestartWidgetState createState() => RestartWidgetState();
}

class RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
