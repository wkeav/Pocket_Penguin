import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
/*
  Container that switches between Login & Register screens
*/

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true; // Tracks which screen to show

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin; // Flip between true/false
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          width: 375,
          height: 800,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE0F2FE), Color(0xFFDBEAFE)],
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.grey[800]!, width: 8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Column(
              children: [
                // Phone Notch
                Container(
                  width: 128,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    border: Border(
                      bottom: BorderSide(color: Colors.blue[100]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.asset("images/logo.png", width: 32, height: 32),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Pocket Penguin',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: _isLogin
                      ? LoginScreen(onToggleMode: _toggleMode)
                      : RegisterScreen(onToggleMode: _toggleMode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

