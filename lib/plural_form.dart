class PluralForm {
  final String one;

  final String other;

  final String? zero;

  final int value;

  PluralForm({
    required this.one,
    required this.other,
    required this.value,
    this.zero,
  });
}
