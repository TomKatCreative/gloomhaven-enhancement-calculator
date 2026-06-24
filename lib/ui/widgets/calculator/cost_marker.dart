/// Composes the marker suffix shown next to a cost (e.g., `§*`, `†`, `‡*`).
///
/// Each calculator section shows up to two stacked markers next to its cost:
/// a feature-specific marker (`§` Party Boon, `†` temporary, `‡` Hail's
/// discount) and the universal `*` Building 44 enhancer marker. This helper
/// concatenates only the active markers in insertion order, returning `null`
/// when none apply (so the caller can hide the suffix entirely).
///
/// ## Example
/// ```dart
/// // Card-level cost with Party Boon and Enhancer L3:
/// final marker = costMarker({'§': partyBoon, '*': enhancerLvl3Applies});
/// // → '§*' if both true, '§' if only first, null if neither.
/// ```
String? costMarker(Map<String, bool> markers) {
  final composed = markers.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .join();
  return composed.isEmpty ? null : composed;
}
