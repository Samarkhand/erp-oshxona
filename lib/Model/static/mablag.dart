
import 'package:flutter/material.dart';

class MablagSaqlashTuri {
  static final MablagSaqlashTuri naqd = MablagSaqlashTuri(1, "Naqd", Icons.money, Colors.green.hashCode);
  static final MablagSaqlashTuri plastik = MablagSaqlashTuri(2, "Plastik", Icons.credit_card, Colors.orange.hashCode);
  static final MablagSaqlashTuri elHamyon = MablagSaqlashTuri(3, "El.hamyon", Icons.wallet, Colors.blue.hashCode);
  static final MablagSaqlashTuri bank = MablagSaqlashTuri(4, "Bank hisob", Icons.account_balance, Colors.purple.hashCode);

  static Map<int, MablagSaqlashTuri> obyektlar = {
    0: MablagSaqlashTuri(0, "Noma'lum", const IconData(0), 0), 
    naqd.tr: naqd,
    plastik.tr: plastik,
    elHamyon.tr: elHamyon,
    bank.tr: bank,
  };

  int tr;
  String nomi;
  IconData icon;
  int color;

  MablagSaqlashTuri(this.tr, this.nomi, this.icon, this.color);

  @override
  String toString() => nomi;

  @override
  operator ==(other) => other is MablagSaqlashTuri && other.tr == tr;

  @override
  int get hashCode => tr.hashCode^nomi.hashCode^color.hashCode;
}
