// lib/screens/home/widgets/brand_list_item.dart

import 'package:flutter/material.dart';
import '../../../models/brand_post.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_constants.dart';

class BrandListItem extends StatelessWidget {
  final String brandName;
  final List<BrandPost> posts;
  final String lastUpdated;
  final bool isDarkTheme;

  const BrandListItem({
    Key? key,
    required this.brandName,
    required this.posts,
    required this.lastUpdated,
    required this.isDarkTheme,
  }) : super(key: key);

  String _formatDate(String dateStr) {
    try {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr;
    }
  }

  void _showEnlargedImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // 배경을 투명하게 설정
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
            child: Hero(
              tag: imageUrl, // 고유한 태그 설정
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, size: 50, color: Colors.red),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            brandName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          Text(
            _formatDate(lastUpdated),
            style: TextStyle(
              fontSize: 12,
              color: isDarkTheme ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (posts.isNotEmpty) ...[
                Text(
                  '최근 게시글',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showEnlargedImage(context, post.imageUrl);
                              },
                              child: Hero(
                                tag: post.imageUrl, // 고유한 태그 설정
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    post.imageUrl,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 150,
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.error),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 150,
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              post.postType,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkTheme ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ] else
                Text(
                  '최근 $DAYS일 내에 게시된 공지가 없습니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkTheme ? Colors.white70 : Colors.black87,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
