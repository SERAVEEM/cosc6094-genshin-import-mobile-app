import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_comment.dart';
import 'api_service.dart';

class CommentService {
  static void _handleResponseError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    try {
      final body = jsonDecode(response.body);
      throw Exception(
        body['message'] ??
            'Terjadi kesalahan pada server (Status: ${response.statusCode})',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
        'Terjadi kesalahan pada server (Status: ${response.statusCode})',
      );
    }
  }

  static Future<List<ProductComment>> getComments(String weaponId) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/weapons/$weaponId/comments'),
      headers: await ApiService.getHeaders(),
    );
    _handleResponseError(response);
    final data = jsonDecode(response.body)['data'] as List;
    return data.map((item) => ProductComment.fromJson(item)).toList();
  }

  static Future<ProductComment> createComment(
    String weaponId,
    int rating,
    String content,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/weapons/$weaponId/comments'),
      headers: await ApiService.getHeaders(),
      body: jsonEncode({'rating': rating, 'content': content}),
    );
    _handleResponseError(response);
    final data = jsonDecode(response.body)['data'];
    return ProductComment.fromJson(data);
  }
}
