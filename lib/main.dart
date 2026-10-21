import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/finance_repository.dart';
import 'providers/finance_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  await initializeDateFormatting('id_ID', null);

  final repository = await FinanceRepository.create();
  final provider = FinanceProvider(repository);

  runApp(CashlyApp(provider: provider));
}

class CashlyApp extends StatefulWidget {
  final FinanceProvider provider;

  const CashlyApp({super.key, required this.provider});

  @override
  State<CashlyApp> createState() => _CashlyAppState();
}

class _CashlyAppState extends State<CashlyApp> {
  bool _guestMode = false;

  void _enterGuestMode() {
    setState(() => _guestMode = true);
  }

  @override
  Widget build(BuildContext context) {
    return FinanceScope(
      notifier: widget.provider,
      child: MaterialApp(
        title: 'Cashly',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Jika user sudah login di Firebase atau memilih mode tamu
            if (snapshot.hasData && snapshot.data != null) {
              return const MainShell();
            }

            if (_guestMode) {
              return const MainShell();
            }

            return LoginScreen(
              onLoginSuccess: () {
                setState(() => _guestMode = false);
              },
              onContinueAsGuest: _enterGuestMode,
            );
          },
        ),
      ),
    );
  }
}
