import 'package:flutter/material.dart';

/// 12.5 -> "$12.50"
String formatPrice(double value) => '\$${value.toStringAsFixed(2)}';

/// Hiện thông báo ngắn ở cuối màn hình
void showMessage(BuildContext context, String text) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(content: Text(text), duration: const Duration(seconds: 1)),
  );
}
