import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/screens/home/timetable_components/member_selector.dart';
import 'package:skeduler/screens/home/timetable_components/subject_selector.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_grid/timetable_grid.dart';

class TimetableDisplay extends StatefulWidget {
  final TimetableEditMode editMode;

  TimetableDisplay({
    Key key,
    @required this.editMode,
  }) : super(key: key);

  @override
  _TimetableDisplayState createState() => _TimetableDisplayState();
}

class _TimetableDisplayState extends State<TimetableDisplay> {
  Color _containerColor = Colors.black;
  int _animationDuration = 300;
  Curve _animationCurve = Curves.easeInCubic;

  @override
  Widget build(BuildContext context) {
    OriginTheme originTheme = Provider.of<OriginTheme>(context);

    return ChangeNotifierProvider<TimetableEditMode>.value(
      value: widget.editMode,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double selectorHeight = 80;
          double timetableDisplayHeight =
              constraints.maxHeight - selectorHeight * 2;

          return Consumer<TimetableEditMode>(
            builder: (context, editMode, _) {
              return Stack(
                children: <Widget>[
                  Container(
                    height: constraints.maxHeight,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10.0),
                          height: editMode.editing
                              ? timetableDisplayHeight
                              : timetableDisplayHeight + selectorHeight,
                          child: TimetableGrid(),
                        ),
                        !editMode.editing
                            ? Container(
                                height: selectorHeight,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        color: editMode.viewMe
                                            ? Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? originTheme.primaryColor
                                                : originTheme.primaryColorLight
                                            : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.remove_red_eye,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                          ),
                                          onPressed: () {
                                            editMode.viewMe = !editMode.viewMe;
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Text(
                                      'View me',
                                      style: TextStyle(
                                        color: editMode.viewMe
                                            ? null
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                height: selectorHeight,
                                child: Stack(
                                  children: <Widget>[
                                    AbsorbPointer(
                                      absorbing: !editMode.dragSubject,
                                      child: Center(
                                        child: SubjectSelector(
                                          activated: editMode.dragSubject,
                                          additionalSpacing:
                                              constraints.maxWidth / 5,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      height: selectorHeight,
                                      width: constraints.maxWidth / 5,
                                      right: 0.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerRight,
                                            end: Alignment.centerLeft,
                                            stops: [0.5, 0.8, 1],
                                            colors: [
                                              Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              Theme.of(context)
                                                  .scaffoldBackgroundColor
                                                  .withOpacity(0.8),
                                              Theme.of(context)
                                                  .scaffoldBackgroundColor
                                                  .withOpacity(0),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Switch(
                                            activeColor:
                                                Theme.of(context).accentColor,
                                            value: editMode.dragSubject,
                                            onChanged: (value) {
                                              setState(() =>
                                                  editMode.dragSubject = value);
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                        !editMode.editing
                            ? Container()
                            : Container(
                                height: selectorHeight,
                                child: Stack(
                                  children: <Widget>[
                                    AbsorbPointer(
                                      absorbing: !editMode.dragMember,
                                      child: Center(
                                        child: MemberSelector(
                                          activated: editMode.dragMember,
                                          additionalSpacing:
                                              constraints.maxWidth / 5,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      height: selectorHeight,
                                      width: constraints.maxWidth / 5,
                                      right: 0.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerRight,
                                            end: Alignment.centerLeft,
                                            stops: [0.5, 0.8, 1],
                                            colors: [
                                              Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              Theme.of(context)
                                                  .scaffoldBackgroundColor
                                                  .withOpacity(0.8),
                                              Theme.of(context)
                                                  .scaffoldBackgroundColor
                                                  .withOpacity(0),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Switch(
                                            activeColor:
                                                Theme.of(context).accentColor,
                                            value: editMode.dragMember,
                                            onChanged: (value) {
                                              setState(() =>
                                                  editMode.dragMember = value);
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                  !editMode.editing
                      ? Container()
                      : Consumer<TimetableEditMode>(
                          builder: (context, editModeConsumer, _) {
                            return AnimatedPositioned(
                              duration:
                                  Duration(milliseconds: _animationDuration),
                              curve: _animationCurve,
                              top: editModeConsumer.binVisible
                                  ? timetableDisplayHeight
                                  : constraints.maxHeight,
                              child: DragTarget<TimetableDragData>(
                                onWillAccept: (value) {
                                  _containerColor = Colors.red;
                                  return true;
                                },
                                onAccept: (_) => _containerColor = Colors.black,
                                onLeave: (_) => _containerColor = Colors.black,
                                builder: (_, __, ___) {
                                  return AnimatedContainer(
                                    duration: Duration(
                                        milliseconds: _animationDuration),
                                    curve: _animationCurve,
                                    alignment: Alignment.bottomCenter,
                                    height: editModeConsumer.binVisible
                                        ? selectorHeight * 2
                                        : 0,
                                    width: constraints.maxWidth,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          _containerColor,
                                          Colors.transparent
                                        ],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: AnimatedCrossFade(
                                        duration: Duration(
                                            milliseconds: _animationDuration),
                                        firstCurve: _animationCurve,
                                        secondCurve: _animationCurve,
                                        crossFadeState:
                                            editModeConsumer.binVisible
                                                ? CrossFadeState.showFirst
                                                : CrossFadeState.showSecond,
                                        firstChild: Icon(
                                          Icons.delete,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                        secondChild: Icon(
                                          null,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
