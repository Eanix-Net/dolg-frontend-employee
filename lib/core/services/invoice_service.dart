import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/payment.dart';
import '../models/appointment.dart';
import '../models/customer.dart';
import '../api/api_service.dart';

class InvoiceService extends ChangeNotifier {
  static final _logger = Logger('InvoiceService');
  final ApiService _apiService;
  
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  InvoiceService(this._apiService);
  
  // Getters
  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get all invoices or filter by customer ID
  Future<List<Invoice>> getInvoices({int? customerId}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final endpoint = customerId != null 
          ? '/invoices?customer_id=$customerId' 
          : '/invoices';
      
      final response = await _apiService.get(endpoint);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _invoices = (data as List).map((json) => Invoice.fromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
        return _invoices;
      } else {
        throw Exception('Failed to load invoices: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error getting invoices: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Get a single invoice by ID
  Future<Invoice> getInvoice(int id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final response = await _apiService.get('/invoices/$id');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final invoice = Invoice.fromJson(data);
        _isLoading = false;
        notifyListeners();
        return invoice;
      } else {
        throw Exception('Failed to load invoice details: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error getting invoice detail: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Create a new invoice
  Future<Invoice> createInvoice(Invoice invoice) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final response = await _apiService.post(
        '/invoices',
        data: jsonEncode(invoice.toJson()),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final createdInvoice = Invoice.fromJson(data);
        _invoices.add(createdInvoice);
        _isLoading = false;
        notifyListeners();
        return createdInvoice;
      } else {
        throw Exception('Failed to create invoice: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error creating invoice: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Update an existing invoice
  Future<Invoice> updateInvoice(Invoice invoice) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      if (invoice.id == null) {
        throw Exception('Cannot update invoice: ID is null');
      }
      
      final response = await _apiService.put(
        '/invoices/${invoice.id}',
        data: jsonEncode(invoice.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedInvoice = Invoice.fromJson(data);
        
        // Update the invoice in the local list
        final index = _invoices.indexWhere((i) => i.id == updatedInvoice.id);
        if (index >= 0) {
          _invoices[index] = updatedInvoice;
        }
        
        _isLoading = false;
        notifyListeners();
        return updatedInvoice;
      } else {
        throw Exception('Failed to update invoice: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error updating invoice: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Delete an invoice
  Future<bool> deleteInvoice(int id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final response = await _apiService.delete('/invoices/$id');
      
      if (response.statusCode == 204) {
        _invoices.removeWhere((invoice) => invoice.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to delete invoice: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error deleting invoice: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Add payment to an invoice
  Future<Payment> addPayment(Payment payment) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final response = await _apiService.post(
        '/payments',
        data: jsonEncode(payment.toJson()),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final createdPayment = Payment.fromJson(data);
        
        // Get updated invoice to reflect new payment
        await getInvoice(payment.invoiceId);
        
        _isLoading = false;
        notifyListeners();
        return createdPayment;
      } else {
        throw Exception('Failed to add payment: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error adding payment: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Get payments for an invoice
  Future<List<Payment>> getInvoicePayments(int invoiceId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final response = await _apiService.get('/invoices/$invoiceId/payments');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final payments = (data as List).map((json) => Payment.fromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
        return payments;
      } else {
        throw Exception('Failed to load payments: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error getting payments: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Generate invoice from appointment
  Future<Invoice> generateInvoiceFromAppointment(Appointment appointment, Customer customer) async {
    try {
      // Create invoice items based on services provided during the appointment
      final items = <InvoiceItem>[];
      double total = 0.0;
      
      // In a real implementation, you would get services from the appointment
      // For now, we'll create a sample item
      final item = InvoiceItem(
        description: 'Lawn Service - ${DateFormat('MMM d, yyyy').format(appointment.arrivalDateTime)}',
        quantity: 1,
        unitPrice: 75.0, // Sample price
        amount: 75.0,
      );
      
      items.add(item);
      total += item.amount;
      
      // Create the invoice
      final invoice = Invoice(
        customerId: customer.id!,
        customerName: customer.name,
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)), // Due in 30 days
        total: total,
        balance: total, // Initially, balance equals total
        amountPaid: 0.0, // Add required amountPaid parameter
        status: InvoiceStatus.draft,
        items: items,
      );
      
      // Save the invoice to the API
      return await createInvoice(invoice);
    } catch (e) {
      _logger.severe('Error generating invoice from appointment: $e');
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
} 