import 'package:flutter/material.dart';

class AxisCustom extends StatefulWidget {
  final ValueSetter<List<String>> valSetCustoms;
  final List<String> initialCustoms;
  final bool initiallyExpanded;

  const AxisCustom({
    Key key,
    this.valSetCustoms,
    this.initialCustoms,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  _AxisCustomState createState() => _AxisCustomState();
}

class _AxisCustomState extends State<AxisCustom> {
  List<String> _customs;

  bool _expanded;

  List<Widget> _generateCustoms() {
    List<Widget> customValWidgets = [];

    _customs.forEach((custom) {
      GlobalKey<FormState> formKey = GlobalKey<FormState>();
      String newCustom;

      customValWidgets.add(
        ListTile(
          dense: true,
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
                          'Add custom value',
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
                                  int index = _customs.indexOf(custom);
                                  _customs.removeAt(index);
                                  _customs.insert(index, newCustom);
                                });
                              }

                              /// update through valueSetter
                              if (widget.valSetCustoms != null) {
                                widget.valSetCustoms(_customs);
                              }

                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  break;
                case CustomOption.remove:
                  setState(() => _customs.remove(custom));
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
      title: Icon(
        Icons.add_circle,
        size: 30.0,
      ),
      onTap: () => showDialog(
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
                  validator: (value) => value == null || value.trim() == ''
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
                      setState(() => _customs.add(newCustom));
                    }

                    /// update through valueSetter
                    if (widget.valSetCustoms != null) {
                      widget.valSetCustoms(_customs);
                    }

                    Navigator.of(context).pop();
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
    _customs = widget.initialCustoms ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

enum CustomOption {
  edit,
  remove,
}
