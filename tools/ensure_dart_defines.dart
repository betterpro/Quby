import 'dart:io';

/// Ensures dart-defines.json exists before debug/run (copies from .example).
void main() {
  final target = File('dart-defines.json');
  if (target.existsSync()) return;

  final example = File('dart-defines.json.example');
  if (!example.existsSync()) {
    stderr.writeln(
      'Missing dart-defines.json.example. Cannot create dart-defines.json.',
    );
    exit(1);
  }

  example.copySync('dart-defines.json');
  stdout.writeln(
    'Created dart-defines.json from dart-defines.json.example.\n'
    'Edit it with your Supabase, Google, and Stripe keys, then debug again.',
  );
}
