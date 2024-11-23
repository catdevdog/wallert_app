// lib/models/brand_post.dart

class BrandPost {
  final String postType;
  final String imageUrl;
  final String timestamp;

  BrandPost({
    required this.postType,
    required this.imageUrl,
    required this.timestamp,
  });

  factory BrandPost.fromJson(Map<String, dynamic> json) {
    final String brandName = json['brand_name'] ?? '';
    final String postType = json['post_type'] ?? '';
    final String imageHash = json['image_hash'] ?? '';
    final int id = json['id'] ?? 0;

    // 이미지 URL 구성
    final String constructedImageUrl =
        'https://catdevdog.i234.me:12222/$brandName/$postType/${brandName}_$id\_$imageHash.jpg';

    return BrandPost(
      postType: postType,
      imageUrl: constructedImageUrl,
      timestamp: json['timestamp'] ?? '',
    );
  }
}
