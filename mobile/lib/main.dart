import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Data locale untuk DateFormat id_ID (dipakai formatters & struk ESC/POS).
  await initializeDateFormatting('id_ID', null);
  runApp(const ProviderScope(child: PoSchedulerApp()));
}
