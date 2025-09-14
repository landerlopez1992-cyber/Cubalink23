import 'package:flutter/material.dart';
import '../models/order_status.dart';
import '../services/delivery_detection_service.dart';

/// Widget para mostrar alerta de diferencias de entrega
class DeliveryDifferenceAlert extends StatelessWidget {
  final DeliveryDetectionResult detectionResult;
  final VoidCallback onContinue;
  final VoidCallback onRemoveProducts;
  final VoidCallback onReviewDetails;
  
  const DeliveryDifferenceAlert({
    super.key,
    required this.detectionResult,
    required this.onContinue,
    required this.onRemoveProducts,
    required this.onReviewDetails,
  });
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 28),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Diferencias de Entrega',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sus productos tienen diferentes tiempos de entrega:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            
            // Mostrar información de entrega por vendedor
            ...detectionResult.deliveryInfos.map((info) => _buildDeliveryInfoCard(info)),
            
            SizedBox(height: 16),
            
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange[700], size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Recomendación',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Para evitar retrasos, recomendamos separar estos productos en pedidos diferentes.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onRemoveProducts,
          child: Text('Remover Productos'),
        ),
        TextButton(
          onPressed: onReviewDetails,
          child: Text('Revisar Detalles'),
        ),
        ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[600],
            foregroundColor: Colors.white,
          ),
          child: Text('Continuar'),
        ),
      ],
    );
  }
  
  Widget _buildDeliveryInfoCard(DeliveryInfo info) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getVendorColor(info.vendorId),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getVendorIcon(info.vendorId),
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.vendorName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  '${info.estimatedDays} días estimados',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getVendorColor(String vendorId) {
    switch (vendorId.toLowerCase()) {
      case 'amazon':
        return Color(0xFFFF9900);
      case 'walmart':
        return Color(0xFF004C91);
      case 'ebay':
        return Color(0xFF0064D2);
      case 'homedepot':
      case 'home_depot':
        return Color(0xFFF96302);
      case 'shein':
        return Color(0xFFFF6B35);
      default:
        return Colors.grey[600]!;
    }
  }
  
  IconData _getVendorIcon(String vendorId) {
    switch (vendorId.toLowerCase()) {
      case 'amazon':
        return Icons.shopping_cart;
      case 'walmart':
        return Icons.store;
      case 'ebay':
        return Icons.sell;
      case 'homedepot':
      case 'home_depot':
        return Icons.home_repair_service;
      case 'shein':
        return Icons.checkroom;
      default:
        return Icons.storefront;
    }
  }
}