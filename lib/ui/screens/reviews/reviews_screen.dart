import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/models/review.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/review_service.dart';
import '../../common/app_drawer.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  // Format for dates
  final dateFormat = DateFormat('MMM d, yyyy');
  
  @override
  void initState() {
    super.initState();
    // Load reviews when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReviewService>(context, listen: false).getReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final reviewService = Provider.of<ReviewService>(context);
    final isAdmin = authService.hasRole(UserRole.admin);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
      drawer: const AppDrawer(currentRoute: '/reviews'),
      body: reviewService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reviewService.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error Loading Reviews',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reviewService.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          reviewService.getReviews();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : reviewService.reviews.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Reviews Yet',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Customer reviews will appear here',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: reviewService.reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviewService.reviews[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  child: Text(
                                    review.rating.toString(),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  review.customerName ?? 'Customer #${review.customerId}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: review.datetime != null
                                    ? Text(dateFormat.format(review.datetime!))
                                    : null,
                                trailing: isAdmin
                                    ? IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        tooltip: 'Delete Review',
                                        onPressed: () {
                                          _showDeleteConfirmation(context, review);
                                        },
                                      )
                                    : null,
                              ),
                              if (review.comment != null && review.comment!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Text(
                                    review.comment!,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Row(
                                  children: [
                                    ...List.generate(
                                      5,
                                      (starIndex) => Icon(
                                        starIndex < review.rating 
                                            ? Icons.star 
                                            : Icons.star_border,
                                        color: starIndex < review.rating 
                                            ? Colors.amber 
                                            : Colors.grey,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: Text(
          'Are you sure you want to delete this review from ${review.customerName ?? 'Customer #${review.customerId}'}?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final reviewService = Provider.of<ReviewService>(context, listen: false);
              await reviewService.deleteReview(review.id!);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
} 