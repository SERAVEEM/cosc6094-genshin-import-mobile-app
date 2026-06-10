import 'package:flutter/material.dart';
import '../models/product_comment.dart';
import '../services/comment_service.dart';

class CommentProvider with ChangeNotifier {
  final Map<String, List<ProductComment>> _commentsByWeapon = {};
  final Set<String> _loadingWeaponIds = {};
  String _errorMessage = '';
  bool _isSubmitting = false;

  String get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;

  List<ProductComment> commentsFor(String weaponId) {
    return _commentsByWeapon[weaponId] ?? [];
  }

  bool isLoading(String weaponId) {
    return _loadingWeaponIds.contains(weaponId);
  }

  Future<void> fetchComments(String weaponId) async {
    _loadingWeaponIds.add(weaponId);
    _errorMessage = '';
    notifyListeners();

    try {
      _commentsByWeapon[weaponId] = await CommentService.getComments(weaponId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _loadingWeaponIds.remove(weaponId);
      notifyListeners();
    }
  }

  Future<void> createComment(
    String weaponId,
    int rating,
    String content,
  ) async {
    _isSubmitting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final comment = await CommentService.createComment(
        weaponId,
        rating,
        content,
      );
      final comments = List<ProductComment>.from(
        _commentsByWeapon[weaponId] ?? [],
      );
      comments.insert(0, comment);
      _commentsByWeapon[weaponId] = comments;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
