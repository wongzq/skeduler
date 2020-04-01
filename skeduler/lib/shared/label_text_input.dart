import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LabelTextInput extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String label;
  final String hintText;
  final ValueSetter<String> valueSetter;
  final String Function(String) validator;
  final TextEditingController controller;
  final String initialValue;

  const LabelTextInput({
    this.formKey,
    this.label = '',
    this.hintText = '',
    this.valueSetter,
    this.validator,
    this.controller, this.initialValue,
  });

  @override
  _LabelTextInputState createState() => _LabelTextInputState();
}

class _LabelTextInputState extends State<LabelTextInput> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
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
            child: Form(
              key: widget.formKey,
              child: TextFormField(
                initialValue: widget.initialValue,
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
                style: TextStyle(fontSize: 15.0),
                onChanged: (value) => widget.valueSetter(value),
                validator: (value) {
                  if (widget.validator != null) {
                    return widget.validator(value);
                  } else {
                    return value != null && value != '' ? null : '';
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
