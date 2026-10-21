import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../models/user_profile_model.dart';

class SampleData {
  static UserProfileModel get erwinProfile => const UserProfileModel(
    name: 'Erwin Wijaya',
    email: 'erwin_wijaya@teknokrat.ac.id',
    occupation: 'Mahasiswa Informatika / Mobile Dev',
  );

  static UserProfileModel get initialProfile => const UserProfileModel(
    name: 'Pengguna FinTrack',
    email: '',
    occupation: '',
  );

  static List<BudgetModel> get initialBudgets => [
    const BudgetModel(
      id: 'b1',
      name: 'Kuliner & Kopi',
      amount: 2000000,
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
      amount: 1500000,
      category: 'Belanja',
    ),
    const BudgetModel(
      id: 'b4',
      name: 'Tagihan Listrik & Internet',
      amount: 750000,
      category: 'Tagihan',
    ),
    const BudgetModel(
      id: 'b5',
      name: 'Hiburan & Edukasi',
      amount: 600000,
      category: 'Hiburan',
    ),
  ];

  static List<TransactionModel> getTransactionsWithLastMonth() {
    final now = DateTime.now();
    final prevMonthRef = DateTime(now.year, now.month - 1, 1);
    final prevYear = prevMonthRef.year;
    final prevMonth = prevMonthRef.month;

    return [
      // ========================================================
      // TRANSAKSI BULAN INI (CURRENT MONTH)
      // ========================================================
      TransactionModel(
        id: 'tx_now_1',
        title: 'Gaji Pokok & Tunjangan',
        amount: 8500000,
        type: TransactionType.income,
        category: 'Gaji',
        date: DateTime(now.year, now.month, 1, 9, 30),
        description: 'Transfer payroll bulanan kantor',
      ),
      TransactionModel(
        id: 'tx_now_2',
        title: 'Project Freelance UI/UX Mobile',
        amount: 3500000,
        type: TransactionType.income,
        category: 'Bonus',
        date: DateTime(now.year, now.month, 3, 14, 0),
        description: 'Termin 1 redesain aplikasi mobile klien',
      ),
      TransactionModel(
        id: 'tx_now_3',
        title: 'Belanja Bulanan Superindo',
        amount: 780000,
        type: TransactionType.expense,
        category: 'Belanja',
        date: DateTime(now.year, now.month, 5, 11, 20),
        description: 'Bahan makanan pokok & keperluan bulanan',
      ),
      TransactionModel(
        id: 'tx_now_4',
        title: 'Isi Bensin Pertamax & Tol',
        amount: 200000,
        type: TransactionType.expense,
        category: 'Transportasi',
        date: DateTime(now.year, now.month, 7, 8, 45),
        description: 'Pertamax full tank motor & mobil',
      ),
      TransactionModel(
        id: 'tx_now_5',
        title: 'Makan Bareng & Kopi Kenangan',
        amount: 135000,
        type: TransactionType.expense,
        category: 'Makanan & Minuman',
        date: DateTime(now.year, now.month, 9, 13, 15),
        description: 'Makan siang bareng tim & kopi',
      ),
      TransactionModel(
        id: 'tx_now_6',
        title: 'Token Listrik PLN & IndiHome',
        amount: 510000,
        type: TransactionType.expense,
        category: 'Tagihan',
        date: DateTime(now.year, now.month, 11, 10, 0),
        description: 'Internet wifi 50 Mbps & token listrik',
      ),
      TransactionModel(
        id: 'tx_now_7',
        title: 'Passive Income Reksadana Bibit',
        amount: 380000,
        type: TransactionType.income,
        category: 'Investasi',
        date: DateTime(now.year, now.month, 13, 9, 0),
        description: 'Dividen bulanan pasar uang',
      ),
      TransactionModel(
        id: 'tx_now_8',
        title: 'Grab Transportasi Meeting',
        amount: 110000,
        type: TransactionType.expense,
        category: 'Transportasi',
        date: DateTime(now.year, now.month, 15, 15, 30),
        description: 'Transportasi meeting klien ke kantor',
      ),
      TransactionModel(
        id: 'tx_now_9',
        title: 'Tiket Bioskop XXI & Snack',
        amount: 125000,
        type: TransactionType.expense,
        category: 'Hiburan',
        date: DateTime(now.year, now.month, 17, 19, 0),
        description: 'Nonton premier weekend bareng teman',
      ),
      TransactionModel(
        id: 'tx_now_10',
        title: 'Apotek Kimia Farma (Vitamin)',
        amount: 95000,
        type: TransactionType.expense,
        category: 'Kesehatan',
        date: DateTime(now.year, now.month, 19, 14, 10),
        description: 'Vitamin C & suplemen harian',
      ),

      // ========================================================
      // TRANSAKSI BULAN KEMARIN (LAST MONTH)
      // ========================================================
      TransactionModel(
        id: 'tx_prev_1',
        title: 'Gaji Pokok Bulan Lalu',
        amount: 8500000,
        type: TransactionType.income,
        category: 'Gaji',
        date: DateTime(prevYear, prevMonth, 1, 9, 0),
        description: 'Payroll bulanan kantor',
      ),
      TransactionModel(
        id: 'tx_prev_2',
        title: 'Insentif & Bonus Quiz Kampus',
        amount: 3200000,
        type: TransactionType.income,
        category: 'Bonus',
        date: DateTime(prevYear, prevMonth, 4, 11, 30),
        description: 'Reward kompetisi pengembangan mobile Teknokrat',
      ),
      TransactionModel(
        id: 'tx_prev_3',
        title: 'Belanja Bulanan & Logistik',
        amount: 850000,
        type: TransactionType.expense,
        category: 'Belanja',
        date: DateTime(prevYear, prevMonth, 6, 14, 30),
        description: 'Belanja supermarket kebutuhan bulanan',
      ),
      TransactionModel(
        id: 'tx_prev_4',
        title: 'Bensin & Service Motor',
        amount: 240000,
        type: TransactionType.expense,
        category: 'Transportasi',
        date: DateTime(prevYear, prevMonth, 8, 10, 15),
        description: 'Ganti oli mesin & isi bensin pertamax',
      ),
      TransactionModel(
        id: 'tx_prev_5',
        title: 'Tagihan Listrik & WiFi',
        amount: 580000,
        type: TransactionType.expense,
        category: 'Tagihan',
        date: DateTime(prevYear, prevMonth, 11, 9, 30),
        description: 'Paket data bulanan dan internet',
      ),
      TransactionModel(
        id: 'tx_prev_6',
        title: 'Makan Bersama Tim Kampus',
        amount: 165000,
        type: TransactionType.expense,
        category: 'Makanan & Minuman',
        date: DateTime(prevYear, prevMonth, 14, 13, 0),
        description: 'Makan siang & diskusi tugas kelompok',
      ),
      TransactionModel(
        id: 'tx_prev_7',
        title: 'Bagi Hasil Dividen Reksadana',
        amount: 420000,
        type: TransactionType.income,
        category: 'Investasi',
        date: DateTime(prevYear, prevMonth, 17, 10, 0),
        description: 'Bagi hasil investasi kuartalan',
      ),
      TransactionModel(
        id: 'tx_prev_8',
        title: 'Nonton Bioskop & Popcorn',
        amount: 140000,
        type: TransactionType.expense,
        category: 'Hiburan',
        date: DateTime(prevYear, prevMonth, 19, 19, 30),
        description: 'Tiket cinema XXI & popcorn',
      ),
      TransactionModel(
        id: 'tx_prev_9',
        title: 'Langganan Kursus Online Flutter',
        amount: 290000,
        type: TransactionType.expense,
        category: 'Pendidikan',
        date: DateTime(prevYear, prevMonth, 22, 16, 0),
        description: 'Upgrade skill mobile development',
      ),
      TransactionModel(
        id: 'tx_prev_10',
        title: 'Apotek & Suplemen Kesehatan',
        amount: 120000,
        type: TransactionType.expense,
        category: 'Kesehatan',
        date: DateTime(prevYear, prevMonth, 25, 15, 20),
        description: 'Vitamin C & multivitamin',
      ),
      TransactionModel(
        id: 'tx_prev_11',
        title: 'Kopi & Diskusi Coding Weekend',
        amount: 95000,
        type: TransactionType.expense,
        category: 'Makanan & Minuman',
        date: DateTime(prevYear, prevMonth, 27, 20, 15),
        description: 'Nongkrong kafe sambil ngerjain project',
      ),
    ];
  }

  static List<TransactionModel> get initialTransactions => getTransactionsWithLastMonth();
}
