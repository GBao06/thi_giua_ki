import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/user.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com';

  // Token lưu tạm trong bộ nhớ (tắt app là mất). Muốn giữ đăng nhập thì lưu vào
  // shared_preferences hoặc flutter_secure_storage.
  static String? _accessToken;

  // Giải mã UTF-8 thủ công để không bị lỗi font tiếng Việt
  static dynamic _decode(http.Response res) =>
      jsonDecode(utf8.decode(res.bodyBytes));

  /// POST /auth/login. Tài khoản thử: emilys / emilyspass
  static Future<User> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );
    final data = _decode(res) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw ApiException(
        data['message'] as String? ?? 'Đăng nhập thất bại',
      );
    }
    _accessToken = data['accessToken'] as String;
    return User.fromJson(data);
  }

  /// GET /auth/me: lấy thông tin người dùng đang đăng nhập (cần token)
  static Future<User> getCurrentUser() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );
    if (res.statusCode != 200) {
      throw const ApiException('Không lấy được thông tin tài khoản');
    }
    return User.fromJson(_decode(res) as Map<String, dynamic>);
  }

  /// GET /products hoặc /products/search?q=...
  static Future<List<Product>> getProducts({String query = ''}) async {
    final uri = query.trim().isEmpty
        ? Uri.parse('$_baseUrl/products?limit=30')
        : Uri.parse('$_baseUrl/products/search').replace(
            queryParameters: {'q': query.trim(), 'limit': '30'},
          );
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw const ApiException('Không tải được danh sách sản phẩm');
    }
    final data = _decode(res) as Map<String, dynamic>;
    return (data['products'] as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static void logout() => _accessToken = null;
}
