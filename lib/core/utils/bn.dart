/// Bangla digit / date helpers.
const _en = '0123456789';
const _bn = '০১২৩৪৫৬৭৮৯';

const List<String> bnMonths = [
  'জানুয়ারি',
  'ফেব্রুয়ারি',
  'মার্চ',
  'এপ্রিল',
  'মে',
  'জুন',
  'জুলাই',
  'আগস্ট',
  'সেপ্টেম্বর',
  'অক্টোবর',
  'নভেম্বর',
  'ডিসেম্বর',
];

/// bn(12) -> ১২
String bn(Object value) {
  var s = value.toString();
  for (var i = 0; i < _en.length; i++) {
    s = s.replaceAll(_en[i], _bn[i]);
  }
  return s;
}

/// bnMoney(12000) -> ১২০০০.০০  (or ১২০০০ if decimal is false)
String bnMoney(double v, {bool decimal = true}) =>
    bn(decimal ? v.toStringAsFixed(2) : v.round().toString());

/// bnCompact(0) -> ০, bnCompact(150.5) -> ১৫০.৫০
String bnCompact(double v, {bool decimal = true}) {
  if (v == 0) return '০';
  return bnMoney(v, decimal: decimal);
}

/// ১৬ নভেম্বর
String bnDate(DateTime d) => '${bn(d.day)} ${bnMonths[d.month - 1]}';

/// ১৯ নভেম্বর, ২০২৬
String bnFullDate(DateTime d) =>
    '${bn(d.day)} ${bnMonths[d.month - 1]}, ${bn(d.year)}';

/// ১৯ নভেম্বর, ২০২৬ - ০২:১৭ PM
String bnDateTime(DateTime d) {
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final ampm = d.hour >= 12 ? 'PM' : 'AM';
  final hh = bn(h12.toString().padLeft(2, '0'));
  final mm = bn(d.minute.toString().padLeft(2, '0'));
  return '${bnFullDate(d)} - $hh:$mm $ampm';
}

/// নভেম্বর
String bnMonth(DateTime d) => bnMonths[d.month - 1];

/// Relative time for party rows (এখন, ৩৩ সেকেন্ড, ২৩ মিনিট, ২ ঘণ্টা, ৩ দিন)
String bnRelativeTime(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inSeconds < 15) return 'এখন';
  if (diff.inSeconds < 60) return '${bn(diff.inSeconds)} সেকেন্ড';
  if (diff.inMinutes < 60) return '${bn(diff.inMinutes)} মিনিট';
  if (diff.inHours < 24) return '${bn(diff.inHours)} ঘণ্টা';
  if (diff.inDays < 30) return '${bn(diff.inDays)} দিন';
  return bnDate(d);
}
