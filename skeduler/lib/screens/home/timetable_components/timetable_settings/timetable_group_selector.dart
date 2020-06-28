import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/firestore/timetable.dart';
import 'package:skeduler/shared/simple_widgets.dart';
import 'package:skeduler/shared/ui_settings.dart';

class TimetableGroupSelector extends StatefulWidget {
  final ValueGetter<List<TimetableGroup>> valGetGroups;
  final ValueSetter<List<TimetableGroup>> valSetGroups;
  final ValueGetter<int> valGetGroupSelected;
  final ValueSetter<int> valSetGroupSelected;

  TimetableGroupSelector({
    Key key,
    this.valGetGroups,
    this.valSetGroups,
    this.valGetGroupSelected,
    this.valSetGroupSelected,
  }) : super(key: key);

  @override
  _TimetableGroupSelectorState createState() => _TimetableGroupSelectorState();
}

class _TimetableGroupSelectorState extends State<TimetableGroupSelector> {
  OriginTheme _originTheme;
  double _padding = 10;

  List<Widget> _generateTimetableGroups() {
    const int maxTimetableGroups = 4;
    List<Widget> widgets = [];

    double height = 40;
    double width = widget.valGetGroups().length < maxTimetableGroups
        ? (MediaQuery.of(context).size.width - (_padding * 2)) /
            (widget.valGetGroups().length + 1)
        : (MediaQuery.of(context).size.width - (_padding * 2)) /
            (widget.valGetGroups().length + 0.5);

    for (int i = 0; i < widget.valGetGroups().length; i++) {
      widgets.add(Container(
          width: width,
          height: height,
          child: FlatButton(
              splashColor: _originTheme.primaryColor,
              color: widget.valGetGroupSelected() == i
                  ? _originTheme.primaryColor
                  : Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(height / 2)),
              onPressed: () => setState(() {
                    if (widget.valSetGroupSelected != null) {
                      widget.valSetGroupSelected(i);
                    }
                  }),
              child: Text((i + 1).toString(),
                  style: textStyleBody.copyWith(
                      color: widget.valGetGroupSelected() == i
                          ? _originTheme.textColor
                          : Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white)))));
    }

    // add button
    if (widget.valGetGroups().length < maxTimetableGroups) {
      widgets.add(Container(
          width: widget.valGetGroups().length > 1 ? width / 2 : width,
          height: height,
          child: FlatButton(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(height / 2)),
              onPressed: () {
                if (widget.valGetGroups().length < maxTimetableGroups) {
                  setState(() {
                    if (widget.valGetGroups != null) {
                      List<TimetableGroup> newGroups =
                          List.from(widget.valGetGroups());
                      if (widget.valSetGroups != null) {
                        newGroups.add(TimetableGroup());
                        widget.valSetGroups(newGroups);
                      }

                      if (widget.valSetGroupSelected != null) {
                        widget.valSetGroupSelected(newGroups.length - 1);
                      }
                    }
                  });
                }
              },
              child: Icon(Icons.add))));
    }

    // delete button
    if (widget.valGetGroups().length > 1) {
      widgets.add(Container(
          width: widget.valGetGroups().length < maxTimetableGroups
              ? width / 2
              : width / 2,
          height: height,
          child: FlatButton(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(height / 2)),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleAlertDialog(
                          context: context,
                          contentDisplay: 'Delete Timetable group ' +
                              (widget.valGetGroupSelected() + 1).toString() +
                              '?',
                          confirmDisplay: 'DELETE',
                          confirmFunction: () {
                            setState(() {
                              if (widget.valSetGroups != null) {
                                List<TimetableGroup> newGroups =
                                    List.from(widget.valGetGroups());
                                newGroups
                                    .removeAt(widget.valGetGroupSelected());
                                widget.valSetGroups(newGroups);
                                int newIndex = widget.valGetGroupSelected() - 1;
                                newIndex = newIndex < 0 ? 0 : newIndex;
                                widget.valSetGroupSelected(newIndex);
                              }
                              Navigator.of(context).maybePop();
                            });
                          });
                    });
              },
              child: Center(child: Icon(Icons.delete)))));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    _originTheme = Provider.of<OriginTheme>(context);

    return Container(
        padding: EdgeInsets.symmetric(horizontal: _padding),
        width: MediaQuery.of(context).size.width,
        child: Row(children: _generateTimetableGroups()));
  }
}
