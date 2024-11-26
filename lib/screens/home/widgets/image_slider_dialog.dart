// lib/screens/home/widgets/image_slider_dialog.dart

import 'package:flutter/material.dart';
import '../../../models/brand_post.dart';

class ImageSliderDialog extends StatefulWidget {
  final List<BrandPost> posts;
  final bool isDarkTheme;

  const ImageSliderDialog({
    Key? key,
    required this.posts,
    required this.isDarkTheme,
  }) : super(key: key);

  @override
  State<ImageSliderDialog> createState() => _ImageSliderDialogState();
}

class _ImageSliderDialogState extends State<ImageSliderDialog> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                // 이미지 슬라이더
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: widget.posts.length,
                    itemBuilder: (context, index) {
                      final post = widget.posts[index];
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Hero(
                          tag: '${post.imageUrl}-$index',
                          child: Image.network(
                            post.imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 닫기 버튼
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            // 페이지 인디케이터
            if (widget.posts.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.posts.length,
                        (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            // 게시물 타입 표시
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.posts[_currentPage].postType,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}