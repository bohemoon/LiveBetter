import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'bootstrap_io.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final overrides = await platformOverrides();
  runApp(
    ProviderScope(
      overrides: overrides,
      child: const LiveBetterApp(),
    ),
  );
}
