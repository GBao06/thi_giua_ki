import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/helpers.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onBuyNow;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onBuyNow,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      // InkWell bọc cả card: bấm chỗ nào cũng onTap, riêng 2 nút bên dưới
      // tự xử lý sự kiện của nó nên không kích hoạt onTap của card.
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chỉ dùng 1 ảnh chính (thumbnail) ở trang danh sách
                  Image.network(
                    product.thumbnail,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => const SizedBox(
                      width: 100,
                      height: 100,
                      child: Icon(Icons.broken_image),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfo()),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onAddToCart,
                      child: const Text('Thêm vào giỏ'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onBuyNow,
                      child: const Text('Mua ngay'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            Text(' ${product.rating.toStringAsFixed(1)}'),
            Text(
              '  (${product.reviewCount} đánh giá)',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Wrap để tự xuống dòng nếu màn hình hẹp
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '-${product.discountPercentage.round()}%',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              formatPrice(product.price),
              style: const TextStyle(
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
        Text(
          formatPrice(product.discountedPrice),
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
