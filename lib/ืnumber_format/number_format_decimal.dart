class NumberFormatDecimal {
  numberFormatDecimal(number) {
    double numberFormat = double.parse((number).toStringAsFixed(2));
    return numberFormat;
  }
}
