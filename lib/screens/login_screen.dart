import 'package:flutter/material.dart';
import 'package:simodis_jatim/screens/home_screen.dart';
import 'package:simodis_jatim/widgets/notification_permission_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isLoading = false;

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final identifier = _identifierController.text.trim().toLowerCase();
      final password = _passwordController.text;

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;

        String? targetRole;
        String roleLabel = '';

        // 1. LOGIN SEBAGAI SUPERADMIN (ADMINISTRATOR PUSAT)
        if ((identifier == 'superadmin' ||
                identifier == '197001011990031001' ||
                identifier == 'administrator@dinsos.jatimprov.go.id') &&
            password == 'password') {
          targetRole = 'superadmin';
          roleLabel = 'Superadministrator Pusat';
        }
        // 2. LOGIN SEBAGAI ADMIN (KASUBAG UMUM / ASET)
        else if ((identifier == 'admin' ||
                identifier == '197805122005011004' ||
                identifier == '198501012010011001') &&
            password == 'password') {
          targetRole = 'admin';
          roleLabel = 'Kasubag Tata Usaha & Aset';
        }
        // 3. LOGIN SEBAGAI PEGAWAI (USER PEMOHON)
        else if ((identifier == 'pegawai' ||
                identifier == 'user' ||
                identifier == '199503152020121002') &&
            password == 'password') {
          targetRole = 'user';
          roleLabel = 'Pegawai / Pemohon';
        }

        if (targetRole != null) {
          _showLoginSuccessLoading(targetRole, roleLabel);
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Username/NIP atau Password salah! (Gunakan pass: password)'),
                  ),
                ],
              ),
            ),
          );
        }
      });
    }
  }

  void _showLoginSuccessLoading(String targetRole, String roleLabel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Spinner with Checkmark Icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2B5B9E)),
                          backgroundColor: Color(0xFFE2E8F0),
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF16A34A),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Login Berhasil!',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Menyiapkan dashboard $roleLabel...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const SizedBox(
                      width: 140,
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        backgroundColor: Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context, rootNavigator: true).pop(); // Tutup loading dialog

      // Munculkan dialog perizinan notifikasi
      NotificationPermissionDialog.show(
        context,
        onGranted: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF16A34A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: const Row(
                children: [
                  Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Notifikasi aktif. Anda akan menerima pembaruan berkas secara real-time.'),
                  ),
                ],
              ),
            ),
          );
          _navigateToHome(targetRole);
        },
        onDismissed: () {
          _navigateToHome(targetRole);
        },
      );
    });
  }

  void _navigateToHome(String targetRole) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(role: targetRole),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
      (route) => false,
    );
  }

  // Quick fill untuk mempermudah testing saat demo/pengembangan
  void _quickFill(String username) {
    _identifierController.text = username;
    _passwordController.text = 'password';
    _handleLogin();
  }

  void _showContactAdminDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.support_agent_rounded, color: Color(0xFF2B5B9E)),
            SizedBox(width: 8),
            Text(
              'Bantuan Akun Login',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Akun default sistem untuk pengujian (Semua pass: password):',
              style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
            SizedBox(height: 8),
            Text('• Superadmin: superadmin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text('• Admin Kasubag: admin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text('• Pegawai Pemohon: pegawai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B5B9E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24487A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/logo_sipk.png',
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: const Icon(
                              Icons.directions_car_rounded,
                              size: 40,
                              color: Color(0xFF2B5B9E),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'LOGIN MASUK',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),

                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'SIP-K ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2B5B9E),
                            ),
                          ),
                          TextSpan(
                            text: 'DINSOS JATIM',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Username / NIP',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _identifierController,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText: 'Contoh: superadmin / admin / pegawai',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.person, size: 20, color: Color(0xFF94A3B8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2B5B9E), width: 1.5),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isPasswordObscured,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText: 'Masukkan password (password)',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.lock, size: 20, color: Color(0xFF94A3B8)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 20,
                            color: const Color(0xFF94A3B8),
                          ),
                          onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2B5B9E), width: 1.5),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Password wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B5B9E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Masuk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.login_rounded, size: 18),
                              ],
                            ),
                    ),

                    const SizedBox(height: 18),

                    // Quick Login Chips untuk Uji Coba Cepat
                    // Quick Login Chips untuk Uji Coba Cepat (Bebas Overflow)
                    const Center(
                      child: Text('Akses Cepat Demo:', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6, // Jarak horizontal antar chip
                      runSpacing: 6, // Jarak vertikal jika turun baris
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.shield, size: 14, color: Color(0xFFB45309)),
                          label: const Text('Superadmin', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          onPressed: () => _quickFill('superadmin'),
                          backgroundColor: const Color(0xFFFEF3C7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.admin_panel_settings, size: 14, color: Color(0xFF24487A)),
                          label: const Text('Kasubag', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          onPressed: () => _quickFill('admin'),
                          backgroundColor: const Color(0xFFEFF6FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.person, size: 14, color: Color(0xFF475569)),
                          label: const Text('User', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          onPressed: () => _quickFill('pegawai'),
                          backgroundColor: const Color(0xFFF1F5F9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: GestureDetector(
                        onTap: _showContactAdminDialog,
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            children: [
                              TextSpan(text: 'Kendala saat login? '),
                              TextSpan(
                                text: 'Bantuan Akun',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),

                    const Text(
                      'Dinas Sosial Provinsi Jawa Timur',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}