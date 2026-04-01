extension NatrixStringCutExtension on String {
  String cut(int start, [int? end]) =>
      substring(start, (end ?? length).clamp(0, length));
}

extension IterableFirstWhereOrNullExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

String simpleStringReduction(String raw) {
  String o = "";
  for (int i = 0; i < raw.length; i++) {
    if (raw[i] != "\"") {
      o += raw[i];
      continue;
    }
    if (i < 1 || raw[i - 1] != "\\") {
      continue;
    }
    o = o.substring(0, o.length - 1);
    o += raw[i];
  }
  return o;
}
