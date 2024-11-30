// home_screen.dart

import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/brand_post.dart';
import 'widgets/brand_grid_item.dart';
import 'widgets/image_slider_dialog.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'widgets/new_badge.dart';

/// 화면 표시 모드를 정의하는 열거형
/// - grid2x2: 2x2 그리드 형태
/// - grid3x3: 3x3 그리드 형태
/// - list: 리스트 형태
enum ViewMode {
  grid2x2,
  grid3x3,
  list
}

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkTheme;
  final String title;

  const HomeScreen({
    Key? key,
    required this.title,
    required this.toggleTheme,
    required this.isDarkTheme,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  // 상태 변수들
  List<dynamic> _brands = [];
  Map<String, List<BrandPost>> _brandPosts = {};
  bool _isLoading = true;
  String _errorMessage = '';
  ViewMode _currentViewMode = ViewMode.grid3x3;
  String _sortType = '';  // 정렬 방식을 저장하는 변수

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  bool _isRecentlyUpdated(lastUpdated) {
    if (lastUpdated.isEmpty) return false;

    try {
      final lastUpdateDate = DateTime.parse(lastUpdated);
      final now = DateTime.now();
      final difference = now.difference(lastUpdateDate);

      return difference.inDays <= 0;
    } catch (e) {
      return false;
    }
  }
  /// ViewMode를 순환하는 메소드
  /// grid3x3 -> grid2x2 -> list -> grid3x3 순으로 변경
  void _toggleViewMode() {
    setState(() {
      switch (_currentViewMode) {
        case ViewMode.grid3x3:
          _currentViewMode = ViewMode.grid2x2;
          break;
        case ViewMode.grid2x2:
          _currentViewMode = ViewMode.list;
          break;
        case ViewMode.list:
          _currentViewMode = ViewMode.grid3x3;
          break;
      }
    });
  }

  /// 현재 ViewMode에 해당하는 아이콘을 반환
  IconData _getViewModeIcon() {
    switch (_currentViewMode) {
      case ViewMode.grid3x3:
        return Icons.grid_on;
      case ViewMode.grid2x2:
        return Icons.grid_view;
      case ViewMode.list:
        return Icons.list;
    }
  }

  /// 브랜드 데이터와 최근 게시물을 가져오는 메소드
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final brands = await _apiService.fetchBrands();
      setState(() {
        _brands = brands;
      });

      // 각 브랜드의 최근 게시물 가져오기
      for (var brand in brands) {
        final brandName = brand['name'];
        await _fetchRecentPosts(brandName);
      }
    } catch (e) {
      setState(() {
        _errorMessage = '데이터를 불러오는 중 문제가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 특정 브랜드의 최근 게시물을 가져오는 메소드
  Future<void> _fetchRecentPosts(String brandName) async {
    try {
      final posts = await _apiService.fetchRecentPosts(brandName);
      setState(() {
        _brandPosts[brandName] = posts;
      });
    } catch (e) {
      print('Error fetching posts for $brandName: $e');
    }
  }

  /// 브랜드의 썸네일 URL을 가져오는 메소드
  String _getThumbnailUrl(String brandName) {
    final posts = _brandPosts[brandName] ?? [];
    if (posts.isEmpty) return '';

    final schedulePost = posts.firstWhere(
          (post) => post.postType == 'SETTING_SCHEDULE',
      orElse: () => posts.first,
    );

    return schedulePost.imageUrl;
  }

  /// 브랜드의 프로필 이미지 URL을 생성하는 메소드
  String _getProfileUrl(String brandName, String imageName) {
    if (imageName.isEmpty) return '';
    return '${AppConstants.staticImage}/$brandName/$imageName.jpg';
  }

  /// 현재 날짜를 "MM월 dd일" 형식으로 반환하는 메소드
  String _getCurrentDate() {
    final now = DateTime.now();
    return DateFormat('MM월 dd일').format(now);
  }

  /// AppBar를 구성하는 메소드
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.title),
          const SizedBox(width: 8),
          Text(
            _getCurrentDate(),
            style: TextStyle(
              fontSize: 14,
              color: widget.isDarkTheme ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(_getViewModeIcon()),
          onPressed: _toggleViewMode,
          tooltip: '보기 방식 변경',
        ),
        IconButton(
          icon: Icon(widget.isDarkTheme ? Icons.wb_sunny : Icons.nights_stay),
          onPressed: widget.toggleTheme,
        ),
      ],
    );
  }

  /// 브랜드 리스트 뷰를 구성하는 메소드
  /// 브랜드 리스트 뷰를 구성하는 메소드
  Widget _buildBrandList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: _brands.length,
      itemBuilder: (context, index) {
        final item = _brands[index];
        final brandName = item['name'];
        final brandNameKr = item['name_kr'];
        final posts = _brandPosts[brandName] ?? [];
        final lastUpdated = item['last_updated'] ?? '';
        final profileUrl = _getProfileUrl(brandName, item['profile_image'] ?? '');
        final isRecent = _isRecentlyUpdated(lastUpdated);

        return InkWell(
          onTap: () => showDialog(
            context: context,
            builder: (context) => ImageSliderDialog(
              posts: posts,
              isDarkTheme: widget.isDarkTheme,
            ),
          ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                _buildProfileImage(profileUrl),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        brandNameKr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isRecent) ...[
                        const SizedBox(width: 8),
                        const NewBadge(size: 10),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 프로필 이미지를 구성하는 메소드
  Widget _buildProfileImage(String profileUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: profileUrl.isNotEmpty
            ? Image.network(
          profileUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person_outline,
              color: Colors.grey[400],
              size: 24,
            );
          },
        )
            : Icon(
          Icons.person_outline,
          color: Colors.grey[400],
          size: 24,
        ),
      ),
    );
  }

  /// 그리드 뷰를 구성하는 메소드
  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _currentViewMode == ViewMode.grid2x2 ? 2 : 3,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _brands.length,
      itemBuilder: (context, index) {
        final item = _brands[index];
        final brandName = item['name'];
        final brandNameKr = item['name_kr'];
        final posts = _brandPosts[brandName] ?? [];
        final lastUpdated = item['last_updated'] ?? '';
        final thumbnailUrl = _getThumbnailUrl(brandName);
        final profileUrl = _getProfileUrl(brandName, item['profile_image'] ?? '');

        return BrandGridItem(
          brandName: brandName,
          brandNameKr: brandNameKr,
          posts: posts,
          lastUpdated: lastUpdated,
          thumbnailUrl: thumbnailUrl,
          profileUrl: profileUrl,
          isDarkTheme: widget.isDarkTheme,
          grid: _currentViewMode == ViewMode.grid2x2 ? 2 : 3,
        );
      },
    );
  }

  /// 메인 화면 본문을 구성하는 메소드
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_brands.isEmpty) {
      return const Center(child: Text('브랜드 데이터가 없습니다.'));
    }

    return _currentViewMode == ViewMode.list ? _buildBrandList() : _buildGrid();
  }

  /// 최신순으로 정렬하는 메소드
  void _sortByLatest() {
    setState(() {
      _brands.sort((a, b) {
        DateTime dateA = DateTime.parse(a['last_updated']);
        DateTime dateB = DateTime.parse(b['last_updated']);
        return dateB.compareTo(dateA);
      });
      _sortType = 'latest';
    });
  }

  /// 이름순으로 정렬하는 메소드
  void _sortByName() {
    setState(() {
      _brands.sort((a, b) => a['name_kr'].compareTo(b['name_kr']));
      _sortType = 'name';
    });
  }

  /// 정렬 버튼을 구성하는 메소드
  Widget _buildSortButtons() {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 4),
          _buildSortButton('업데이트순', 'latest', _sortByLatest),
          _buildSortButton('이름순', 'name', _sortByName),
        ],
      ),
    );
  }

  /// 개별 정렬 버튼을 구성하는 메소드
  Widget _buildSortButton(String text, String type, VoidCallback onPressed) {
    final theme = Theme.of(context);
    final isSelected = _sortType == type;

    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          // 테마에 따른 색상 적용
          color: isSelected
              ? theme.textTheme.bodyLarge?.color?.withOpacity(1)
              : theme.colorScheme.primary
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSortButtons(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}