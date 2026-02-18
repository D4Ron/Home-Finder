import 'package:intl/intl.dart';

class Formatters {
  static String price(double amount) {
    final fmt = NumberFormat('#,###', 'fr_FR');
    return '${fmt.format(amount)} Fcfa';
  }

  static String date(DateTime dt) =>
      DateFormat('d MMM yyyy', 'fr_FR').format(dt);

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'À l\'instant';
    if (diff.inHours   < 1)  return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays    < 1)  return 'Il y a ${diff.inHours}h';
    if (diff.inDays    < 7)  return 'Il y a ${diff.inDays}j';
    return date(dt);
  }

  static String compact(double amount) {
    if (amount >= 1e9) return '${(amount / 1e9).toStringAsFixed(1)}Md';
    if (amount >= 1e6) return '${(amount / 1e6).toStringAsFixed(1)}M';
    if (amount >= 1e3) return '${(amount / 1e3).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }
}