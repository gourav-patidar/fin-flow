/// Format [value] as an Indian-grouped currency string (e.g. ₹1,24,500).
///
/// Indian grouping puts a comma after the first 3 digits from the right and
/// every 2 digits beyond that — distinct from Western grouping.
///
/// * [showSymbol] prepends the ₹ glyph (default true).
/// * [decimals] controls the digits after the decimal point. 0 hides the
///   fractional part entirely.
String formatINR(
  num value, {
  bool showSymbol = true,
  int decimals = 0,
}) {
  final bool negative = value < 0;
  final num absVal = value.abs();
  final int intPart = absVal.truncate();
  final String intStr = intPart.toString();

  final String grouped = _groupIndian(intStr);

  String result = grouped;
  if (decimals > 0) {
    final num frac = absVal - intPart;
    final String fracStr =
        frac.toStringAsFixed(decimals).substring(2); // skip "0."
    result = '$result.$fracStr';
  }

  final String symbol = showSymbol ? '₹' : '';
  final String sign = negative ? '-' : '';
  return '$sign$symbol$result';
}

String _groupIndian(String digits) {
  if (digits.length <= 3) return digits;
  final String lastThree = digits.substring(digits.length - 3);
  final String rest = digits.substring(0, digits.length - 3);
  final String groupedRest = rest.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{2})+$)'),
    (Match m) => '${m[1]},',
  );
  return '$groupedRest,$lastThree';
}
