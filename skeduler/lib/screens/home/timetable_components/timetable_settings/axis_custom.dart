import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/navigation/route_arguments.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';

class AxisCustom extends StatefulWidget {
  final List<String> initialCustoms;
  final ValueSetter<List<String>> valSetCustoms;
  final ValueGetter<List<String>> valGetCustoms;
  final bool initiallyExpanded;

  const AxisCustom({
    Key key,
    this.initialCustoms,
    this.valSetCustoms,
    this.valGetCustoms,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  _AxisCustomState createState() => _AxisCustomState();
}

class _AxisCustomState extends State<AxisCustom> {
  TimetableStatus _ttbStatus;
  List<String> _customVals;
  bool _expanded;

  List<Widget> _generateCustoms() {
    List<Widget> customValWidgets = [];

    _customVals.forEach((custom) {
      GlobalKey<FormState> formKey = GlobalKey<FormState>();
      String newCustom;

      customValWidgets.add(
        ListTile(
          key: UniqueKey(),
          dense: true,
          title: Text(custom),
          trailing: PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.edit),
                      SizedBox(width: 10.0),
                      Text('Edit'),
                    ],
                  ),
                  value: CustomOption.edit,
                ),
                PopupMenuItem(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.reorder),
                      SizedBox(width: 10.0),
                      Text('Reorder'),
                    ],
                  ),
                  value: CustomOption.reorder,
                ),
                PopupMenuItem(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.delete),
                      SizedBox(width: 10.0),
                      Text('Remove'),
                    ],
                  ),
                  value: CustomOption.remove,
                ),
              ];
            },
            onSelected: (value) async {
              switch (value) {
                case CustomOption.edit:
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          'Edit custom value',
                          style: TextStyle(fontSize: 15.0),
                        ),
                        content: Form(
                          key: formKey,
                          child: TextFormField(
                            initialValue: custom,
                            decoration: InputDecoration(
                              hintText: 'Type something here',
                              hintStyle: TextStyle(fontSize: 15.0),
                            ),
                            onChanged: (value) => newCustom = value,
                            validator: (value) {
                              if (value == null || value.trim() == '') {
                                return 'Value cannot be empty';
                              } else if (_ttbStatus.temp
                                  .groups[_ttbStatus.tempGroupIndex].axisCustom
                                  .contains(value)) {
                                return 'Value already exists';
                              } else {
                                _ttbStatus.temp.updateAxisCustomValue(
                                  prev: custom,
                                  next: value,
                                  groupIndex: 0,
                                );
                                return null;
                              }
                            },
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('CANCEL'),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          FlatButton(
                            child: Text('SAVE'),
                            onPressed: () {
                              if (formKey.currentState.validate()) {
                                setState(() {
                                  int index = _customVals.indexOf(custom);
                                  _customVals.removeAt(index);
                                  _customVals.insert(index, newCustom);
                                });

                                // update through valueSetter
                                if (widget.valSetCustoms != null) {
                                  widget.valSetCustoms(_customVals);
                                }

                                Navigator.of(context).maybePop();
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                  break;
                case CustomOption.reorder:
                  Navigator.of(context).pushNamed(
                    '/timetables/editor/settings/reorderAxisCustom',
                    arguments: RouteArgsReorderAxisCustom(
                      axisCustom: _customVals,
                      valSetAxisCustom: (value) {
                        setState(() {
                          _customVals = value;
                        });

                        // Update through valueSetter
                        if (widget.valSetCustoms != null) {
                          widget.valSetCustoms(_customVals);
                        }
                      },
                    ),
                  );
                  break;
                case CustomOption.remove:
                  setState(() => _customVals.remove(custom));

                  // Update through valueSetter
                  if (widget.valSetCustoms != null) {
                    widget.valSetCustoms(_customVals);
                  }
                  break;
              }
            },
          ),
        ),
      );
    });

    customValWidgets.add(_generateAddCustomButton());

    return customValWidgets;
  }

  Widget _generateAddCustomButton() {
    return ListTile(
      key: UniqueKey(),
      title: Icon(
        Icons.add_circle,
        size: 30.0,
      ),
      onTap: () async => await showDialog(
          context: context,
          builder: (context) {
            GlobalKey<FormState> formKey = GlobalKey<FormState>();
            String newCustom;

            return AlertDialog(
              title: Text(
                'Add custom value',
                style: TextStyle(fontSize: 15.0),
              ),
              content: Form(
                key: formKey,
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Type something here',
                    hintStyle: TextStyle(fontSize: 15.0),
                  ),
                  onChanged: (value) => newCustom = value,
                  validator: (value) {
                    if (value == null || value.trim() == '') {
                      return 'Value cannot be empty';
                    } else if (_customVals.contains(value)) {
                      return 'Value already exists';
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('CANCEL'),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                FlatButton(
                  child: Text('SAVE'),
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      setState(() => _customVals.add(newCustom));

                      // update through valueSetter
                      if (widget.valSetCustoms != null) {
                        widget.valSetCustoms(_customVals);
                      }

                      Navigator.of(context).maybePop();
                    }
                  },
                ),
              ],
            );
          }),
    );
  }

  @override
  void initState() {
    _expanded = widget.initiallyExpanded;
    _customVals = widget.initialCustoms ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _ttbStatus = Provider.of<TimetableStatus>(context);

    if (widget.valGetCustoms != null) {
      _customVals = widget.valGetCustoms();
    }

    return ExpansionTile(
      onExpansionChanged: (expanded) => setState(() => _expanded = !_expanded),
      initiallyExpanded: widget.initiallyExpanded,
      title: Text(
        'Axis 3 : Custom',
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
        ),
      ),
      trailing: Icon(
        _expanded ? Icons.expand_less : Icons.expand_more,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.white,
      ),
      children: _generateCustoms(),
    );
  }
}
