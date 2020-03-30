import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

const Color defaultColor = Colors.teal;

final List<AppTheme> myAppThemes = [
  AppTheme(
      id: 'pink',
      description: 'Pink',
      data: ThemeData(
          primarySwatch: Colors.pink,
          accentColor: Colors.pinkAccent,
          brightness: Brightness.light)),
  AppTheme(
      id: 'red',
      description: 'Red',
      data: ThemeData(
          primarySwatch: Colors.red,
          accentColor: Colors.redAccent,
          brightness: Brightness.light)),
  AppTheme(
      id: 'deep_orange',
      description: 'Deep orange',
      data: ThemeData(
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.deepOrangeAccent,
          brightness: Brightness.light)),
  AppTheme(
      id: 'orange',
      description: 'Orange',
      data: ThemeData(
          primarySwatch: Colors.orange,
          accentColor: Colors.orangeAccent,
          brightness: Brightness.light)),
  AppTheme(
      id: 'amber',
      description: 'Amber',
      data: ThemeData(
          primarySwatch: Colors.amber,
          accentColor: Colors.amberAccent,
          brightness: Brightness.light)),
  AppTheme(
      id: 'yellow',
      description: 'Yellow',
      data: ThemeData(
          primarySwatch: Colors.yellow,
          accentColor: Colors.yellowAccent,
          brightness: Brightness.light)),
  AppTheme(
      id: 'lime',
      description: 'Lime',
      data: ThemeData(
          primarySwatch: Colors.lime,
          accentColor: Colors.limeAccent,
          brightness: Brightness.light)),
  AppTheme(
      id: 'light_green',
      description: 'Light green',
      data: ThemeData(
          primarySwatch: Colors.lightGreen,
          accentColor: Colors.lightGreenAccent,
          brightness: Brightness.light)),
  AppTheme(
      id: 'green',
      description: 'Green',
      data: ThemeData(
          primarySwatch: Colors.green,
          accentColor: Colors.greenAccent,
          brightness: Brightness.light)),
  AppTheme(
      id: 'teal',
      description: 'Teal',
      data: ThemeData(
          primarySwatch: Colors.teal,
          accentColor: Colors.tealAccent,
          brightness: Brightness.light)),
  AppTheme(
      id: 'cyan',
      description: 'Cyan',
      data: ThemeData(
          primarySwatch: Colors.cyan,
          accentColor: Colors.cyanAccent,
          brightness: Brightness.light)),
  AppTheme(
      id: 'light_blue',
      description: 'Light blue',
      data: ThemeData(
          primarySwatch: Colors.lightBlue,
          accentColor: Colors.lightBlueAccent,
          brightness: Brightness.light)),
  AppTheme(
      id: 'blue',
      description: 'Blue',
      data: ThemeData(
          primarySwatch: Colors.blue,
          accentColor: Colors.blueAccent,
          brightness: Brightness.light)),
  AppTheme(
      id: 'indigo',
      description: 'Indigo',
      data: ThemeData(
          primarySwatch: Colors.indigo,
          accentColor: Colors.indigoAccent,
          brightness: Brightness.light)),
  AppTheme(
      id: 'deep_purple',
      description: 'Deep purple',
      data: ThemeData(
          primarySwatch: Colors.deepPurple,
          accentColor: Colors.deepPurpleAccent,
          brightness: Brightness.light)),
  AppTheme(
      id: 'purple',
      description: 'Purple',
      data: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.purpleAccent,
          brightness: Brightness.light)),
];

List<AppTheme> myAppDarkThemes = [
  AppTheme(
      id: 'pink_dark',
      description: 'Pink - Dark',
      data: ThemeData(
          primarySwatch: Colors.pink,
          accentColor: Colors.pinkAccent,
          brightness: Brightness.dark)),
  AppTheme(
      id: 'red_dark',
      description: 'Red - Dark',
      data: ThemeData(
          primarySwatch: Colors.red,
          accentColor: Colors.redAccent,
          brightness: Brightness.dark)),
  AppTheme(
      id: 'deep_orange_dark',
      description: 'Deep orange - Dark',
      data: ThemeData(
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.deepOrangeAccent,
          brightness: Brightness.dark)),
  AppTheme(
      id: 'orange_dark',
      description: 'Orange - Dark',
      data: ThemeData(
          primarySwatch: Colors.orange,
          accentColor: Colors.orangeAccent,
          brightness: Brightness.dark)),
  AppTheme(
      id: 'amber_dark',
      description: 'Amber - Dark',
      data: ThemeData(
          primarySwatch: Colors.amber,
          accentColor: Colors.amberAccent,
          brightness: Brightness.dark)),
  AppTheme(
      id: 'yellow_dark',
      description: 'Yellow - Dark',
      data: ThemeData(
          primarySwatch: Colors.yellow,
          accentColor: Colors.yellowAccent,
          brightness: Brightness.dark)),
  AppTheme(
      id: 'lime_dark',
      description: 'Lime - Dark',
      data: ThemeData(
          primarySwatch: Colors.lime,
          accentColor: Colors.limeAccent,
          brightness: Brightness.dark)),
  AppTheme(
      id: 'light_green_dark',
      description: 'Light green - Dark',
      data: ThemeData(
          primarySwatch: Colors.lightGreen,
          accentColor: Colors.lightGreenAccent,
          brightness: Brightness.dark)),
  AppTheme(
      id: 'green_dark',
      description: 'Green - Dark',
      data: ThemeData(
          primarySwatch: Colors.green,
          accentColor: Colors.greenAccent,
          brightness: Brightness.dark)),
  AppTheme(
      id: 'teal_dark',
      description: 'Teal - Dark',
      data: ThemeData(
          primarySwatch: Colors.teal,
          accentColor: Colors.tealAccent,
          brightness: Brightness.dark)),
  AppTheme(
      id: 'cyan_dark',
      description: 'Cyan - Dark',
      data: ThemeData(
          primarySwatch: Colors.cyan,
          accentColor: Colors.cyanAccent,
          brightness: Brightness.dark)),
  AppTheme(
      id: 'light_blue_dark',
      description: 'Light blue - Dark',
      data: ThemeData(
          primarySwatch: Colors.lightBlue,
          accentColor: Colors.lightBlueAccent,
          brightness: Brightness.dark)),
  AppTheme(
      id: 'blue_dark',
      description: 'Blue - Dark',
      data: ThemeData(
          primarySwatch: Colors.blue,
          accentColor: Colors.blueAccent,
          brightness: Brightness.dark)),
  AppTheme(
      id: 'indigo_dark',
      description: 'Indigo - Dark',
      data: ThemeData(
          primarySwatch: Colors.indigo,
          accentColor: Colors.indigoAccent,
          brightness: Brightness.dark)),
  AppTheme(
      id: 'deep_purple_dark',
      description: 'Deep purple - Dark',
      data: ThemeData(
          primarySwatch: Colors.deepPurple,
          accentColor: Colors.deepPurpleAccent,
          brightness: Brightness.dark)),
  AppTheme(
      id: 'purple_dark',
      description: 'Purple - Dark',
      data: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.purpleAccent,
          brightness: Brightness.dark)),
];
