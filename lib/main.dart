import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/finance_repository.dart';
import 'providers/finance_provider.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final repository = await FinanceRepository.create();
  final provider = FinanceProvider(repository);

  runApp(FinTrackApp(provider: provider));
}

class FinTrackApp extends StatelessWidget {
  final FinanceProvider provider;

  const FinTrackApp({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return FinanceScope(
      notifier: provider,
      child: MaterialApp(
        title: 'FinTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainShell(),
      ),
    );
  }
}
