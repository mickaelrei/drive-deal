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

/// Returns a string in the DD/MM/YYYY format
String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}'
      '/'
      '${date.month.toString().padLeft(2, '0')}'
      '/'
      '${date.year}';
}
