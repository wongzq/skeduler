import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class AxisCustomReoder extends StatefulWidget {
  final List<String> axisCustom;
  final ValueSetter<List<String>> valSetAxisCustom;

  const AxisCustomReoder({
    Key key,
    this.axisCustom,
    this.valSetAxisCustom,
  }) : super(key: key);

  @override
  _AxisCustomReoderState createState() => _AxisCustomReoderState();
}

class _AxisCustomReoderState extends State<AxisCustomReoder> {
  // properties
  TimetableStatus _ttbStatus;
  List<String> _customVals;

  // methods
  List<Widget> _generateCustoms(context) {
    List<Widget> customValWidgets = [];

    _customVals.forEach((custom) {
      GlobalKey<FormState> formKey = GlobalKey<FormState>();
      String newCustom;

      customValWidgets.add(
        Column(
          key: UniqueKey(),
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              dense: true,
              leading: Icon(Icons.reorder),
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
                          Icon(Icons.delete),
                          SizedBox(width: 10.0),
                          Text('Remove'),
                        ],
                      ),
                      value: CustomOption.remove,
                    ),
                  ];
                },
                onSelected: (val) async {
                  switch (val) {
                    case CustomOption.edit:
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              'Edit custom value',
                              style: TextStyle(fontSize: 16.0),
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
                                  } else if (_ttbStatus.temp.axisCustom
                                      .contains(value)) {
                                    return 'Value already exists';
                                  } else {
                                    _ttbStatus.updateTempAxisCustomValue(
                                      prev: custom,
                                      next: value,
                                    );
                                    return null;
                                  }
                                },
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('CANCEL'),
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                              ),
                              FlatButton(
                                child: Text('SAVE'),
                                onPressed: () {
                                  if (formKey.currentState.validate()) {
                                    setState(() {
                                      int index = _customVals.indexOf(custom);
                                      _customVals.removeAt(index);

                                      if (index >= _customVals.length) {
                                        _customVals.add(newCustom);
                                      } else {
                                        _customVals.insert(index, newCustom);
                                      }
                                    });

                                    // update through valueSetter
                                    if (widget.valSetAxisCustom != null) {
                                      widget.valSetAxisCustom(_customVals);
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
                    case CustomOption.remove:
                      setState(() => _customVals.remove(custom));

                      // update through valueSetter
                      if (widget.valSetAxisCustom != null) {
                        widget.valSetAxisCustom(_customVals);
                      }
                      break;
                  }
                },
              ),
            ),
            Divider(height: 1.0),
          ],
        ),
      );
    });

    return customValWidgets;
  }

  @override
  void initState() {
    _customVals = widget.axisCustom ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _ttbStatus = Provider.of<TimetableStatus>(context);

    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title: 'Reorder'),
        actions: <Widget>[
          _customVals.length < 1
              ? IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    await showDialog(
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
                                  } else if (_ttbStatus.temp.axisCustom
                                      .contains(value)) {
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
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                              ),
                              FlatButton(
                                child: Text('SAVE'),
                                onPressed: () {
                                  if (formKey.currentState.validate()) {
                                    setState(() => _customVals.add(newCustom));

                                    // update through valueSetter
                                    if (widget.valSetAxisCustom != null) {
                                      widget.valSetAxisCustom(_customVals);
                                    }

                                    Navigator.of(context).maybePop();
                                  }
                                },
                              ),
                            ],
                          );
                        });
                  },
                )
              : Container(),
        ],
      ),
      body: ReorderableListView(
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            String customVal = _customVals[oldIndex];
            _customVals.removeAt(oldIndex);

            if (newIndex >= _customVals.length) {
              _customVals.add(customVal);
            } else {
              _customVals.insert(newIndex, customVal);
            }

            if (widget.valSetAxisCustom != null) {
              widget.valSetAxisCustom(_customVals);
            }
          });
        },
        children: _generateCustoms(context),
      ),
    );
  }
}
