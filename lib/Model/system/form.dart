
enum FormAlertType{
  none, success, info, warning, danger
}

class FormAlert{
  FormAlertType type = FormAlertType.none;
  String text = '';

  FormAlert.just();
  FormAlert(this.type, this.text);
}
