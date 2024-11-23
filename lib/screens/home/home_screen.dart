// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/brand_post.dart';
import 'widgets/brand_list_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List<dynamic> _data = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, List<BrandPost>> _brandPosts = {};
  Set<String> _fetchedBrands = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse(API_URL));

      print('Fetching brands from API');
      print('Request URL: $API_URL');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // 추가된 로그

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          _data = responseData['data'] ?? [];
          _isLoading = false;
        });

        // 각 브랜드에 대해 최근 게시글을 한 번씩만 불러옵니다.
        for (var brand in _data) {
          final brandName = brand['name'];
          // `days` 값을 전달하여 최근 DAYS일 내의 게시글을 가져옵니다.
          _fetchRecentPosts(brandName);
        }
      } else {
        _setError('데이터 로드 실패. 나중에 다시 시도해주세요.');
      }
    } catch (e) {
      _setError('데이터를 가져오는 중 오류가 발생했습니다.');
      print('데이터를 가져오는 중 오류 발생: $e');
    }
  }

  /// `days`는 더 이상 함수의 파라미터가 아니므로 제거되었습니다.
  Future<void> _fetchRecentPosts(String brandName) async {
    if (_fetchedBrands.contains(brandName)) {
      // 이미 호출된 브랜드이므로 다시 호출하지 않음
      return;
    }

    _fetchedBrands.add(brandName);

    // `{brand_name}`을 실제 브랜드 이름으로 대체
    final String recentPostsUrl =
    RECENT_POSTS_API_URL_TEMPLATE.replaceAll('{brand_name}', brandName);

    // Uri 빌드
    Uri uri = Uri.parse(recentPostsUrl);

    // `days` 파라미터를 상수 DAYS로 설정
    uri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'days': DAYS.toString(),
      },
    );

    try {
      final response = await http.get(uri);

      print('Fetching recent posts for brand: $brandName');
      print('Request URL: $uri');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // 추가된 로그

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        print('API 응답: $responseData'); // 추가된 로그

        if (responseData['success'] == true) {
          final data = responseData['data'];
          if (data is List) {
            setState(() {
              _brandPosts[brandName] =
                  data.map((post) => BrandPost.fromJson(post)).toList();
            });
          } else if (data is String) {
            print('데이터가 리스트가 아닙니다: $data');
            setState(() {
              _brandPosts[brandName] = [];
            });
          } else {
            print('예상치 못한 데이터 형식: ${data.runtimeType}');
            setState(() {
              _brandPosts[brandName] = [];
            });
          }
        } else {
          print('최근 게시글이 없습니다.');
          setState(() {
            _brandPosts[brandName] = [];
          });
        }
      } else {
        print(
            '최근 게시글 데이터를 가져오는 중 HTTP 오류 발생. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('최근 게시글 데이터를 가져오는 중 오류 발생: $e');
    }
  }

  void _setError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    return ListView.builder(
      itemCount: _data.length,
      itemBuilder: _buildListItem,
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    final item = _data[index];
    final brandName = item['name'];
    final posts = _brandPosts[brandName] ?? [];
    final lastUpdated = item['last_updated'] ?? '';

    return BrandListItem(
      brandName: brandName,
      posts: posts,
      lastUpdated: lastUpdated,
      isDarkTheme: widget.isDarkTheme,
    );
  }
}
