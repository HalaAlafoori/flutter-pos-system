import 'package:flutter/material.dart';

class SingleRowWrap extends StatelessWidget {
  const SingleRowWrap({
    Key? key,
    required this.children,
  }) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Wrap(
            spacing: 4.0,
            children: children,
          ),
        ),
      ),
    );
  }
}
