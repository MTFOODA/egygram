import 'package:flutter/material.dart';

/// Shown at startup when Supabase could not be initialized (e.g. the app was
/// run without the required `--dart-define` values).
///
/// It renders the exact, actionable diagnostic produced by
/// `SupabaseConfig` / `SupabaseBootstrap` instead of crashing on a blank
/// screen or letting the failure surface later as a misleading auth error.
class StartupErrorScreen extends StatelessWidget {
  final String message;

  const StartupErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1B1B1F),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Color(0xFFFF6B6B), size: 40),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'EgyGram could not start',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Supabase is not configured correctly.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A31),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SelectableText(
                      message,
                      style: const TextStyle(
                        color: Color(0xFFE6E6E6),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pass the values at run/build time, e.g.:',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A31),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const SelectableText(
                      'flutter run \\\n'
                      '  --dart-define=SUPABASE_URL=https://<project>.supabase.co \\\n'
                      '  --dart-define=SUPABASE_ANON_KEY=<your-anon-key>',
                      style: TextStyle(
                        color: Color(0xFF9BE8A0),
                        fontSize: 12,
                        fontFamily: 'monospace',
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
