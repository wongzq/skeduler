import 'package:flutter/material.dart';

// Text input decoration: default
InputDecoration textInputDecoration(BuildContext context) {
  return InputDecoration(
    errorStyle: TextStyle(fontSize: 12.0),
    fillColor: Colors.white,
    filled: true,

    // On Enabled
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.white,
        width: 1.0,
      ),
    ),

    // On Focused
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(const Radius.circular(30.0)),
      borderSide: BorderSide(
        color: Colors.black,
        width: 1.0,
      ),
    ),

    // On Error
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.red,
        width: 1.0,
      ),
    ),

    // On Focused Error
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(const Radius.circular(30.0)),
      borderSide: BorderSide(
        color: Colors.red,
        width: 1.0,
      ),
    ),
  );
}

// Text input decoration: valid
InputDecoration textInputDecorationValid(BuildContext context) {
  return InputDecoration(
    fillColor: Colors.white,
    filled: true,

    // On Enabled
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(const Radius.circular(30.0)),
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
        width: 1.0,
      ),
    ),

    // On Focused
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(const Radius.circular(30.0)),
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
        width: 1.0,
      ),
    ),
  );
}

// Text style: for drawer list tile
const TextStyle textStyleHeader = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.w600,
  letterSpacing: 1.0,
);

const TextStyle textStyleBody = TextStyle(
  fontSize: 14.0,
  fontWeight: FontWeight.w400,
  letterSpacing: 1.0,
);

const TextStyle textStyleBodyLight = TextStyle(
  fontSize: 14.0,
  fontWeight: FontWeight.w400,
  letterSpacing: 1.0,
  color: Color(0xFFBBBBBB),
);