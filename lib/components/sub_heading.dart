import 'package:flutter/material.dart';

class SubHeading extends StatelessWidget {

  String text;

  SubHeading({
    super.key,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text(
                text,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[400]),)),
            ),
          ),
        ),
      ],
    );
  }
}
