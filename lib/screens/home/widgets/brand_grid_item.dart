// lib/screens/home/widgets/brand_grid_item.dart

import 'package:flutter/material.dart';
import 'dart:ui'; // ImageFilter를 사용하기 위해 필요
import '../../../models/brand_post.dart';
// import 'package:intl/intl.dart'; // _formatDate 제거로 인해 더 이상 필요 없음
// import 'image_slider_dialog.dart'; // 팝업 제거로 인해 더 이상 필요 없음
import 'new_badge.dart';

class BrandGridItem extends StatelessWidget {
  final String brandName;
  final String brandNameKr;
  final List<BrandPost> posts;
  final String lastUpdated;
  final String thumbnailUrl;
  final String profileUrl;
  final bool isDarkTheme;
  final int grid;
  // --- 추가된 필드 ---
  final bool isSubscribed;
  final ValueChanged<bool>? onSubscriptionChanged;
  // --- 추가 끝 ---

  const BrandGridItem({
    Key? key,
    required this.brandName,
    required this.brandNameKr,
    required this.posts,
    required this.lastUpdated,
    required this.thumbnailUrl,
    required this.profileUrl,
    required this.isDarkTheme,
    required this.grid,
    // --- 생성자에 추가 ---
    required this.isSubscribed,
    this.onSubscriptionChanged,
    // --- 추가 끝 ---
  }) : super(key: key);

  // _formatDate 메서드는 사용되지 않으므로 제거 가능

  // --- 팝업 로직 제거 ---
  // void _showImageSlider(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => ImageSliderDialog(
  //       posts: posts,
  //       isDarkTheme: isDarkTheme,
  //     ),
  //   );
  // }
  // --- 팝업 로직 제거 끝 ---

  bool _isRecentlyUpdated() {
    if (lastUpdated.isEmpty) return false;
    try {
      final lastUpdateDate = DateTime.parse(lastUpdated);
      final now = DateTime.now();
      // 당일 업데이트된 것만 'New' 표시 (기존 HomeScreen 로직과 통일)
      return now.difference(lastUpdateDate).inDays <= 0 &&
          now.day == lastUpdateDate.day &&
          now.month == lastUpdateDate.month &&
          now.year == lastUpdateDate.year;
    } catch (e) {
      print('Error parsing date in BrandGridItem: $lastUpdated, $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      // --- onTap 제거 (팝업 호출 제거) ---
      onTap: () {
        // 클릭 시 동작 없음 또는 다른 동작 (예: print)
        print('$brandNameKr 그리드 아이템 탭됨 (팝업 없음)');
      },
      borderRadius: BorderRadius.circular(8), // InkWell 효과를 위한 테두리 유지
      child: Card( // Card로 감싸 시각적 경계 제공
        elevation: isDarkTheme ? 2 : 1,
        clipBehavior: Clip.antiAlias, // Card 경계 외부 콘텐츠 자르기
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail with Blur Effect
            if (thumbnailUrl.isNotEmpty)
              ClipRRect( // 이미지 자체에도 BorderRadius 적용
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image, color: Colors.grey[400]),
                      ),
                    ),
                    // Blur Effect
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                      child: Container(color: Colors.black.withOpacity(0.05)),
                    ),
                  ],
                ),
              )
            else
            // 썸네일 없을 경우
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400]),
                ),
              ),

            // Profile Image at the Center
            Center( // Align 대신 Center 사용 가능
              child: CircleAvatar(
                radius: grid == 2 ? 40 : 25,
                backgroundColor: Colors.white.withOpacity(0.5), // 배경 약간 투명하게
                child: ClipOval(
                  child: profileUrl.isNotEmpty
                      ? Image.network(
                    profileUrl,
                    width: grid == 2 ? 80 : 50,
                    height: grid == 2 ? 80 : 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person_outline,
                      size: grid == 2 ? 40 : 25,
                      color: Colors.grey[600],
                    ),
                  )
                      : Icon(
                    Icons.person_outline,
                    size: grid == 2 ? 40 : 25,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),

            // Bottom Overlay (Name and Switch)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  // 그라데이션 배경으로 가독성 향상
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.0),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Brand Name
                    Expanded(
                      child: Text(
                        brandNameKr,
                        style: TextStyle(
                          fontSize: grid == 2 ? 14 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // 흰색 텍스트
                          shadows: [ // 텍스트 그림자 추가 (선택 사항)
                            Shadow(
                              blurRadius: 2.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // --- 스위치 추가 ---
                    if (onSubscriptionChanged != null)
                      Transform.scale( // 스위치 크기 조절
                        scale: 0.7,
                        alignment: Alignment.centerRight,
                        child: Switch(
                          value: isSubscribed,
                          onChanged: onSubscriptionChanged,
                          activeTrackColor: theme.colorScheme.primaryContainer.withOpacity(0.7),
                          inactiveTrackColor: Colors.grey.withOpacity(0.5),
                          activeColor: theme.colorScheme.primary,
                          inactiveThumbColor: Colors.white,
                          // Material 3 스타일 적용 시 thumbIcon 사용 가능
                          // thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                          //   (Set<MaterialState> states) {
                          //     if (states.contains(MaterialState.selected)) {
                          //       return const Icon(Icons.check, color: Colors.white);
                          //     }
                          //     return const Icon(Icons.close);
                          //   },
                          // ),
                        ),
                      ),
                    // --- 스위치 추가 끝 ---
                  ],
                ),
              ),
            ),

            // New Badge
            if (_isRecentlyUpdated())
              Positioned(
                top: 6,
                right: 6,
                child: NewBadge(size: grid == 2 ? 10 : 8), // 뱃지 크기 약간 조정
              ),
          ],
        ),
      ),
    );
  }
}