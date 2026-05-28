import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../shared/error_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _registerMockSocial(String source) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final email = '${source}_traveler@gachamerch.com';
      final name = source == 'google' ? 'Google Traveler' : 'HoyoVerse Traveler';
      final oauthId = 'oauth_${source}_123456789';
      
      await authProvider.loginOauth(email, name, oauthId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login via $source berhasil!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Widget _socialButton({
    required String label,
    required String letter,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: const Color(0xff1C2436),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0x22ffffff), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                letter,
                style: const TextStyle(
                  color: Color(0xffFF6B6B), // Premium pinkish-red accent letter
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: AppTheme.space2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Banner Image at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Image.asset(
              'assets/images/register_banner.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Back button layered on top of the banner
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          
          // Scrollable Card content overlapping the banner
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 220), // Height spacer for the banner image
                  
                  ClipPath(
                    clipper: TiltedClipper(),
                    child: Container(
                      width: double.infinity,
                      color: Colors.black,
                      padding: const EdgeInsets.only(
                        top: 60, // Spacing to avoid title overlapping the tilt
                        left: AppTheme.space6,
                        right: AppTheme.space6,
                        bottom: AppTheme.space8,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppTheme.space8),
                            
                            // Name Field Label
                            const Text(
                              'Name',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppTheme.space2),
                            
                            // Name Input
                            TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                fillColor: const Color(0xff1C2436),
                                filled: true,
                                hintText: 'Enter your name',
                                hintStyle: const TextStyle(color: AppTheme.textMuted),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.space6,
                                  vertical: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                errorStyle: const TextStyle(color: Colors.redAccent),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Name cannot be empty!';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppTheme.space4),
                            
                            // Email Field Label
                            const Text(
                              'Email',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppTheme.space2),
                            
                            // Email Input
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                fillColor: const Color(0xff1C2436),
                                filled: true,
                                hintText: 'email@example.com',
                                hintStyle: const TextStyle(color: AppTheme.textMuted),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.space6,
                                  vertical: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                errorStyle: const TextStyle(color: Colors.redAccent),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty || !val.contains('@')) {
                                  return 'Format email tidak valid!';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppTheme.space4),
                            
                            // Password Field Label
                            const Text(
                              'Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppTheme.space2),
                            
                            // Password Input
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                fillColor: const Color(0xff1C2436),
                                filled: true,
                                hintText: '••••••••',
                                hintStyle: const TextStyle(color: AppTheme.textMuted),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.space6,
                                  vertical: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: AppTheme.textMuted,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                errorStyle: const TextStyle(color: Colors.redAccent),
                              ),
                              validator: (val) {
                                if (val == null || val.length < 6) {
                                  return 'Password minimal 6 karakter!';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppTheme.space4),
                            
                            // Confirm Password Field Label
                            const Text(
                              'Confirm Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppTheme.space2),
                            
                            // Confirm Password Input
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                fillColor: const Color(0xff1C2436),
                                filled: true,
                                hintText: '••••••••',
                                hintStyle: const TextStyle(color: AppTheme.textMuted),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.space6,
                                  vertical: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: AppTheme.textMuted,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                errorStyle: const TextStyle(color: Colors.redAccent),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Konfirmasi password Anda!';
                                }
                                if (val != _passwordController.text) {
                                  return 'Password tidak cocok!';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppTheme.space8),
                            
                            // Register Action Button
                            authProvider.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(color: AppTheme.accent),
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.accent, // Geo Gold
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'REGISTER',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: AppTheme.space6),
                            
                            // Social Divider
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: Color(0x22ffffff)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.space3),
                                  child: Text(
                                    'or register with',
                                    style: TextStyle(
                                      color: AppTheme.textMuted.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: Color(0x22ffffff)),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.space4),
                            
                            // Social buttons Row
                            Row(
                              children: [
                                Expanded(
                                  child: _socialButton(
                                    label: 'Google',
                                    letter: 'G',
                                    onPressed: () => _registerMockSocial('google'),
                                  ),
                                ),
                                const SizedBox(width: AppTheme.space4),
                                Expanded(
                                  child: _socialButton(
                                    label: 'HoyoVerse',
                                    letter: 'H',
                                    onPressed: () => _registerMockSocial('hoyoverse'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.space8),
                            
                            // Already have account redirection
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Already have an account? Login',
                                  style: TextStyle(color: AppTheme.accent),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TiltedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Start on the left, slightly lower (down at y=40)
    path.moveTo(0, 40);
    // Draw a smooth bezier curve to the top-right corner (width, 0)
    path.quadraticBezierTo(
      size.width * 0.5,
      20,
      size.width,
      0,
    );
    // Draw lines to form the rest of the closed box
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
