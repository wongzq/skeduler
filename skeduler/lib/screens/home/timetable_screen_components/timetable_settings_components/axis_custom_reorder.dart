import 'package:flutter/material.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_settings_components/axis_custom.dart';

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
  /// properties
  List<String> _customVals;

  /// methods
  List<Widget> _generateCustoms(context) {
    List<Widget> customValWidgets = [];

    _customVals.forEach((custom) {
      GlobalKey<FormState> formKey = GlobalKey<FormState>();
      String newCustom;

      customValWidgets.add(
        ListTile(
          key: UniqueKey(),
          dense: true,
          leading: Icon(Icons.reorder),
          title: Text(custom),
          trailing: PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text('Edit'),
                  value: CustomOption.edit,
                ),
                PopupMenuItem(
                  child: Text('Remove'),
                  value: CustomOption.remove,
                ),
              ];
            },
            onSelected: (val) {
              switch (val) {
                case CustomOption.edit:
                  showDialog(
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
                            validator: (value) =>
                                value == null || value.trim() == ''
                                    ? 'Value cannot be empty'
                                    : null,
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('CANCEL'),
                            onPressed: () => Navigator.of(context).pop(),
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

                                /// update through valueSetter
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

                  /// update through valueSetter
                  if (widget.valSetAxisCustom != null) {
                    widget.valSetAxisCustom(_customVals);
                  }
                  break;
              }
            },
          ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Reorder'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
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
                          validator: (value) =>
                              value == null || value.trim() == ''
                                  ? 'Value cannot be empty'
                                  : null,
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('CANCEL'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        FlatButton(
                          child: Text('SAVE'),
                          onPressed: () {
                            if (formKey.currentState.validate()) {
                              setState(() => widget.axisCustom.add(newCustom));
                            }

                            /// update through valueSetter
                            if (widget.valSetAxisCustom != null) {
                              widget.valSetAxisCustom(widget.axisCustom);
                            }

                            Navigator.of(context).maybePop();
                          },
                        ),
                      ],
                    );
                  });
            },
          )
        ],
      ),
      body: ReorderableListView(
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            String customVal = widget.axisCustom[oldIndex];
            widget.axisCustom.removeAt(oldIndex);

            if (newIndex >= widget.axisCustom.length) {
              widget.axisCustom.add(customVal);
            } else {
              widget.axisCustom.insert(newIndex, customVal);
            }
            if (widget.valSetAxisCustom != null) {
              widget.valSetAxisCustom(widget.axisCustom);
            }
          });
        },
        children: _generateCustoms(context),
      ),
    );
  }
}
