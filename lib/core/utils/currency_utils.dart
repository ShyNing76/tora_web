import 'package:intl/intl.dart';

class CurrencyUtils {
  /// Format số thành tiền Việt Nam (ví dụ: 1000000 -> "1.000.000 ₫")
  static String formatVND(dynamic value, {bool showSymbol = true}) {
    if (value == null) return '0${showSymbol ? ' ₫' : ''}';

    // Chuyển chuỗi sang số nếu cần
    num number;
    if (value is String) {
      number = num.tryParse(value.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0;
    } else if (value is num) {
      number = value;
    } else {
      return '0${showSymbol ? ' ₫' : ''}';
    }

    // Định dạng theo locale Việt Nam
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: showSymbol ? '₫' : '', decimalDigits: 0);
    return formatter.format(number).trim();
  }

  /// Parse chuỗi tiền Việt Nam về dạng số (ví dụ: "1.000.000 ₫" -> 1000000)
  static num parseVND(String value) {
    if (value.isEmpty) return 0;
    return num.tryParse(value.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0;
  }
}
