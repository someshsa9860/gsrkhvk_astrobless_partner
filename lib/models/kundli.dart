import 'package:flutter/material.dart';

class KundliGender {
  dynamic title;
  bool? isSelected;
  dynamic image;
  KundliGender({this.title, this.isSelected, this.image});
}

class Kundli {
  IconData? icon;
  bool? isSelected;
  Kundli({this.icon, this.isSelected});
}

class KundliDetailTab {
  dynamic title;
  bool isSelected;
  KundliDetailTab({required this.title, required this.isSelected});
}

class KundliDetails {
  dynamic title;
  dynamic value;
  KundliDetails({this.title, this.value});
}
