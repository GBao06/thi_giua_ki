import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'product_list_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Điền sẵn tài khoản thử của dummyjson cho tiện test
  final _usernameCtrl = TextEditingController(text: 'emilys');
  final _passwordCtrl = TextEditingController(text: 'emilyspass');

  bool _loading = false;
  bool _obscure = true;
  String? _error;
  
  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await ApiService.login(
        _usernameCtrl.text.trim(),
        _passwordCtrl.text,
      );
      if (!mounted) return;
      // pushReplacement: thay trang login để bấm Back không quay lại được
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProductListPage(user: user)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Không thể kết nối. Kiểm tra mạng và thử lại.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Easy',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên đăng nhập',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  onSubmitted: (_) => _loading ? null : _login(),
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Đăng nhập'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
