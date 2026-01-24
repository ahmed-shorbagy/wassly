import 'package:string_similarity/string_similarity.dart';

class SearchHelper {
  /// Simple smart search that returns true if [query] matches [text]
  /// or is "similar enough" to it.
  static bool isMatch(String query, String text, {double threshold = 0.3}) {
    if (query.isEmpty) return true;

    final queryLower = query.toLowerCase().trim();
    final textLower = text.toLowerCase().trim();

    // 1. Standard contains check (Fastest and most common)
    if (textLower.contains(queryLower)) return true;

    // 2. Fuzzy similarity check
    // Dice's Coefficient: returns 1.0 for identical strings, 0.0 for those with no shared bigrams.
    final similarity = StringSimilarity.compareTwoStrings(
      textLower,
      queryLower,
    );
    if (similarity >= threshold) return true;

    // 3. Handle cases where user might have flipped words (e.g., "Juice Fresh" instead of "Fresh Juice")
    final queryParts = queryLower
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty);
    if (queryParts.length > 1) {
      bool allPartsMatch = true;
      for (final part in queryParts) {
        if (!textLower.contains(part) &&
            StringSimilarity.compareTwoStrings(textLower, part) < threshold) {
          allPartsMatch = false;
          break;
        }
      }
      if (allPartsMatch) return true;
    }

    return false;
  }

  /// Filters a list of items providing smart fuzzy search.
  /// [getSearchStrings] should return a list of fields to search in (e.g., name, description).
  static List<T> filterList<T>({
    required List<T> items,
    required String query,
    required List<String> Function(T) getSearchStrings,
    double threshold = 0.25,
  }) {
    if (query.isEmpty) return items;

    return items.where((item) {
      final searchFields = getSearchStrings(item);
      for (final field in searchFields) {
        if (isMatch(query, field, threshold: threshold)) return true;
      }
      return false;
    }).toList();
  }
}
