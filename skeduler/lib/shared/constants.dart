import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,

  // When Enabled
  enabledBorder: OutlineInputBorder(
    // borderRadius: const BorderRadius.all(
    //   const Radius.circular(30.0),
    // ),
    borderSide: BorderSide(
      color: Colors.white,
      width: 1.0,
    ),
  ),

  // When Focused
  focusedBorder: OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      const Radius.circular(30.0),
    ),
    borderSide: BorderSide(
      color: Colors.black,
      width: 1.0,
    ),
  ),
);
