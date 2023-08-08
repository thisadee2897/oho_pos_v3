import 'package:intl/intl.dart';

class NumberFormats {
  numberFormats(number) {
    String numberFormat = NumberFormat.currency(name: '').format(number);
    return numberFormat;
  }
}
