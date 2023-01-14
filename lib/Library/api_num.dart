// ignore_for_file: camel_case_extensions

extension intIW on int {
  //int toPrecision(int n) => int.parse(toStringAsFixed(n));
}

extension doubleIW on double {
  double decimal(int n) => double.parse(toStringAsFixed(n));
}

extension numIW on num {
  num decimal(int n) => num.parse(toStringAsFixed(n));
}
