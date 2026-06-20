// Syncs GOOGLE_MAPS_API_KEY from dart-defines.json into iOS xcconfig.
// Run before iOS builds: dart run tools/sync_maps_keys.dart

import 'dart:convert';
import 'dart:io';

void main() {
  final definesFile = File('dart-defines.json');
  if (!definesFile.existsSync()) {
    stderr.writeln(
        'Missing dart-defines.json. Copy dart-defines.json.example first.');
    exit(1);
  }

  final json =
      jsonDecode(definesFile.readAsStringSync()) as Map<String, dynamic>;
  final apiKey = json['GOOGLE_MAPS_API_KEY'] as String? ?? '';

  if (apiKey.isEmpty) {
    stderr.writeln('GOOGLE_MAPS_API_KEY is empty in dart-defines.json.');
    exit(1);
  }

  final xcconfig = File('ios/Flutter/MapsKeys.xcconfig');
  xcconfig.writeAsStringSync('GOOGLE_MAPS_API_KEY=$apiKey\n');
  stdout.writeln('Wrote ios/Flutter/MapsKeys.xcconfig');
}
