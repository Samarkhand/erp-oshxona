import 'package:flutter/material.dart';

class CardDashboard extends StatelessWidget {
  CardDashboard({this.title, this.subtitle, this.color, Key? key})
      : super(key: key);
  Text? title;
  Text? subtitle;
  Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title != null ? title! : const SizedBox(),
              SizedBox(height: (title == null || subtitle == null) ? 0 : 12),
              subtitle != null ? subtitle! : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class CardWithList extends StatelessWidget {
  const CardWithList({required this.child, this.color, this.height, Key? key})
      : super(key: key);
  final Widget child;
  final Color? color;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: height,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: child,
        ),
      ),
    );
  }
}
