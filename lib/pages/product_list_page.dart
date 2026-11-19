import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';
import 'profile_page.dart';

class ProductListPage extends StatefulWidget {
  final User user;

  const ProductListPage({super.key, required this.user});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  List<Product> _products = [];
  bool _loading = true;
  String? _error;

  // Mỗi lần gọi API tăng 1. Dùng để bỏ qua kết quả của request cũ
  // (ví dụ gõ "phone" rồi gõ tiếp "phones", request cũ về trễ hơn request mới).
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProducts([String query = '']) async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await ApiService.getProducts(query: query);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _products = result;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = 'Không tải được danh sách sản phẩm';
        _loading = false;
      });
    }
  }

  // Debounce: đợi người dùng ngừng gõ 500ms mới gọi API, tránh gọi liên tục
  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _loadProducts(text),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );
  }

  void _openDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Hình tròn ở bên trái navbar, bấm vào mở trang profile
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: _openProfile,
            child: CircleAvatar(
              backgroundImage: NetworkImage(widget.user.image),
            ),
          ),
        ),
        title: const Text('Easy'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _loadProducts(_searchCtrl.text),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    if (_products.isEmpty) {
      return const Center(child: Text('Không tìm thấy sản phẩm nào'));
    }

    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ProductCard(
          product: product,
          onTap: () => _openDetail(product),
          onBuyNow: () => showMessage(context, 'Mua ngay: ${product.title}'),
          onAddToCart: () =>
              showMessage(context, 'Đã thêm vào giỏ: ${product.title}'),
        );
      },
    );
  }
}
