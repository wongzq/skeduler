import 'package:flutter/material.dart';

class LabelTextInput extends StatefulWidget {
  final String label;
  final String hintText;
  final ValueSetter<String> valueSetter;

  const LabelTextInput({this.label = '', this.hintText = '', this.valueSetter});

  @override
  _LabelTextInputState createState() => _LabelTextInputState();
}

class _LabelTextInputState extends State<LabelTextInput> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 100.0,
            child: Text(
              widget.label,
              style: TextStyle(fontSize: 15.0),
            ),
          ),
          Expanded(
            child: TextFormField(
              initialValue: null,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  // fontStyle: FontStyle.italic,
                ),
              ),
              style: TextStyle(fontSize: 15.0),
              onChanged: (value) => widget.valueSetter(value),
            ),
          )
        ],
      ),
    );
  }
}
