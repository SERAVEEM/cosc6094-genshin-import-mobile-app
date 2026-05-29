import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistProvider with ChangeNotifier {
  Set<String> _wishlist = {};

  Set<String> get items => _wishlist;

  WishlistProvider() {
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listStr = prefs.getString('wishlist_items');
      if (listStr != null) {
        final List<dynamic> decoded = jsonDecode(listStr);
        _wishlist = decoded.cast<String>().toSet();
        notifyListeners();
      }
    } catch (_) {}
  }

  bool isWishlisted(String id) {
    return _wishlist.contains(id);
  }

  Future<void> toggleWishlist(String id) async {
    if (_wishlist.contains(id)) {
      _wishlist.remove(id);
    } else {
      _wishlist.add(id);
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('wishlist_items', jsonEncode(_wishlist.toList()));
    } catch (_) {}
  }
}
