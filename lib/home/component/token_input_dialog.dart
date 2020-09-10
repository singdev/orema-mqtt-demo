import 'package:flutter/material.dart';

import '../home_bloc.dart';

class TokenInputDialog extends StatefulWidget {
  final TextEditingController controller;
  final Function onRecharge;

  const TokenInputDialog({Key key, this.controller, this.onRecharge}) : super(key: key);
  @override
  _TokenInputDialogState createState() => _TokenInputDialogState();
}

class _TokenInputDialogState extends State<TokenInputDialog> {
  bool errorToken = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Recharge"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.controller,
            onChanged: (v) {
              setState(() {
                errorToken = widget.controller.text.length != 20;
              });
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: "Token",
                errorText: errorToken ? "20 chiffres" : null),
          )
        ],
      ),
      actions: [
        FlatButton(
          onPressed: errorToken
              ? null
              : widget.onRecharge,
          child: Text("RECHARGER"),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("ANNULER"),
        ),
      ],
    );
  }
}
