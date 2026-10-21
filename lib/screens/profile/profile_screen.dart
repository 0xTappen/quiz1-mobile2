import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_profile_model.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../currency/currency_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileModal(
    BuildContext context,
    UserProfileModel currentProfile,
  ) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final initialName = (currentProfile.name.isNotEmpty &&
            currentProfile.name != 'Pengguna Cashly' &&
            currentProfile.name != 'Pengguna FinTrack')
        ? currentProfile.name
        : (currentUser?.displayName?.isNotEmpty == true
            ? currentUser!.displayName!
            : (currentProfile.name != 'Pengguna Cashly' &&
                    currentProfile.name != 'Pengguna FinTrack'
                ? currentProfile.name
                : ''));
    final initialEmail = currentProfile.email.isNotEmpty
        ? currentProfile.email
        : (currentUser?.email ?? '');

    final nameController = TextEditingController(text: initialName);
    final emailController = TextEditingController(text: initialEmail);
    final occupationController = TextEditingController(
      text: currentProfile.occupation,
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Profil Pengguna',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(modalCtx),
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama lengkap',
                    controller: nameController,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Email',
                    hint: 'nama@domain.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!val.contains('@')) {
                        return 'Masukkan format email yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Pekerjaan / Profesi',
                    hint: 'Contoh: Product Designer',
                    controller: occupationController,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Simpan Perubahan',
                    icon: Icons.check_rounded,
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final updated = currentProfile.copyWith(
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        occupation: occupationController.text.trim(),
                      );
                      await FinanceScope.of(context).updateProfile(updated);
                      if (modalCtx.mounted) {
                        Navigator.pop(modalCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profil berhasil diperbarui'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmResetData(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Reset Data Aplikasi?'),
        content: const Text(
          'Semua perubahan transaksi dan anggaran akan dikembalikan ke data percontohan awal. Apakah kamu yakin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await FinanceScope.of(context).resetAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil di-reset ke sample awal'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            child: const Text('Reset Data'),
          ),
        ],
      ),
    );
  }

  void _confirmSeedErwinData(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.auto_awesome, color: AppColors.accent, size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Muat Data Presentasi?',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
            ),
          ],
        ),
        content: const Text(
          'Aplikasi akan mengisi data profil "Erwin Wijaya" (erwin_wijaya@teknokrat.ac.id) serta transaksi Bulan Ini dan Bulan Kemarin agar siap ditampilkan saat presentasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await FinanceScope.of(context).seedErwinDemoData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Data presentasi Erwin Wijaya (Bulan Ini & Bulan Lalu) berhasil dimuat!',
                    ),
                    backgroundColor: AppColors.income,
                  ),
                );
              }
            },
            child: const Text('Muat Data'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.wallet_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Cashly',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Versi 1.0.0 (Release)',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Cashly adalah aplikasi manajemen keuangan pribadi modern yang dirancang untuk memantau pemasukan, pengeluaran, dan anggaran bulanan secara cerdas dan efisien.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            SizedBox(height: 12),
            Text(
              'Dibuat dengan Flutter Material 3, Google Fonts, dan SharedPreferences.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finance = FinanceScope.of(context);
    final profile = finance.profile;
    final currentUser = FirebaseAuth.instance.currentUser;
    final displayName = (profile.name.isNotEmpty &&
            profile.name != 'Pengguna Cashly' &&
            profile.name != 'Pengguna FinTrack')
        ? profile.name
        : (currentUser?.displayName?.isNotEmpty == true
            ? currentUser!.displayName!
            : (profile.name.isNotEmpty ? profile.name : 'Pengguna'));
    final displayEmail = profile.email.isNotEmpty
        ? profile.email
        : (currentUser?.email ?? 'Belum ada email');
    final photoUrl = (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
        ? profile.avatarUrl
        : currentUser?.photoURL;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profil Pengguna')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar circle
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: (photoUrl != null && photoUrl.isNotEmpty)
                            ? Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    profile.initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  profile.initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayEmail,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (profile.occupation.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          profile.occupation,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),

                    // Edit Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            _showEditProfileModal(context, profile),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text(
                          'Edit Profil',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Mini Overview Statistics
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaksi Dicatat',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${finance.transactions.length}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kategori Anggaran',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${finance.budgets.length}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Settings List
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.currency_exchange_rounded,
                      title: 'Kurs Mata Uang & Konverter',
                      subtitle: 'Pantau nilai tukar live & kalkulator valas',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CurrencyScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingsTile(
                      icon: Icons.language_rounded,
                      title: 'Bahasa Aplikasi',
                      subtitle: 'Bahasa Indonesia (id_ID)',
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Tentang Aplikasi',
                      subtitle: 'Informasi versi dan pengembang',
                      onTap: () => _showAboutDialog(context),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingsTile(
                      icon: Icons.cloud_download_rounded,
                      title: 'Muat Data Presentasi (Erwin Wijaya)',
                      subtitle: 'Isi otomatis data bulan ini & bulan kemarin',
                      titleColor: AppColors.primary,
                      iconColor: AppColors.primary,
                      onTap: () => _confirmSeedErwinData(context),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingsTile(
                      icon: Icons.restore_rounded,
                      title: 'Reset ke Data Awal',
                      subtitle: 'Kembalikan data percontohan default',
                      titleColor: AppColors.warning,
                      iconColor: AppColors.warning,
                      onTap: () => _confirmResetData(context),
                    ),
                    if (currentUser != null) ...[
                      const Divider(height: 1, indent: 56),
                      _buildSettingsTile(
                        icon: Icons.logout_rounded,
                        title: 'Keluar Akun Google',
                        subtitle: 'Logout dari ${currentUser.email}',
                        titleColor: AppColors.expense,
                        iconColor: AppColors.expense,
                        onTap: () async {
                          await AuthService().signOut();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Berhasil logout dari akun Google'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          }
                        },
                      ),
                    ] else ...[
                      const Divider(height: 1, indent: 56),
                      _buildSettingsTile(
                        icon: Icons.login_rounded,
                        title: 'Masuk dengan Akun Google',
                        subtitle: 'Hubungkan akun Google Anda',
                        titleColor: AppColors.primary,
                        iconColor: AppColors.primary,
                        onTap: () async {
                          try {
                            final cred = await AuthService().signInWithGoogle();
                            if (cred != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Berhasil login sebagai ${cred.user?.displayName ?? cred.user?.email}',
                                  ),
                                  backgroundColor: AppColors.income,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal login: $e'),
                                  backgroundColor: AppColors.expense,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? titleColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppColors.textMuted,
      ),
    );
  }
}
