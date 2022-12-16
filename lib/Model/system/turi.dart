import 'package:flutter/material.dart';

class Tur {

  int tr;
  String nomi;
  Color ranggi;
  IconData icon;
  Tur(this.tr, this.nomi, {this.ranggi = const Color(0x00000000), this.icon = const IconData(0)});

  @override
  String toString(){
    return tr.toString();
  }
}