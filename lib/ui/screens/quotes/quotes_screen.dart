import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/quote.dart';
import '../../../core/models/quote_item.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/quote_service.dart';
import '../../common/app_drawer.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  // Format for currency
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  // Format for dates
  final dateFormat = DateFormat('MMM d, yyyy');
  
  @override
  void initState() {
    super.initState();
    // Load quotes when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuoteService>(context, listen: false).getQuotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final quoteService = Provider.of<QuoteService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotes'),
      ),
      drawer: const AppDrawer(currentRoute: '/quotes'),
      floatingActionButton: authService.hasRole(UserRole.lead) 
          ? FloatingActionButton(
              onPressed: () => _showCreateQuoteDialog(context),
              tooltip: 'Create New Quote',
              child: const Icon(Icons.add),
            )
          : null,
      body: quoteService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : quoteService.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error Loading Quotes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        quoteService.error ?? 'Unknown error',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => quoteService.getQuotes(),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : quoteService.quotes.isEmpty
                  ? _buildEmptyState(context, authService)
                  : _buildQuotesList(context, quoteService.quotes, authService),
    );
  }

  Widget _buildEmptyState(BuildContext context, AuthService authService) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.request_quote_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Quotes',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            authService.hasRole(UserRole.lead)
                ? 'Create your first quote using the + button'
                : 'No quotes are available right now',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotesList(BuildContext context, List<Quote> quotes, AuthService authService) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quotes.length,
      itemBuilder: (context, index) {
        final quote = quotes[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: InkWell(
            onTap: () => _showQuoteDetails(context, quote),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quote #${quote.id}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        quote.createdDate != null
                            ? dateFormat.format(quote.createdDate!)
                            : 'No date',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Appointment ID',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '#${quote.appointmentId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Estimate',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            currencyFormat.format(quote.estimate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (authService.hasRole(UserRole.lead))
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                            onPressed: () => _editQuote(context, quote),
                          ),
                          if (authService.hasRole(UserRole.admin))
                            TextButton.icon(
                              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                              label: const Text('Delete', style: TextStyle(color: Colors.red)),
                              onPressed: () => _confirmDeleteQuote(context, quote),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showQuoteDetails(BuildContext context, Quote quote) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quote #${quote.id}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appointment ID: #${quote.appointmentId}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Employee ID: #${quote.employeeId}',
              ),
              const SizedBox(height: 8),
              Text(
                'Created: ${quote.createdDate != null ? dateFormat.format(quote.createdDate!) : 'No date'}',
              ),
              const SizedBox(height: 16),
              Text(
                'Total Estimate: ${currencyFormat.format(quote.estimate)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Divider(),
              if (quote.items != null && quote.items!.isNotEmpty) ...[
                const Text(
                  'Quote Items:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: quote.items!.length,
                    itemBuilder: (context, index) {
                      final item = quote.items![index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          item.service?.name ?? 'Service #${item.serviceId}',
                        ),
                        subtitle: Text(
                          item.service?.description ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currencyFormat.format(item.cost),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (authService.hasRole(UserRole.admin))
                              IconButton(
                                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                onPressed: () => _deleteQuoteItem(context, quote.id!, item.id!),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ] else
                const Text('No items in this quote'),
            ],
          ),
        ),
        actions: [
          if (authService.hasRole(UserRole.lead))
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addQuoteItem(context, quote);
              },
              child: const Text('Add Item'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateQuoteDialog(BuildContext context) async {
    // Implementation for creating a new quote
    // This would typically show a form to select an appointment, employee, etc.
    // For simplicity, we'll just show a placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Quote'),
        content: const Text('Quote creation form would go here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle quote creation
              Navigator.of(context).pop();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _editQuote(BuildContext context, Quote quote) async {
    // Implementation for editing a quote
    // This would typically show a form to edit quote details
    // For simplicity, we'll just show a placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Quote #${quote.id}'),
        content: const Text('Quote edit form would go here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle quote update
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteQuote(BuildContext context, Quote quote) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete Quote #${quote.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final quoteService = Provider.of<QuoteService>(context, listen: false);
      await quoteService.deleteQuote(quote.id!);
    }
  }

  Future<void> _addQuoteItem(BuildContext context, Quote quote) async {
    // Implementation for adding an item to a quote
    // This would typically show a form to select a service and enter cost
    // For simplicity, we'll just show a placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Item to Quote #${quote.id}'),
        content: const Text('Quote item form would go here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle item addition
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteQuoteItem(BuildContext context, int quoteId, int itemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this quote item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final quoteService = Provider.of<QuoteService>(context, listen: false);
      await quoteService.deleteQuoteItem(quoteId, itemId);
    }
  }
} 