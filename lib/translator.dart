import 'localization.dart';

/// Marker function used in your Dart code to mark translation strings.
String translate(String key, [Map<String, dynamic>? args]) {
  return Localization.translate(key, args);
}
