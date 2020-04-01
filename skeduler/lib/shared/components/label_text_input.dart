import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LabelTextInput extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final String label;
  final String hintText;
  final String initialValue;
  final String Function(String) validator;
  final ValueSetter<String> valueSetterText;
  final ValueSetter<String> valueSetterValid;

  const LabelTextInput({
    this.formKey,
    this.controller,
    this.label = '',
    this.hintText = '',
    this.initialValue,
    this.validator,
    this.valueSetterText,
    this.valueSetterValid,
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
                onChanged: (value) {
                  if (widget.valueSetterText != null)
                    widget.valueSetterText(value);
                },
                validator: (value) {
                  if (widget.validator != null) {
                    String validity = widget.validator(value);
                    if (widget.valueSetterValid != null)
                      widget.valueSetterValid(validity);
                    return validity;
                  } else {
                    String validity = value != null && value != '' ? null : '';
                    if (widget.valueSetterValid != null)
                      widget.valueSetterValid(validity);
                    return validity;
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
