import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/helpers.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _pageCtrl = PageController();
  Timer? _timer;
  int _current = 0;

  // Nếu API không có ảnh nào thì dùng tạm thumbnail
  late final List<String> _images = widget.product.images.isNotEmpty
      ? widget.product.images
      : [widget.product.thumbnail];

  @override
  void initState() {
    super.initState();
    // Tự chuyển ảnh mỗi 3 giây (chỉ khi có từ 2 ảnh trở lên)
    if (_images.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!_pageCtrl.hasClients) return;
        final next = (_current + 1) % _images.length;
        _pageCtrl.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // quan trọng: hủy timer để không bị rò rỉ bộ nhớ
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      appBar: AppBar(title: Text(p.title, overflow: TextOverflow.ellipsis)),
      body: ListView(
        children: [
          _buildImageSlider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [if (p.brand != null) p.brand!, p.category].join(' • '),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    Text(' ${p.rating.toStringAsFixed(1)}'),
                    Text(
                      '  (${p.reviewCount} đánh giá)',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPrice(),
                const SizedBox(height: 16),
                Text(p.description),
                const Divider(height: 32),
                _infoRow(Icons.inventory_2_outlined, 'Còn lại: ${p.stock} sản phẩm'),
                _infoRow(Icons.local_shipping_outlined, p.shippingInformation),
                _infoRow(Icons.verified_outlined, p.warrantyInformation),
                _infoRow(Icons.assignment_return_outlined, p.returnPolicy),
                const Divider(height: 32),
                const Text(
                  'Đánh giá',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (p.reviews.isEmpty) const Text('Chưa có đánh giá nào'),
                ...p.reviews.map(_buildReview),
              ],
            ),
          ),
        ],
      ),
      // Nút cố định ở đáy màn hình
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      showMessage(context, 'Đã thêm vào giỏ: ${p.title}'),
                  child: const Text('Thêm vào giỏ'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => showMessage(context, 'Mua ngay: ${p.title}'),
                  child: const Text('Mua ngay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _images.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) => Image.network(
              _images[i],
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) =>
                  const Center(child: Icon(Icons.broken_image, size: 48)),
            ),
          ),
          // Chấm tròn báo đang ở ảnh thứ mấy
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _images.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _current ? Colors.indigo : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrice() {
    final p = widget.product;
    return Wrap(
      spacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          formatPrice(p.discountedPrice),
          style: const TextStyle(
            color: Colors.red,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          formatPrice(p.price),
          style: const TextStyle(
            color: Colors.grey,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '-${p.discountPercentage.round()}%',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildReview(Review r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                r.reviewerName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              ...List.generate(
                5,
                (i) => Icon(
                  i < r.rating ? Icons.star : Icons.star_border,
                  size: 14,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          Text(r.comment),
        ],
      ),
    );
  }
}
