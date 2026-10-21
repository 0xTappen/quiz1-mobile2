import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../models/user_profile_model.dart';

class SampleData {
  static UserProfileModel get initialProfile => const UserProfileModel(
    name: 'Pengguna FinTrack',
    email: '',
    occupation: '',
  );

  static List<BudgetModel> get initialBudgets => [
    const BudgetModel(
      id: 'b1',
      name: 'Kuliner & Kopi',
      amount: 2500000,
      category: 'Makanan & Minuman',
    ),
    const BudgetModel(
      id: 'b2',
      name: 'Transportasi Harian',
      amount: 800000,
      category: 'Transportasi',
    ),
    const BudgetModel(
      id: 'b3',
      name: 'Kebutuhan Bulanan',
      amount: 1800000,
      category: 'Belanja',
    ),
    const BudgetModel(
      id: 'b4',
      name: 'Tagihan Listrik & Internet',
      amount: 1200000,
      category: 'Tagihan',
    ),
    const BudgetModel(
      id: 'b5',
      name: 'Hiburan & Liburan',
      amount: 600000,
      category: 'Hiburan',
    ),
  ];

  static List<TransactionModel> get initialTransactions {
    final now = DateTime.now();

    return [
      TransactionModel(
        id: 't1',
        title: 'Gaji Bulanan',
        amount: 12500000,
        type: TransactionType.income,
        category: 'Gaji',
        date: DateTime(now.year, now.month, 1, 9, 30),
        description: 'Transfer payroll bulanan kantor',
      ),
      TransactionModel(
        id: 't2',
        title: 'Freelance UI/UX Mobile',
        amount: 3800000,
        type: TransactionType.income,
        category: 'Bonus',
        date: DateTime(now.year, now.month, 3, 15, 0),
        description: 'Pembayaran termin 1 redesain aplikasi fintech',
      ),
      TransactionModel(
        id: 't3',
        title: 'Belanja Bulanan Superindo',
        amount: 850000,
        type: TransactionType.expense,
        category: 'Belanja',
        date: DateTime(now.year, now.month, 4, 11, 20),
        description: 'Bahan pokok, buah segar, dan perlengkapan mandi',
      ),
      TransactionModel(
        id: 't4',
        title: 'Bebek Kaleyo Tebet',
        amount: 145000,
        type: TransactionType.expense,
        category: 'Makanan & Minuman',
        date: DateTime(now.year, now.month, 6, 13, 10),
        description: 'Makan siang bareng tim kantor',
      ),
      TransactionModel(
        id: 't5',
        title: 'Isi Bensin Pertamax',
        amount: 250000,
        type: TransactionType.expense,
        category: 'Transportasi',
        date: DateTime(now.year, now.month, 7, 8, 45),
        description: 'Isi full tank motor dan mobil',
      ),
      TransactionModel(
        id: 't6',
        title: 'Tagihan WiFi IndiHome & Listrik PLN',
        amount: 780000,
        type: TransactionType.expense,
        category: 'Tagihan',
        date: DateTime(now.year, now.month, 8, 10, 0),
        description: 'Internet 50 Mbps dan token listrik 300rb',
      ),
      TransactionModel(
        id: 't7',
        title: 'Kopi Kenangan Mantan',
        amount: 48000,
        type: TransactionType.expense,
        category: 'Makanan & Minuman',
        date: DateTime(now.year, now.month, 10, 16, 20),
        description: '2 Cup Kopi Kenangan Mantan Large',
      ),
      TransactionModel(
        id: 't8',
        title: 'Nonton Bioskop XXI & Popcorn',
        amount: 165000,
        type: TransactionType.expense,
        category: 'Hiburan',
        date: DateTime(now.year, now.month, 11, 19, 0),
        description: 'Tiket nonton premiere bareng teman',
      ),
      TransactionModel(
        id: 't9',
        title: 'Apotek Kimia Farma (Vitamin & Masker)',
        amount: 175000,
        type: TransactionType.expense,
        category: 'Kesehatan',
        date: DateTime(now.year, now.month, 12, 14, 15),
        description: 'Vitamin C, D3, dan multivitamin harian',
      ),
      TransactionModel(
        id: 't10',
        title: 'Dividen Reksadana Pasar Uang',
        amount: 450000,
        type: TransactionType.income,
        category: 'Investasi',
        date: DateTime(now.year, now.month, 13, 10, 0),
        description: 'Bagi hasil investasi bulanan di Bibit',
      ),
      TransactionModel(
        id: 't11',
        title: 'GrabCar ke Sudirman',
        amount: 85000,
        type: TransactionType.expense,
        category: 'Transportasi',
        date: DateTime(now.year, now.month, 14, 8, 15),
        description: 'Transportasi meeting klien ke SCBD',
      ),
    ];
  }
}
