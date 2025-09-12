import 'package:flutter/material.dart';
import '../services/shipping_calculator.dart';

/// Widget para mostrar información de peso y envío
class WeightShippingDisplay extends StatelessWidget {
  final double weightLb; // Peso en libras
  final String? originalWeight;
  final String? destination;
  final String? shippingType;
  final String? vendorId;
  final bool showShippingCost;
  final VoidCallback? onTap;
  
  const WeightShippingDisplay({
    super.key,
    required this.weightLb,
    this.originalWeight,
    this.destination,
    this.shippingType,
    this.vendorId,
    this.showShippingCost = false,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final weightCategory = _getWeightCategory(weightLb);
    final color = _getWeightColor(weightCategory);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.scale,
              size: 16,
              color: color,
            ),
            SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${weightLb.toStringAsFixed(1)} lb',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (originalWeight != null && originalWeight != weightLb.toString())
                  Text(
                    '($originalWeight)',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                if (showShippingCost && destination != null)
                  _buildShippingCost(context),
                if (showShippingCost)
                  _buildMaletinesInfo(context),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShippingCost(BuildContext context) {
    final calculation = ShippingCalculator.calculateShipping(
      weightLb: weightLb,
      destination: destination!,
      shippingType: shippingType ?? 'express',
      vendorId: vendorId,
    );
    
    if (!calculation.isValid) {
      return Text(
        'No disponible',
        style: TextStyle(
          fontSize: 10,
          color: Colors.red,
        ),
      );
    }
    
    return Text(
      'Envío: ${calculation.formattedCost}',
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey[600],
      ),
    );
  }
  
  Widget _buildMaletinesInfo(BuildContext context) {
    final calculation = ShippingCalculator.calculateShipping(
      weightLb: weightLb,
      destination: destination ?? 'cuba',
      shippingType: shippingType ?? 'express',
      vendorId: vendorId,
    );
    
    if (!calculation.isValid) {
      return SizedBox.shrink();
    }
    
    return Text(
      calculation.maletinesInfo,
      style: TextStyle(
        fontSize: 9,
        color: Colors.blue[600],
        fontWeight: FontWeight.w500,
      ),
    );
  }
  
  WeightCategory _getWeightCategory(double weightLb) {
    if (weightLb <= 1.0) return WeightCategory.light;      // < 1 lb
    if (weightLb <= 10.0) return WeightCategory.medium;    // 1-10 lb
    if (weightLb <= 30.0) return WeightCategory.heavy;     // 10-30 lb
    if (weightLb <= 70.0) return WeightCategory.oversized; // 30-70 lb
    return WeightCategory.freight;                         // > 70 lb
  }
  
  Color _getWeightColor(WeightCategory category) {
    switch (category) {
      case WeightCategory.light:
        return Colors.green;
      case WeightCategory.medium:
        return Colors.blue;
      case WeightCategory.heavy:
        return Colors.orange;
      case WeightCategory.oversized:
        return Colors.red;
      case WeightCategory.freight:
        return Colors.purple;
    }
  }
}

/// Widget para mostrar información detallada de envío
class ShippingDetailsCard extends StatelessWidget {
  final ShippingCalculation calculation;
  final String destination;
  final VoidCallback? onEditDestination;
  final VoidCallback? onEditShippingType;
  
  const ShippingDetailsCard({
    super.key,
    required this.calculation,
    required this.destination,
    this.onEditDestination,
    this.onEditShippingType,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Detalles de Envío',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Información de peso
            _buildInfoRow(
              'Categoría de Peso',
              calculation.weightCategoryDescription,
              Icons.scale,
            ),
            
            // Tipo de envío
            _buildInfoRow(
              'Tipo de Envío',
              calculation.shippingTypeDescription,
              Icons.delivery_dining,
              onTap: onEditShippingType,
            ),
            
            // Destino
            _buildInfoRow(
              'Destino',
              destination,
              Icons.location_on,
              onTap: onEditDestination,
            ),
            
            // Tiempo estimado
            _buildInfoRow(
              'Tiempo Estimado',
              calculation.formattedDays,
              Icons.schedule,
            ),
            
            // Información detallada de tiempos
            if (calculation.detailedDeliveryInfo.isNotEmpty)
              _buildInfoRow(
                'Detalle de Tiempos',
                calculation.detailedDeliveryInfo,
                Icons.info_outline,
              ),
            
            // Información de maletines
            if (calculation.maletinesInfo.isNotEmpty)
              _buildInfoRow(
                'Método de Envío',
                calculation.maletinesInfo,
                Icons.local_shipping,
              ),
            
            // Costo de envío
            _buildInfoRow(
              'Costo de Envío',
              calculation.formattedCost,
              Icons.attach_money,
              isHighlighted: true,
            ),
            
            // Descuento por volumen
            if (calculation.volumeDiscount != null && calculation.volumeDiscount! > 0)
              _buildInfoRow(
                'Descuento por Volumen',
                '${(calculation.volumeDiscount! * 100).toStringAsFixed(0)}%',
                Icons.discount,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
    bool isHighlighted = false,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? Colors.grey[600],
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? Colors.blue : Colors.black,
              ),
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.edit,
              size: 16,
              color: Colors.grey[400],
            ),
        ],
      ),
    );
  }
}

/// Widget para mostrar selector de tipo de envío
class ShippingTypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onChanged;
  final double weightKg;
  
  const ShippingTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
    required this.weightKg,
  });
  
  @override
  Widget build(BuildContext context) {
    final availableTypes = _getAvailableShippingTypes(weightKg);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Envío',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ...availableTypes.map((type) => _buildShippingTypeOption(type)),
      ],
    );
  }
  
  Widget _buildShippingTypeOption(String type) {
    final isSelected = selectedType == type;
    final info = _getShippingTypeInfo(type);
    
    return GestureDetector(
      onTap: () => onChanged(type),
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              info.icon,
              color: isSelected ? Colors.blue : Colors.grey[600],
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blue : Colors.black,
                    ),
                  ),
                  Text(
                    info.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.blue,
              ),
          ],
        ),
      ),
    );
  }
  
  List<String> _getAvailableShippingTypes(double weightLb) {
    final types = <String>[];
    
    // Si el peso es <= 70lb, puede ser express
    if (weightLb <= 70.0) {
      types.add('express');
    }
    
    // Si el peso es > 70lb, solo marítimo
    if (weightLb > 70.0) {
      types.add('maritime');
    }
    
    return types;
  }
  
  ShippingTypeInfo _getShippingTypeInfo(String type) {
    switch (type) {
      case 'express':
        return ShippingTypeInfo(
          name: 'Envío Express',
          description: '3-8 días • Más rápido',
          icon: Icons.flash_on,
        );
      case 'standard':
        return ShippingTypeInfo(
          name: 'Envío Estándar',
          description: '7-15 días • Económico',
          icon: Icons.local_shipping,
        );
      case 'freight':
        return ShippingTypeInfo(
          name: 'Envío de Carga',
          description: '15-30 días • Productos pesados',
          icon: Icons.local_shipping,
        );
      default:
        return ShippingTypeInfo(
          name: 'Envío Estándar',
          description: '7-15 días',
          icon: Icons.local_shipping,
        );
    }
  }
}

class ShippingTypeInfo {
  final String name;
  final String description;
  final IconData icon;
  
  const ShippingTypeInfo({
    required this.name,
    required this.description,
    required this.icon,
  });
}
