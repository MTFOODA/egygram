/// Parses date/datetime values coming from Supabase (PostgREST) into [DateTime].
///
/// PostgREST returns `timestamptz` columns as ISO-8601 strings, but we also
/// defensively handle [DateTime] and numeric epoch values so the same parser
/// works for local maps and future schema tweaks.
library;

DateTime parseDate(dynamic value, {DateTime? fallback}) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed.toLocal();
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  return fallback ?? DateTime.now();
}
