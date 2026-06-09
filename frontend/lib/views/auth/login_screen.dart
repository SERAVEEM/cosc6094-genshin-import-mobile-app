import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../shared/error_dialog.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    // Web client ID — required for Android Google Sign-In to resolve Error 10
    serverClientId: '203621729218-es7oitgrifuk9863muugk5v16t7gl9dg.apps.googleusercontent.com',
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.login(_emailController.text.trim(), _passwordController.text.trim());
      // Navigate to HomeScreen on successful login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _loginGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      await authProvider.loginOauth(
        googleUser.email,
        googleUser.displayName ?? 'Google Traveler',
        googleUser.id,
      );
      // Navigate to HomeScreen on successful OAuth login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        _showGoogleFallbackDialog(e.toString());
      }
    }
  }

  void _showGoogleFallbackDialog(String debugError) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff111622),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.borderSubtle),
          ),
          title: Row(
            children: [
              Image.asset('assets/auth/google.png', height: 20),
              const SizedBox(width: 8),
              const Text(
                'Google Sign-In Setup',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Native Google Sign-In failed to initialize:',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  debugError,
                  style: const TextStyle(color: AppTheme.accent, fontFamily: 'monospace', fontSize: 11),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Note: To run native OAuth, you must register your Android debug SHA-1 signature in the Google Cloud/Firebase Console.\n\nWould you like to log in using a mock Google Traveler account instead?',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCEL', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                final localContext = context;
                Navigator.of(dialogContext).pop();
                final authProvider = Provider.of<AuthProvider>(localContext, listen: false);
                final navigator = Navigator.of(localContext);
                try {
                  await authProvider.loginOauth(
                    'google_traveler@gachamerch.com',
                    'Google Traveler',
                    'oauth_google_123456789',
                  );
                  // Navigate to HomeScreen after successful mock Google login
                  if (localContext.mounted) {
                    navigator.pushReplacementNamed('/home');
                  }
                } catch (e) {
                  if (localContext.mounted) {
                    ErrorDialog.show(localContext, e.toString().replaceAll('Exception: ', ''));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('MOCK LOGIN', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loginMockHoyo() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.loginOauth(
        'hoyoverse_traveler@gachamerch.com',
        'HoyoVerse Traveler',
        'oauth_hoyoverse_123456789',
      );
      // Navigate to HomeScreen on successful mock Hoyo login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xff22252D).withValues(alpha: 0.8), // Dark capsule fill
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            textAlign: TextAlign.center, // Centered text inside the input
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }

  Widget _socialButton({
    required String label,
    required String imageAsset,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 140, // compact size
      decoration: BoxDecoration(
        color: const Color(0xff22252D).withValues(alpha: 0.8), // matching capsule fill
        borderRadius: BorderRadius.circular(30),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imageAsset,
                  height: 16,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
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
          // Banner Image at the top (Mitsuri banner matching Register screen)
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
          
          // Scrollable Card content overlapping the banner
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 220), // Height spacer for the banner image
                  
                  ClipPath(
                    clipper: CurveClipper(), // Wave curve clipper
                    child: Container(
                      width: double.infinity,
                      color: Colors.black,
                      padding: const EdgeInsets.only(
                        top: 90, // Spacing to avoid title overlapping the curve
                        left: AppTheme.space6,
                        right: AppTheme.space6,
                        bottom: AppTheme.space8,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppTheme.space8),
                            
                            // Email Input
                            _buildInputField(
                              controller: _emailController,
                              label: 'Email',
                              hintText: 'Enter your email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.isEmpty || !val.contains('@')) {
                                  return 'Format email tidak valid!';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppTheme.space4),
                            
                            // Password Input
                            _buildInputField(
                              controller: _passwordController,
                              label: 'Password',
                              hintText: 'Enter your password',
                              obscureText: true,
                              validator: (val) {
                                if (val == null || val.length < 6) {
                                  return 'Password minimal 6 karakter!';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppTheme.space8),
                            
                            // Log In Button
                            authProvider.isLoading
                                ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                                : SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.accent,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'LOG IN',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: AppTheme.space8),
                            
                             Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 _socialButton(
                                   label: 'Google',
                                   imageAsset: 'assets/auth/google.png',
                                   onPressed: _loginGoogle,
                                 ),
                                 const SizedBox(width: 16),
                                 _socialButton(
                                   label: 'HoyoVerse',
                                   imageAsset: 'assets/auth/hoyoverse.png',
                                   onPressed: _loginMockHoyo,
                                 ),
                               ],
                             ),
                            const SizedBox(height: AppTheme.space8),
                            
                            // Redirection
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                  );
                                },
                                child: const Text(
                                  'Don\'t have an account? Register here',
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
          
          // Close button layered on top of the banner and scroll view
          if (Navigator.canPop(context))
            Positioned(
              top: 40,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    
    // Left edge goes up, then curves at the top-left corner
    path.lineTo(0, 60);
    path.quadraticBezierTo(0, 30, 30, 30);
    
    // Slanted top edge line to the beginning of the top-right corner
    path.lineTo(size.width - 30, 70);
    
    // Right curve to the right edge
    path.quadraticBezierTo(size.width, 70, size.width, 100);
    
    // Right edge down to bottom right
    path.lineTo(size.width, size.height);
    
    // Bottom edge back to bottom left
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
