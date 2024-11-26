// lib/screens/home/widgets/brand_grid_item.dart

import 'package:flutter/material.dart';
import '../../../models/brand_post.dart';
import 'package:intl/intl.dart';
import 'image_slider_dialog.dart';

class BrandGridItem extends StatelessWidget {
  final String brandName;
  final String brandNameKr;
  final List<BrandPost> posts;
  final String lastUpdated;
  final String thumbnailUrl;
  final bool isDarkTheme;

  const BrandGridItem({
    Key? key,
    required this.brandName,
    required this.brandNameKr,
    required this.posts,
    required this.lastUpdated,
    required this.thumbnailUrl,
    required this.isDarkTheme,
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
          // Thumbnail Image
          Positioned.fill(
            child: thumbnailUrl.isNotEmpty
                ? Hero(
              tag: '$brandName-thumbnail',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  thumbnailUrl,
                  fit: BoxFit.cover,
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
          // Black Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          // Brand Name Text
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Text(
              brandNameKr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

}