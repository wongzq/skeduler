import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
