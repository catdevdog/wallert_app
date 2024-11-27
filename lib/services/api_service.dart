import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/brand_post.dart';

class ApiService {
  // 브랜드 목록 가져오기
  Future<List<dynamic>> fetchBrands() async {
    final String url = '${AppConstants.baseUrl}/brands'; // BASE_URL + /brands
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        print('fetchBrands response: $responseData');
        return responseData['data'] ?? [];
      } else {
        print('Error fetching brands: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load brands');
      }
    } catch (e) {
      print('Exception during fetchBrands: $e');
      throw Exception('Error fetching brands');
    }
  }

  // 특정 브랜드의 최근 게시물 가져오기
  Future<List<BrandPost>> fetchRecentPosts(String brandName) async {
    final String url = '${AppConstants.baseUrl}/brands/$brandName/recent-posts?days=${AppConstants.days}';

    try {
      final response = await http.get(Uri.parse(url)); // 쿼리 파라미터로 days 전달
      print('Request URL: $url'); // 디버깅용 로그

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        print('fetchRecentPosts response: $responseData'); // 디버깅용 로그

        if (responseData['success'] == true) {
          return (responseData['data'] as List)
              .map((post) => BrandPost.fromJson(post))
              .toList();
        }
        return []; // 성공했지만 데이터가 없을 경우
      } else {
        print('Error fetching posts for $brandName: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load posts for brand $brandName');
      }
    } catch (e) {
      print('Exception during fetchRecentPosts for $brandName: $e');
      throw Exception('Error fetching posts for brand $brandName');
    }
  }
}
