import 'package:flutter/foundation.dart';
import '../api/api_service.dart';
import '../models/review.dart';

class ReviewService with ChangeNotifier {
  final ApiService _apiService;
  bool _isLoading = false;
  String? _error;
  List<Review> _reviews = [];

  ReviewService(this._apiService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Review> get reviews => _reviews;

  Future<List<Review>> getReviews() async {
    _setLoading(true);
    try {
      final response = await _apiService.get('/reviews');
      _reviews = (response as List)
          .map((json) => Review.fromJson(json))
          .toList();
      _setError(null);
      return _reviews;
    } catch (e) {
      _setError('Failed to load reviews: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<Review?> getReview(int id) async {
    _setLoading(true);
    try {
      final response = await _apiService.get('/reviews/$id');
      final review = Review.fromJson(response);
      _setError(null);
      return review;
    } catch (e) {
      _setError('Failed to load review: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteReview(int id) async {
    _setLoading(true);
    try {
      await _apiService.delete('/reviews/$id');
      _reviews.removeWhere((r) => r.id == id);
      notifyListeners();
      _setError(null);
      return true;
    } catch (e) {
      _setError('Failed to delete review: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    if (value != null) {
      notifyListeners();
    }
  }
} 