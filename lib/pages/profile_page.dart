import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Gán Future vào biến để FutureBuilder không gọi lại API mỗi lần build
  late Future<User> _future = ApiService.getCurrentUser();

  void _logout() {
    ApiService.logout();
    // Xóa hết các trang trước đó, quay về login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang cá nhân')),
      body: FutureBuilder<User>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Không tải được thông tin tài khoản'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(
                      () => _future = ApiService.getCurrentUser(),
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          return _buildProfile(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildProfile(User user) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 56,
            backgroundImage: NetworkImage(user.image),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          '@${user.username}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        _row(Icons.email_outlined, 'Email', user.email),
        _row(Icons.phone_outlined, 'Điện thoại', user.phone ?? '-'),
        _row(Icons.person_outline, 'Giới tính', user.gender ?? '-'),
        _row(Icons.badge_outlined, 'ID', '${user.id}'),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Đăng xuất'),
        ),
      ],
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }
}
