import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/brand_post.dart';
// import 'widgets/brand_grid_item.dart'; // --- 그리드 아이템 Import 제거 ---
// import 'widgets/image_slider_dialog.dart'; // 사용 안 함
import '../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'widgets/new_badge.dart';
import '../../services/notification_service.dart';
import '../web_view_screen.dart';
import '../calendar/calendar_screen.dart';

// enum ViewMode { grid2x2, grid3x3, list } // --- ViewMode Enum 제거 ---

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
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  List<dynamic> _brands = [];
  Map<String, List<BrandPost>> _brandPosts = {};
  bool _isLoading = true;
  String _errorMessage = '';
  // ViewMode _currentViewMode = ViewMode.list; // --- ViewMode 상태 변수 제거 ---
  Set<String> _subscribedGyms = {};

  // Data Management & Initialization

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    _fetchData();
    _loadSubscribedTopics();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final brands = await _apiService.fetchBrands();
      // 기본 정렬: 이름순으로 정렬
      brands.sort((a, b) {
        final nameA = a['name_kr'] ?? '';
        final nameB = b['name_kr'] ?? '';
        return nameA.compareTo(nameB);
      });

      setState(() {
        _brands = brands;
      });

      // 병렬 처리로 포스트 로딩 속도 개선 (선택 사항)
      await Future.wait(
          brands.map((brand) => _fetchRecentPosts(brand['name']))
      );

    } catch (e) {
      setState(() {
        _errorMessage = '데이터를 불러오는 중 문제가 발생했습니다: $e';
      });
    } finally {
      // 모든 데이터 로딩 후 로딩 상태 변경
      if (mounted) { // 비동기 작업 후 위젯 상태 확인
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  Future<void> _fetchRecentPosts(String brandName) async {
    try {
      final posts = await _apiService.fetchRecentPosts(brandName);
      // setState 호출 전에 위젯 마운트 상태 확인
      if (mounted) {
        setState(() {
          _brandPosts[brandName] = posts;
        });
      }
    } catch (e) {
      print('Error fetching posts for $brandName: $e');
    }
  }

  // *** START: Updated Info Dialog Method ***
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder( // 모서리 둥글게
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Row( // 아이콘과 텍스트를 함께 표시
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              const Text('앱 안내'),
            ],
          ),
          content: const SingleChildScrollView( // 내용이 길어질 경우 스크롤 가능
            child: ListBody( // 리스트 형태로 내용 구성
              // *** UPDATED CONTENT START ***
              children: <Widget>[
                Text('Wallert 앱은 클라이밍장의 최신 세팅 일정을 알림으로 받아볼 수 있는 앱입니다.'),
                SizedBox(height: 10),
                Text('세팅 정보는 각 클라이밍장의 공식 인스타그램 게시물을 기반으로 업데이트됩니다.'),
                SizedBox(height: 10),
                Text('현재는 \'더클라임\' 브랜드의 세팅 정보만 제공하고 있습니다.'),
                SizedBox(height: 10),
                Text('리스트 우측 스위치를 통해 [구독/해제] 할 수 있으며, 알림은 세팅 하루 전 오후 7시에 일괄 전송됩니다.'),
              ],
              // *** UPDATED CONTENT END ***
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }
  // *** END: Updated Info Dialog Method ***

// 아래는 _buildAppBar 메서드의 전체 수정된 코드입니다:
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
          icon: const Icon(Icons.calendar_month),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalendarScreen()),
            );
          },
          tooltip: '세팅 일정 캘린더',
        ),
        IconButton(
          icon: Icon(widget.isDarkTheme ? Icons.wb_sunny : Icons.nights_stay),
          onPressed: widget.toggleTheme,
          tooltip: '테마 변경',
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showInfoDialog(context),
          tooltip: '앱 정보',
        ),
      ],
    );
  }

  void _navigateToWebView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: AppConstants.webViewUrl),
      ),
    );
  }

  // *** START: Modified Profile Image Placeholder ***
  Widget _buildProfileImage(String profileUrl) { // profileUrl parameter kept for compatibility

    return ClipOval(
      child: Container(
        width: 40,
        height: 40,
        color: Colors.grey[200], // Background for error/loading state
        child: profileUrl.isNotEmpty
            ? Image.network(
                profileUrl,
                fit: BoxFit.cover,
                // Optional: Add loadingBuilder for smoother loading
                // loadingBuilder: (context, child, loadingProgress) {
                //   if (loadingProgress == null) return child;
                //   return Center(
                //     child: CircularProgressIndicator(
                //       value: loadingProgress.expectedTotalBytes != null
                //           ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                //           : null,
                //     ),
                //   );
                // },
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person_outline, // Fallback icon on error
                  color: Colors.grey[400],
                  size: 30,
                ),
              )
            : Icon(
                Icons.person_outline, // Fallback icon when URL is empty
                color: Colors.grey[400],
                size: 30,
              ),
      ),
    );
  }
  // *** END: Modified Profile Image Placeholder ***


  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEmptyBrandDataMessage() {
    return const Center(child: Text('브랜드 데이터가 없습니다.'));
  }


  Widget _buildBodyContent() {
    return _buildBrandList();
  }


  Widget _buildBody() {
    if (_isLoading) return _buildLoadingIndicator();
    if (_errorMessage.isNotEmpty) return _buildErrorMessage();
    if (_brands.isEmpty) return _buildEmptyBrandDataMessage();
    return _buildBodyContent();
  }

  Widget _buildBrandItem(Map<String, dynamic> item, String brandName,
      String brandNameKr, List<BrandPost> posts, String lastUpdated) {
    // Pass the profileUrl even if the image isn't displayed currently
    final profileUrl = _getProfileUrl(brandName, item['profile_image'] ?? '');
    final isRecent = _isRecentlyUpdated(lastUpdated);
    final topic = brandName.replaceAll(' ', '_').toLowerCase();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          _buildProfileImage(profileUrl), // Call the modified function 프로필 이미지
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    brandNameKr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // if (isRecent) ...[
                //   const SizedBox(width: 8),
                //   const NewBadge(size: 10),
                // ],
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            alignment: Alignment.centerRight,
            child: Switch(
              value: _subscribedGyms.contains(topic),
              onChanged: (value) => _toggleSubscription(brandName, brandNameKr),
              activeColor: widget.isDarkTheme ? theme.colorScheme.outline: Colors.white,
              activeTrackColor:  widget.isDarkTheme ? Colors.white : Colors.blueAccent,
              inactiveThumbColor: theme.colorScheme.outline,
              inactiveTrackColor: theme.colorScheme.surfaceVariant,
            ),
          ),
        ],
      ),
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
        final lastUpdated = item['last_updated'] ?? '';
        return _buildBrandItem(item, brandName, brandNameKr, posts, lastUpdated);
      },
    );
  }

  // Helper Methods
  String _getCurrentDate() {
    return DateFormat('MM월 dd일').format(DateTime.now());
  }

  // This method is kept for potential future use or if the original image code is uncommented
  String _getProfileUrl(String brandName, String imageName) {
    // brandName이 비어있으면 빈 문자열 반환
    if (brandName.isEmpty) return '';

    // baseUrl 끝에 '/'가 없으면 추가
    final baseUrl = AppConstants.staticImage.endsWith('/')
        ? AppConstants.staticImage
        : '${AppConstants.staticImage}/';

    // --- 새로운 파일 이름 생성 로직 ---
    String targetName;
    int underscoreIndex = brandName.indexOf('_'); // 첫 번째 '_'의 인덱스 찾기

    if (underscoreIndex != -1) {
      // '_'가 있으면, 그 앞부분을 사용
      targetName = brandName.substring(0, underscoreIndex);
    } else {
      // '_'가 없으면, 전체 brandName 사용
      targetName = brandName;
    }

    // 최종 파일 이름 생성 (예: theclimb.png)
    String generatedFilename = '$targetName.png';
    // --- 파일 이름 생성 로직 끝 ---

    // 최종 URL 생성 (baseUrl 바로 뒤에 생성된 파일 이름 붙임)
    // 예: https://catdevdog.i234.me:12222/theclimb.png
    return '$baseUrl$generatedFilename';
  }

  bool _isRecentlyUpdated(lastUpdated) {
    if (lastUpdated == null || lastUpdated.isEmpty) return false;
    try {
      final lastUpdateDate = DateTime.parse(lastUpdated);
      final now = DateTime.now();
      return now.difference(lastUpdateDate).inDays <= 0 &&
          now.day == lastUpdateDate.day &&
          now.month == lastUpdateDate.month &&
          now.year == lastUpdateDate.year;
    } catch (e) {
      print('Error parsing date in HomeScreen: $lastUpdated, $e');
      return false;
    }
  }


  // Subscription Related Methods
  Future<void> _loadSubscribedTopics() async {
    final subscribedTopics = await _notificationService.loadSubscribedTopics();
    if (mounted) {
      setState(() {
        _subscribedGyms = subscribedTopics;
      });
    }
  }


  Future<void> _toggleSubscription(String gymName, String gymNameKr) async {
    final topic = gymName.replaceAll(' ', '_').toLowerCase();
    bool isSubscribing = !_subscribedGyms.contains(topic);

    if (mounted) {
      setState(() {
        if (isSubscribing) {
          _subscribedGyms.add(topic);
        } else {
          _subscribedGyms.remove(topic);
        }
      });
    }

    try {
      if (isSubscribing) {
        await _notificationService.subscribeToTopic(topic);
        _showSubscriptionSnackBar('$gymNameKr 알림을 구독했습니다.');
      } else {
        await _notificationService.unsubscribeFromTopic(topic);
        _showSubscriptionSnackBar('$gymNameKr 알림을 해제했습니다.');
      }
    } catch (e) {
      print('Error toggling subscription for $topic: $e');
      _showSubscriptionSnackBar('알림 설정 변경 중 오류가 발생했습니다.', isError: true);
      if (mounted) {
        setState(() {
          if (isSubscribing) {
            _subscribedGyms.remove(topic);
          } else {
            _subscribedGyms.add(topic);
          }
        });
      }
    }
  }


  void _showSubscriptionSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.redAccent
            : Theme.of(context).snackBarTheme.backgroundColor ?? (widget.isDarkTheme ? Colors.white : Colors.black87),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }
}