import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _fullDate = DateFormat('dd MMMM yyyy', 'id_ID');
  static final DateFormat _shortDate = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _dayMonth = DateFormat('dd MMM', 'id_ID');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy', 'id_ID');

  static String full(DateTime date) {
    try {
      return _fullDate.format(date);
    } catch (_) {
      return DateFormat('dd MMMM yyyy').format(date);
    }
  }

  static String short(DateTime date) {
    try {
      return _shortDate.format(date);
    } catch (_) {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  static String dayMonth(DateTime date) {
    try {
      return _dayMonth.format(date);
    } catch (_) {
      return DateFormat('dd MMM').format(date);
    }
  }

  static String monthYear(DateTime date) {
    try {
      return _monthYear.format(date);
    } catch (_) {
      return DateFormat('MMMM yyyy').format(date);
    }
  }

  static String relative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Hari Ini';
    if (diff == 1) return 'Kemarin';
    if (diff == -1) return 'Besok';
    return short(date);
  }
}
