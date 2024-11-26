import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/brand_post.dart';
import 'widgets/brand_list_item.dart';
import 'widgets/image_slider_dialog.dart'; // 추가적으로 필요한 위젯 임포트
import '../../services/api_service.dart'; // ApiService 임포트

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
  final ApiService _apiService = ApiService(); // ApiService 인스턴스 생성
  List<dynamic> _brands = [];
  Map<String, List<BrandPost>> _brandPosts = {};
  bool _isLoading = true; // 로딩 상태 관리
  String _errorMessage = ''; // 에러 메시지 관리

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // 데이터를 가져오는 메서드
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 브랜드 목록 가져오기
      final brands = await _apiService.fetchBrands();
      setState(() {
        _brands = brands;
      });

      // 각 브랜드의 최근 게시물 가져오기
      for (var brand in brands) {
        final brandName = brand['name'];
        await _fetchRecentPosts(brandName); // async로 비동기적으로 호출
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

  // 특정 브랜드의 최근 게시물 가져오기
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title),
          IconButton(
            icon: Icon(widget.isDarkTheme ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
    );
  }

  String _getThumbnailUrl(String brandName) {
    final posts = _brandPosts[brandName] ?? [];
    if (posts.isEmpty) return '';

    // SETTING_SCHEDULE 타입의 이미지를 먼저 찾음
    final schedulePost = posts.firstWhere(
          (post) => post.postType == 'SETTING_SCHEDULE',
      orElse: () => posts.first, // 없으면 가장 최근 게시물
    );

    return schedulePost.imageUrl;
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

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
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

        return BrandGridItem(
          brandName: brandName,
          brandNameKr: brandNameKr,
          posts: posts,
          lastUpdated: lastUpdated,
          thumbnailUrl: thumbnailUrl,
          isDarkTheme: widget.isDarkTheme,
        );
      },
    );
  }
}
