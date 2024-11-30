// home_screen.dart

import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/brand_post.dart';
import 'widgets/brand_list_item.dart';
import 'widgets/image_slider_dialog.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

enum ViewMode {
  grid2x2,
  grid3x3,
  list
}

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkTheme;

  const HomeScreen({
    Key? key,
    required this.title,
    required this.toggleTheme,
    required this.isDarkTheme,
  }) : super(key: key);

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _brands = [];
  Map<String, List<BrandPost>> _brandPosts = {};
  bool _isLoading = true;
  String _errorMessage = '';
  ViewMode _currentViewMode = ViewMode.grid3x3;
  String sortType = '';

  // ViewMode 순환을 위한 메소드
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

  // ViewMode에 따른 아이콘 반환
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

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

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

  String _getThumbnailUrl(String brandName) {
    final posts = _brandPosts[brandName] ?? [];
    if (posts.isEmpty) return '';

    final schedulePost = posts.firstWhere(
          (post) => post.postType == 'SETTING_SCHEDULE',
      orElse: () => posts.first,
    );

    return schedulePost.imageUrl;
  }

  String _getProfileUrl(String brandName, String imageName) {
    if (imageName == '') return '';
    return '${AppConstants.staticImage}/$brandName/$imageName.jpg';
  }
// 날짜 포맷 함수
  String _getCurrentDate() {
    final now = DateTime.now();
    return DateFormat('MM월 dd일').format(now); // 날짜를 "MM월 dd일" 형식으로 변환
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.title),
          const SizedBox(width: 8),
          Text(
            _getCurrentDate(), // 날짜 표시
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[300],
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

  Widget _buildBrandList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: _brands.length,
      itemBuilder: (context, index) {
        final item = _brands[index];
        final brandName = item['name'];
        final brandNameKr = item['name_kr'];
        final posts = _brandPosts[brandName] ?? [];
        final profileUrl = _getProfileUrl(item['name'], item['profile_image'] ?? '');

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
                ClipRRect(
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    brandNameKr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
        final profileUrl = _getProfileUrl(item['name'], item['profile_image'] ?? '');

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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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
      return const Center(
        child: Text('브랜드 데이터가 없습니다.'),
      );
    }

    return _currentViewMode == ViewMode.list ? _buildBrandList() : _buildGrid();
  }

  // 최신순 정렬 함수
  void _sortByLatest() {
    setState(() {
      _brands.sort((a, b) {
        // `last_updated` 값을 DateTime으로 변환하여 비교
        DateTime dateA = DateTime.parse(a['last_updated']);
        DateTime dateB = DateTime.parse(b['last_updated']);
        return dateB.compareTo(dateA); // 최신순: B -> A
      });
    });
    sortType = 'latest';
  }

  // 이름순 정렬 함수
  void _sortByName() {
    setState(() {
      _brands.sort((a, b) {
        return a['name_kr'].compareTo(b['name_kr']); // 이름순 정렬
      });
    });
    sortType = 'name';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 상단에 정렬 버튼 추가
          Padding(
            padding: const EdgeInsets.all(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // 좌측 정렬
              children: [
                TextButton(
                  onPressed: _sortByLatest, // 최신순 정렬 함수 호출
                  child: Text(
                    '업데이트순',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: sortType == 'latest' ? Colors.white : Colors.grey, // 버튼 텍스트 색상
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _sortByName, // 이름순 정렬 함수 호출
                  child: Text(
                    '이름순',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: sortType == 'name' ? Colors.white : Colors.grey, // 버튼 텍스트 색상
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 스크롤 가능한 위젯을 넣기 위해 Expanded 사용
          Expanded(
            child: _buildBody(), // 기존 body
          ),
        ],
      ),
    );
  }
}