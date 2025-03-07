import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';
import 'package:logging/logging.dart';

final log = Logger('SupaLocalizationManager');

Future<void> main(List<String> arguments) async {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    /// Print log messages to the console.
  });

  final parser = ArgParser();

  // Register commands.
  parser.addCommand('merge');
  final extractCommand = parser.addCommand('extract');
  extractCommand.addOption('locale',
      abbr: 'l', defaultsTo: 'en', help: 'Locale to check');
  extractCommand.addOption('source',
      abbr: 's',
      defaultsTo: 'lib',
      help: 'Source directory to scan for Dart files');

  if (arguments.isEmpty) {
    log.info('Usage: my_localization_cli <command> [options]');
    log.info('Commands: merge, extract');
    exit(1);
  }

  final argResults = parser.parse(arguments);
  final command = argResults.command;
  if (command == null) {
    log.warning('No command provided.');
    exit(1);
  }

  switch (command.name) {
    case 'merge':
      await mergeTranslations();
      break;
    case 'extract':
      final locale = command['locale'];
      final sourceDir = command['source'];
      await extractMissingKeys(locale, sourceDir);
      break;
    default:
      log.warning('Unknown command: ${command.name}');
      exit(1);
  }
}

/// Merges JSON files found in each locale subdirectory (e.g., assets/i18n/en/)
/// into a single file (e.g., assets/i18n/en.json).
Future<void> mergeTranslations() async {
  final assetsDir = Directory('assets/i18n');
  if (!assetsDir.existsSync()) {
    log.warning('Directory assets/i18n not found.');
    exit(1);
  }
  final List<Directory> localeDirs =
      assetsDir.listSync().whereType<Directory>().toList();

  for (var localeDir in localeDirs) {
    final locale = localeDir.path.split(Platform.pathSeparator).last;
    final mergedMap = <String, dynamic>{};

    // Process each JSON file in the locale subdirectory.
    final jsonFiles = localeDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'));

    for (var file in jsonFiles) {
      final filename = file.uri.pathSegments.last;
      final namespace = filename.replaceAll('.json', '');
      try {
        final content = file.readAsStringSync();
        final Map<String, dynamic> jsonMap = json.decode(content);
        jsonMap.forEach((key, value) {
          // In the merged file, keys are prefixed by the namespace.
          final fullKey = '$namespace.$key';
          mergedMap[fullKey] = value;
        });
      } catch (e) {
        log.severe('Error reading ${file.path}: $e');
      }
    }
    final mergedFile = File('assets/i18n/$locale.json');
    mergedFile
        .writeAsStringSync(JsonEncoder.withIndent('  ').convert(mergedMap));
    log.info(
        'Merged translations for locale "$locale" into ${mergedFile.path}');
  }
}

/// Scans Dart source files for `translate('...')` usages and updates
/// individual namespace JSON files under assets/i18n/{locale}/.
/// If a namespace file doesn't exist, it will be created. Any missing key is
/// added with an empty string value.
Future<void> extractMissingKeys(String locale, String sourceDir) async {
  // Recursively search for Dart files.
  final dir = Directory(sourceDir);
  if (!dir.existsSync()) {
    log.severe('Source directory "$sourceDir" not found.');
    exit(1);
  }

  final Set<String> keysFound = {};
  // Regex pattern to capture translate('key') usages.
  final regex = RegExp(r"translate\s*\(\s*'([A-Za-z0-9$\{\}\.]+)'\)");

  await for (var entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = await entity.readAsString();
      for (final match in regex.allMatches(content)) {
        final key = match.group(1);
        if (key != null) {
          keysFound.add(key);
        }
      }
    }
  }

  // Group keys by namespace (the part before the first dot).
  final Map<String, Set<String>> keysByNamespace = {};
  for (final fullKey in keysFound) {
    final parts = fullKey.split('.');
    if (parts.length < 2) {
      log.info('Skipping key without namespace: $fullKey');
      continue;
    }
    final namespace = parts.first;
    // Store the remainder of the key (everything after the namespace).
    final keyPart = parts.sublist(1).join('.');
    keysByNamespace.putIfAbsent(namespace, () => <String>{});
    keysByNamespace[namespace]!.add(keyPart);
  }

  // Ensure the locale directory exists: assets/i18n/<locale>/
  final localeDir = Directory('assets/i18n/$locale');
  if (!localeDir.existsSync()) {
    log.severe(
        'Locale directory "assets/i18n/$locale" does not exist. Creating...');
    localeDir.createSync(recursive: true);
  }

  // Process each namespace group.
  for (final entry in keysByNamespace.entries) {
    final namespace = entry.key;
    final keys = entry.value.toList()..sort((a, b) => a.compareTo(b));

    final filePath = 'assets/i18n/$locale/$namespace.json';
    final jsonFile = File(filePath);
    Map<String, dynamic> jsonMap = {};

    if (jsonFile.existsSync()) {
      try {
        final content = jsonFile.readAsStringSync();
        if (content.trim().isNotEmpty) {
          jsonMap = json.decode(content);
        }
      } catch (e) {
        log.severe('Error reading $filePath: $e');
        continue;
      }
    } else {
      log.severe('File $filePath does not exist. Creating...');
    }

    bool updated = false;
    // Add each missing key with an empty value.
    for (final key in keys) {
      if (!jsonMap.containsKey(key)) {
        jsonMap[key] = "";
        updated = true;
        log.fine('Added missing key "$namespace.$key" with empty value.');
      }
    }

    if (updated) {
      jsonFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(jsonMap));
      log.fine('Updated file: $filePath');
    } else {
      log.info('No missing keys in $filePath.');
    }
  }
}
