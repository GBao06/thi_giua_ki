class Review {
  final int rating;
  final String comment;
  final String reviewerName;

  const Review({
    required this.rating,
    required this.comment,
    required this.reviewerName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String? ?? '',
      reviewerName: json['reviewerName'] as String? ?? 'Ẩn danh',
    );
  }
}

class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final String? brand;
  final double price; // giá gốc
  final double discountPercentage;
  final double rating;
  final int stock;
  final String thumbnail; // ảnh chính, dùng ở trang danh sách
  final List<String> images; // nhiều ảnh, dùng ở trang chi tiết
  final List<Review> reviews;
  final String shippingInformation;
  final String warrantyInformation;
  final String returnPolicy;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.brand,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    required this.images,
    required this.reviews,
    required this.shippingInformation,
    required this.warrantyInformation,
    required this.returnPolicy,
  });

  // API trả về price là giá gốc, giá sau giảm phải tự tính
  double get discountedPrice => price * (1 - discountPercentage / 100);

  // API không có field "số lượt đánh giá" riêng, nên đếm theo mảng reviews
  int get reviewCount => reviews.length;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      brand: json['brand'] as String?, // một số sản phẩm không có brand
      price: (json['price'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      stock: (json['stock'] as num).toInt(),
      thumbnail: json['thumbnail'] as String? ?? '',
      images: List<String>.from(json['images'] as List? ?? []),
      reviews: (json['reviews'] as List? ?? [])
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      shippingInformation: json['shippingInformation'] as String? ?? '',
      warrantyInformation: json['warrantyInformation'] as String? ?? '',
      returnPolicy: json['returnPolicy'] as String? ?? '',
    );
  }
}
