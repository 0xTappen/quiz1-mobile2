import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;
  final String flag;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
  });
}

class CurrencyRatesResult {
  final String baseCurrency;
  final Map<String, double> rates;
  final DateTime lastUpdated;
  final String source;

  CurrencyRatesResult({
    required this.baseCurrency,
    required this.rates,
    required this.lastUpdated,
    required this.source,
  });
}

class CurrencyService {
  // FreeCurrencyAPI key (optional - jika tidak ada akan otomatis fallback ke open.er-api)
  static const String _freeCurrencyApiKey = '';

  // Cache in-memory
  static CurrencyRatesResult? _cachedResult;
  static DateTime? _cacheTime;

  static const List<CurrencyInfo> supportedCurrencies = [
    CurrencyInfo(code: 'IDR', name: 'Rupiah Indonesia', symbol: 'Rp', flag: '🇮🇩'),
    CurrencyInfo(code: 'USD', name: 'Dolar Amerika Serikat', symbol: '\$', flag: '🇺🇸'),
    CurrencyInfo(code: 'EUR', name: 'Euro Uni Eropa', symbol: '€', flag: '🇪🇺'),
    CurrencyInfo(code: 'SGD', name: 'Dolar Singapura', symbol: 'S\$', flag: '🇸🇬'),
    CurrencyInfo(code: 'MYR', name: 'Ringgit Malaysia', symbol: 'RM', flag: '🇲🇾'),
    CurrencyInfo(code: 'JPY', name: 'Yen Jepang', symbol: '¥', flag: '🇯🇵'),
    CurrencyInfo(code: 'GBP', name: 'Pound Sterling Inggris', symbol: '£', flag: '🇬🇧'),
    CurrencyInfo(code: 'AUD', name: 'Dolar Australia', symbol: 'A\$', flag: '🇦🇺'),
    CurrencyInfo(code: 'CNY', name: 'Yuan Tiongkok', symbol: '¥', flag: '🇨🇳'),
    CurrencyInfo(code: 'SAR', name: 'Riyal Arab Saudi', symbol: '﷼', flag: '🇸🇦'),
    CurrencyInfo(code: 'KRW', name: 'Won Korea Selatan', symbol: '₩', flag: '🇰🇷'),
    CurrencyInfo(code: 'THB', name: 'Baht Thailand', symbol: '฿', flag: '🇹🇭'),
    CurrencyInfo(code: 'PHP', name: 'Peso Filipina', symbol: '₱', flag: '🇵🇭'),
    CurrencyInfo(code: 'CAD', name: 'Dolar Kanada', symbol: 'C\$', flag: '🇨🇦'),
    CurrencyInfo(code: 'CHF', name: 'Franc Swiss', symbol: 'CHF', flag: '🇨🇭'),
    CurrencyInfo(code: 'HKD', name: 'Dolar Hong Kong', symbol: 'HK\$', flag: '🇭🇰'),
    CurrencyInfo(code: 'INR', name: 'Rupee India', symbol: '₹', flag: '🇮🇳'),
    CurrencyInfo(code: 'NZD', name: 'Dolar Selandia Baru', symbol: 'NZ\$', flag: '🇳🇿'),
    CurrencyInfo(code: 'AED', name: 'Dirham Uni Emirat Arab', symbol: 'د.إ', flag: '🇦🇪'),
  ];

  static CurrencyInfo getCurrencyInfo(String code) {
    return supportedCurrencies.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => CurrencyInfo(
        code: code.toUpperCase(),
        name: code.toUpperCase(),
        symbol: code.toUpperCase(),
        flag: '🌐',
      ),
    );
  }

  /// Mengambil data kurs mata uang terbaru.
  /// Mencoba FreeCurrencyAPI terlebih dahulu, jika gagal atau tanpa API key,
  /// secara otomatis beralih ke Open Exchange Rates API (open.er-api.com).
  static Future<CurrencyRatesResult> getExchangeRates({
    String baseCurrency = 'IDR',
    bool forceRefresh = false,
  }) async {
    // Return cache jika masih segar (< 15 menit) dan bukan force refresh
    if (!forceRefresh &&
        _cachedResult != null &&
        _cachedResult!.baseCurrency == baseCurrency &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!).inMinutes < 15) {
      return _cachedResult!;
    }

    // 1. Coba FreeCurrencyAPI jika API key tersedia
    if (_freeCurrencyApiKey.isNotEmpty) {
      try {
        final url = Uri.parse(
          'https://api.freecurrencyapi.com/v1/latest?apikey=$_freeCurrencyApiKey&base_currency=$baseCurrency',
        );
        final response = await http.get(url).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final rawRates = data['data'] as Map<String, dynamic>?;
          if (rawRates != null) {
            final rates = <String, double>{};
            rawRates.forEach((key, val) {
              rates[key] = (val as num).toDouble();
            });
            rates[baseCurrency] = 1.0;
            final result = CurrencyRatesResult(
              baseCurrency: baseCurrency,
              rates: rates,
              lastUpdated: DateTime.now(),
              source: 'FreeCurrencyAPI',
            );
            _cachedResult = result;
            _cacheTime = DateTime.now();
            return result;
          }
        }
      } catch (_) {
        // Fallback to open exchange rates
      }
    }

    // 2. Open Exchange Rates API (open.er-api.com) - 100% reliable, no key needed
    try {
      final url = Uri.parse('https://open.er-api.com/v6/latest/$baseCurrency');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawRates = data['rates'] as Map<String, dynamic>?;
        if (rawRates != null) {
          final rates = <String, double>{};
          rawRates.forEach((key, val) {
            rates[key] = (val as num).toDouble();
          });
          rates[baseCurrency] = 1.0;

          DateTime updatedAt = DateTime.now();
          if (data['time_last_update_utc'] != null) {
            try {
              updatedAt = DateTime.parse(data['time_last_update_utc']);
            } catch (_) {}
          }

          final result = CurrencyRatesResult(
            baseCurrency: baseCurrency,
            rates: rates,
            lastUpdated: updatedAt,
            source: 'Open Exchange Rates (FreeCurrency Engine)',
          );
          _cachedResult = result;
          _cacheTime = DateTime.now();
          return result;
        }
      }
    } catch (_) {
      // Jika jaringan gagal, gunakan data cache atau data default
    }

    if (_cachedResult != null) {
      return _cachedResult!;
    }

    // Fallback offline mock rates jika sama sekali tidak ada internet
    return _getFallbackResult(baseCurrency);
  }

  /// Konversi nominal dari satu mata uang ke mata uang lain
  static double convert({
    required double amount,
    required String from,
    required String to,
    required Map<String, double> rates,
    required String baseCurrency,
  }) {
    if (from.toUpperCase() == to.toUpperCase()) return amount;

    // Jika base = from, toRate = rates[to]
    if (baseCurrency.toUpperCase() == from.toUpperCase()) {
      final toRate = rates[to.toUpperCase()] ?? 1.0;
      return amount * toRate;
    }

    // Jika base = to, fromRate = rates[from]
    if (baseCurrency.toUpperCase() == to.toUpperCase()) {
      final fromRate = rates[from.toUpperCase()] ?? 1.0;
      return fromRate > 0 ? amount / fromRate : amount;
    }

    // Cross conversion via base
    final fromRate = rates[from.toUpperCase()] ?? 1.0;
    final toRate = rates[to.toUpperCase()] ?? 1.0;
    if (fromRate == 0) return amount;
    final amountInBase = amount / fromRate;
    return amountInBase * toRate;
  }

  static CurrencyRatesResult _getFallbackResult(String baseCurrency) {
    // Estimasi rate terhadap IDR
    final idrRates = <String, double>{
      'IDR': 1.0,
      'USD': 0.000063, // ~Rp 15.800
      'EUR': 0.000058, // ~Rp 17.200
      'SGD': 0.000084, // ~Rp 11.900
      'MYR': 0.00028,  // ~Rp 3.550
      'JPY': 0.0097,   // ~Rp 103
      'GBP': 0.000050, // ~Rp 20.000
      'AUD': 0.000098, // ~Rp 10.200
      'CNY': 0.00045,  // ~Rp 2.200
      'SAR': 0.00024,  // ~Rp 4.200
      'KRW': 0.087,    // ~Rp 11.5
      'THB': 0.0022,   // ~Rp 450
      'PHP': 0.0037,   // ~Rp 270
      'CAD': 0.000088, // ~Rp 11.400
      'CHF': 0.000056, // ~Rp 17.800
      'HKD': 0.00049,  // ~Rp 2.030
      'INR': 0.0053,   // ~Rp 188
    };

    return CurrencyRatesResult(
      baseCurrency: baseCurrency,
      rates: idrRates,
      lastUpdated: DateTime.now(),
      source: 'Data Tersimpan (Offline)',
    );
  }
}
