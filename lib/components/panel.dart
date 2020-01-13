import 'package:flutter/material.dart';

class Panel extends StatelessWidget {
  final Widget child;

  Panel({this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
        padding: EdgeInsets.all(8),
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor, width: 2.0),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: child));
  }
}
