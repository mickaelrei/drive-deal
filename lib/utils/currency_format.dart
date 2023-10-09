import 'package:intl/intl.dart';

/// Format price in brazil's currency
String formatPrice(double price) {
  final priceFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  return priceFormat.format(price);
}
