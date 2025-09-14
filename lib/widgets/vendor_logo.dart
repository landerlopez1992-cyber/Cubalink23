import 'package:flutter/material.dart';

/// Widget para mostrar el logo del vendedor en la esquina de las tarjetas de productos
class VendorLogo extends StatelessWidget {
  final String? vendorId;
  final double size;
  final EdgeInsets padding;
  
  const VendorLogo({
    super.key,
    this.vendorId,
    this.size = 24.0,
    this.padding = const EdgeInsets.all(4.0),
  });
  
  @override
  Widget build(BuildContext context) {
    if (vendorId == null || vendorId!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final vendorInfo = _getVendorInfo(vendorId!);
    if (vendorInfo == null) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: vendorInfo.color,
          borderRadius: BorderRadius.circular(size / 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: vendorInfo.icon,
      ),
    );
  }
  
  VendorInfo? _getVendorInfo(String vendorId) {
    switch (vendorId.toLowerCase()) {
      case 'amazon':
        return VendorInfo(
          icon: const Text(
            'a',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          color: const Color(0xFFFF9900), // Amazon orange
          name: 'Amazon',
        );
      case 'walmart':
        return VendorInfo(
          icon: const Icon(
            Icons.shopping_cart,
            color: Colors.white,
            size: 16,
          ),
          color: const Color(0xFF004C91), // Walmart blue
          name: 'Walmart',
        );
      case 'ebay':
        return VendorInfo(
          icon: const Text(
            'e',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          color: const Color(0xFFE53238), // eBay red
          name: 'eBay',
        );
      case 'admin':
      case 'system':
        return VendorInfo(
          icon: const Icon(
            Icons.store,
            color: Colors.white,
            size: 16,
          ),
          color: const Color(0xFF28A745), // Green for store
          name: 'Tienda',
        );
      default:
        // Para vendedores específicos
        if (vendorId.startsWith('vendor_')) {
          return VendorInfo(
            icon: const Icon(
              Icons.person,
              color: Colors.white,
              size: 16,
            ),
            color: const Color(0xFFFFC107), // Yellow for vendors
            name: 'Vendedor',
          );
        }
        return null;
    }
  }
}

/// Información del vendedor
class VendorInfo {
  final Widget icon;
  final Color color;
  final String name;
  
  const VendorInfo({
    required this.icon,
    required this.color,
    required this.name,
  });
}

/// Widget para mostrar el logo del vendedor en el carrito de compras
class CartVendorLogo extends StatelessWidget {
  final String? vendorId;
  final double size;
  
  const CartVendorLogo({
    super.key,
    this.vendorId,
    this.size = 20.0,
  });
  
  @override
  Widget build(BuildContext context) {
    if (vendorId == null || vendorId!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final vendorInfo = _getVendorInfo(vendorId!);
    if (vendorInfo == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: vendorInfo.color,
        borderRadius: BorderRadius.circular(size / 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: vendorInfo.icon,
      ),
    );
  }
  
  VendorInfo? _getVendorInfo(String vendorId) {
    switch (vendorId.toLowerCase()) {
      case 'amazon':
        return VendorInfo(
          icon: const Text(
            'a',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          color: const Color(0xFFFF9900),
          name: 'Amazon',
        );
      case 'walmart':
        return VendorInfo(
          icon: const Icon(
            Icons.shopping_cart,
            color: Colors.white,
            size: 14,
          ),
          color: const Color(0xFF004C91),
          name: 'Walmart',
        );
      case 'ebay':
        return VendorInfo(
          icon: const Text(
            'e',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          color: const Color(0xFFE53238),
          name: 'eBay',
        );
      case 'admin':
      case 'system':
        return VendorInfo(
          icon: const Icon(
            Icons.store,
            color: Colors.white,
            size: 14,
          ),
          color: const Color(0xFF28A745),
          name: 'Tienda',
        );
      default:
        if (vendorId.startsWith('vendor_')) {
          return VendorInfo(
            icon: const Icon(
              Icons.person,
              color: Colors.white,
              size: 14,
            ),
            color: const Color(0xFFFFC107),
            name: 'Vendedor',
          );
        }
        return null;
    }
  }
}

/// Widget para mostrar información del vendedor en texto
class VendorName extends StatelessWidget {
  final String? vendorId;
  final TextStyle? style;
  
  const VendorName({
    super.key,
    this.vendorId,
    this.style,
  });
  
  @override
  Widget build(BuildContext context) {
    if (vendorId == null || vendorId!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final vendorName = _getVendorName(vendorId!);
    if (vendorName == null) {
      return const SizedBox.shrink();
    }
    
    return Text(
      vendorName,
      style: style ?? TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
    );
  }
  
  String? _getVendorName(String vendorId) {
    switch (vendorId.toLowerCase()) {
      case 'amazon':
        return 'Amazon';
      case 'walmart':
        return 'Walmart';
      case 'ebay':
        return 'eBay';
      case 'admin':
      case 'system':
        return 'Tienda Cubalink23';
      default:
        if (vendorId.startsWith('vendor_')) {
          return 'Vendedor';
        }
        return null;
    }
  }
}
