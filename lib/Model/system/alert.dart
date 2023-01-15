
import 'package:erp_oshxona/Model/system/turi.dart';

/// habarlar turlari
class AlertType extends Tur {
  static var info = AlertType(1, "Ma'lumot");
  static var success = AlertType(2, "Muvaffaqiyat");
  static var warning = AlertType(3, "Ogohlantirish");
  static var error = AlertType(4, "Xatoli");

  AlertType(super.tr, super.nomi);
}

/// Habar
class Alert{

  int tr = 0;
  AlertType type = AlertType.info;
  String title = '';
  String desc = '';

  Alert(this.type, this.title, {this.desc = '', this.tr = 0});

}

class ExceptionIW implements Exception {
  Alert alert;
  ExceptionIW(this.alert);
}
