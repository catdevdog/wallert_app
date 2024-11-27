import 'package:flutter/material.dart';
import 'dart:ui'; // ImageFilter를 사용하기 위해 필요
import '../../../models/brand_post.dart';
import 'package:intl/intl.dart';
import 'image_slider_dialog.dart';

class BrandGridItem extends StatelessWidget {
  final String brandName;
  final String brandNameKr;
  final List<BrandPost> posts;
  final String lastUpdated;
  final String thumbnailUrl;
  final String profileUrl;
  final bool isDarkTheme;
  final int grid;

  const BrandGridItem({
    Key? key,
    required this.brandName,
    required this.brandNameKr,
    required this.posts,
    required this.lastUpdated,
    required this.thumbnailUrl,
    required this.profileUrl,
    required this.isDarkTheme,
    required this.grid
  }) : super(key: key);

  String _formatDate(String dateStr) {
    try {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr;
    }
  }

  void _showImageSlider(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ImageSliderDialog(
        posts: posts,
        isDarkTheme: isDarkTheme,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showImageSlider(context),
      child: Stack(
        children: [
          // Thumbnail with Blur Effect
          Positioned.fill(
            child: thumbnailUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  // Original Thumbnail
                  Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                  // Blur Effect
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                      child: Container(
                        color: Colors.black.withOpacity(0.05), // 반투명 효과
                      ),
                    ),
                  ),
                ],
              ),
            )
                : Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),

          // Profile Image at the Center
          Align(
            alignment: Alignment.center, // 아이템 기준 정가운데 배치
            child: CircleAvatar(
              radius: grid == 2 ? 40 :25, // 원형 이미지 크기
              // backgroundColor: Colors.white, // 원형 테두리 색상
              child: ClipOval(
                child: profileUrl.isNotEmpty
                    ? Image.network(
                  profileUrl,
                  width: grid == 2 ? 80 : 45,
                  height: grid == 2 ? 80 : 45,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.error_outline,
                      color: Colors.grey[400],
                    );
                  },
                )
                    : Icon(
                  Icons.person_outline,
                  size: 30,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),

          // Brand Name Text
          Positioned(
            bottom: grid == 2 ? 12 : 8,
            left: 8,
            right: 8,
            child: Text(
              brandNameKr,
              style: TextStyle(
                fontSize: grid == 2 ? 16 : 12,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
