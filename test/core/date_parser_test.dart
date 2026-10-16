import 'package:flutter_application_3/core/utils/date_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseDate', () {
    test('returns a DateTime untouched', () {
      final now = DateTime(2026, 1, 2, 3, 4, 5);
      expect(parseDate(now), now);
    });

    test('parses PostgREST ISO-8601 strings to local time', () {
      final parsed = parseDate('2026-01-02T03:04:05.000Z');
      expect(parsed, isA<DateTime>());
      expect(parsed.toUtc(), DateTime.utc(2026, 1, 2, 3, 4, 5));
    });

    test('parses epoch milliseconds', () {
      final epoch = DateTime(2026, 6, 15).millisecondsSinceEpoch;
      expect(parseDate(epoch), DateTime.fromMillisecondsSinceEpoch(epoch));
    });

    test('falls back for invalid strings', () {
      final fallback = DateTime(2000, 1, 1);
      expect(parseDate('not-a-date', fallback: fallback), fallback);
      expect(parseDate(null, fallback: fallback), fallback);
      expect(parseDate('', fallback: fallback), fallback);
    });

    test('defaults to now when no fallback is given', () {
      final before = DateTime.now();
      final parsed = parseDate(null);
      expect(!parsed.isBefore(before.subtract(const Duration(seconds: 5))),
          isTrue);
    });
  });
}
