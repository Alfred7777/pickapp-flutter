import 'package:flutter/material.dart';

class NavDraverItem extends StatelessWidget {
  final Icon icon;
  final Text text;
  final MaterialPageRoute<void> route;

  const NavDraverItem(this.icon, this.text, this.route);

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white,
        child: InkWell(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, route);
            },
            child: Container(
                height: 60,
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: Color(0x883D3A3A), width: 0.6))),
                child: Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 14.0), child: icon),
                    Padding(padding: EdgeInsets.only(left: 12.0), child: text)
                  ],
                ))));
  }
}
