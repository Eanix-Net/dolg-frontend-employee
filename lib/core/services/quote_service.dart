import 'package:flutter/foundation.dart';
import '../api/api_service.dart';
import '../models/quote.dart';
import '../models/quote_item.dart';

class QuoteService with ChangeNotifier {
  final ApiService _apiService;
  bool _isLoading = false;
  String? _error;
  List<Quote> _quotes = [];

  QuoteService(this._apiService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Quote> get quotes => _quotes;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Get all quotes
  Future<List<Quote>> getQuotes() async {
    _setLoading(true);
    try {
      final response = await _apiService.get('/quotes');
      _quotes = (response as List)
          .map((json) => Quote.fromJson(json))
          .toList();
      _setError(null);
      return _quotes;
    } catch (e) {
      _setError('Failed to load quotes: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Get a specific quote by ID
  Future<Quote?> getQuote(int id) async {
    _setLoading(true);
    try {
      final response = await _apiService.get('/quotes/$id');
      final quote = Quote.fromJson(response);
      _setError(null);
      return quote;
    } catch (e) {
      _setError('Failed to load quote: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Create a new quote
  Future<Quote?> createQuote(Quote quote) async {
    _setLoading(true);
    try {
      final response = await _apiService.post(
        '/quotes',
        data: quote.toJson(),
      );
      final newQuote = Quote.fromJson(response);
      _quotes.add(newQuote);
      notifyListeners();
      _setError(null);
      return newQuote;
    } catch (e) {
      _setError('Failed to create quote: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing quote
  Future<Quote?> updateQuote(Quote quote) async {
    _setLoading(true);
    try {
      final response = await _apiService.put(
        '/quotes/${quote.id}',
        data: quote.toJson(),
      );
      final updatedQuote = Quote.fromJson(response);
      
      // Update the quote in the local list
      final index = _quotes.indexWhere((q) => q.id == quote.id);
      if (index != -1) {
        _quotes[index] = updatedQuote;
        notifyListeners();
      }
      
      _setError(null);
      return updatedQuote;
    } catch (e) {
      _setError('Failed to update quote: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a quote
  Future<bool> deleteQuote(int id) async {
    _setLoading(true);
    try {
      await _apiService.delete('/quotes/$id');
      
      // Remove the quote from the local list
      _quotes.removeWhere((q) => q.id == id);
      notifyListeners();
      
      _setError(null);
      return true;
    } catch (e) {
      _setError('Failed to delete quote: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add a service item to a quote
  Future<QuoteItem?> addQuoteItem(int quoteId, int serviceId, double cost) async {
    _setLoading(true);
    try {
      final data = {
        'service_id': serviceId,
        'cost': cost
      };
      
      final response = await _apiService.post(
        '/quotes/$quoteId/items',
        data: data,
      );
      
      final newItem = QuoteItem.fromJson(response);
      
      // Update the quote in our list if it exists
      final quoteIndex = _quotes.indexWhere((q) => q.id == quoteId);
      if (quoteIndex != -1) {
        final updatedQuote = await getQuote(quoteId);
        if (updatedQuote != null) {
          _quotes[quoteIndex] = updatedQuote;
          notifyListeners();
        }
      }
      
      _setError(null);
      return newItem;
    } catch (e) {
      _setError('Failed to add item to quote: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a quote item
  Future<bool> deleteQuoteItem(int quoteId, int itemId) async {
    _setLoading(true);
    try {
      await _apiService.delete('/quotes/item/$itemId');
      
      // Update the quote in our list if it exists
      final quoteIndex = _quotes.indexWhere((q) => q.id == quoteId);
      if (quoteIndex != -1) {
        final updatedQuote = await getQuote(quoteId);
        if (updatedQuote != null) {
          _quotes[quoteIndex] = updatedQuote;
          notifyListeners();
        }
      }
      
      _setError(null);
      return true;
    } catch (e) {
      _setError('Failed to delete quote item: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
} 