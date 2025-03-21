import 'package:flutter/material.dart';
import '../../core/models/customer_location.dart';

class LocationCard extends StatelessWidget {
  final CustomerLocation location;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  const LocationCard({
    Key? key,
    required this.location,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final propertyTypeStr = location.propertyType == PropertyType.business 
        ? 'Business' 
        : 'Residential';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with property type and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: location.propertyType == PropertyType.business 
                        ? Colors.blueGrey[100] 
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    propertyTypeStr,
                    style: TextStyle(
                      color: location.propertyType == PropertyType.business 
                          ? Colors.blueGrey[800] 
                          : Colors.green[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (onEdit != null || onDelete != null)
                  Row(
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.blue,
                          onPressed: onEdit,
                          tooltip: 'Edit Location',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: onDelete,
                          tooltip: 'Delete Location',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Address
            if (location.address != null && location.address!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      location.address!,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            // Point of Contact
            if (location.pointOfContact != null && location.pointOfContact!.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.person, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    location.pointOfContact!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            // Property details row
            if (location.approxAcres != null) ...[
              Row(
                children: [
                  const Icon(Icons.crop_square, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Approx. ${location.approxAcres!.toStringAsFixed(2)} acres',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            // Notes
            if (location.notes != null && location.notes!.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                location.notes!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 