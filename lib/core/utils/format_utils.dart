import 'package:intl/intl.dart';

String formatMoney(double amount, {String currency = '₹'}) {
  if (amount >= 100000) {
    return '$currency${(amount / 100000).toStringAsFixed(2)}L';
  } else if (amount >= 1000) {
    return '$currency${(amount / 1000).toStringAsFixed(1)}K';
  }
  return '$currency${amount.toStringAsFixed(2)}';
}

String formatMoneyExact(double amount, {String currency = '₹'}) {
  return '$currency${NumberFormat('#,##,##0.00').format(amount)}';
}

// Backward-compatible aliases
String formatCurrency(double amount) => formatMoney(amount);
String formatCurrencyExact(double amount) => formatMoneyExact(amount);

String formatDate(DateTime dt) => DateFormat('d MMM yyyy').format(dt);

String formatDateTime(DateTime dt) => DateFormat('d MMM yyyy, h:mm a').format(dt);

String formatTime(DateTime dt) => DateFormat('h:mm a').format(dt);

String formatDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  if (m >= 60) {
    final h = m ~/ 60;
    final rem = m % 60;
    return '${h}h ${rem}m';
  }
  return '${m}m ${s}s';
}

String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return formatDate(dt);
}

String formatPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.length == 12 && digits.startsWith('91')) {
    final num = digits.substring(2);
    return '+91 ${num.substring(0, 5)} ${num.substring(5)}';
  }
  return phone;
}
