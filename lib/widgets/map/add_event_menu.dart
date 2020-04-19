import 'package:flutter/material.dart';

class AddEventMenuButton {
AddEventMenuButton({this.icon, this.action, this.label, this.color});
  IconData icon;
  VoidCallback action;
  String label;
  Color color;
}
