import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cubalink23/services/user_role_service.dart';

class VendorProductsScreen extends StatefulWidget {
  const VendorProductsScreen({Key? key}) : super(key: key);

  @override
  _VendorProductsScreenState createState() => _VendorProductsScreenState();
}

class _VendorProductsScreenState extends State<VendorProductsScreen> with SingleTickerProviderStateMixin {
  final UserRoleService _roleService = UserRoleService();
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  
  List<Map<String, dynamic>> _myProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMyProducts();
  }

  Future<void> _loadMyProducts() async {
    setState(() => _isLoading = true);
    
    try {
      // Simular productos del vendedor actual
      // En producción, esto vendría de Supabase filtrando por vendor_id
      await Future.delayed(Duration(seconds: 1));
      
      setState(() {
        _myProducts = [
          {
            'id': '1',
            'name': 'Pizza Margherita',
            'description': 'Pizza tradicional italiana con tomate, mozzarella y albahaca fresca',
            'price': 12.00,
            'category': 'Comida',
            'subcategory': 'Pizza',
            'images': [],
            'stock': 25,
            'available': true,
            'delivery_config': 'system', // 'own' o 'system'
            'preparation_time': 15,
            'created_at': DateTime.now().subtract(Duration(days: 5)),
          },
          {
            'id': '2',
            'name': 'Hamburguesa Clásica',
            'description': 'Hamburguesa de carne con lechuga, tomate, cebolla y salsa especial',
            'price': 15.00,
            'category': 'Comida',
            'subcategory': 'Hamburguesas',
            'images': [],
            'stock': 30,
            'available': true,
            'delivery_config': 'own', // Vendedor entrega él mismo
            'preparation_time': 10,
            'created_at': DateTime.now().subtract(Duration(days: 3)),
          },
          {
            'id': '3',
            'name': 'Ensalada César',
            'description': 'Ensalada fresca con lechuga, pollo, crutones y aderezo César',
            'price': 8.50,
            'category': 'Comida',
            'subcategory': 'Ensaladas',
            'images': [],
            'stock': 0,
            'available': false,
            'delivery_config': 'system',
            'preparation_time': 5,
            'created_at': DateTime.now().subtract(Duration(days: 1)),
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando productos: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Color(0xFF2E7D32),
        title: Text(
          'Mis Productos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadMyProducts,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: 'Mis Productos',
              icon: Icon(Icons.inventory, size: 20),
            ),
            Tab(
              text: 'Agregar Nuevo',
              icon: Icon(Icons.add_box, size: 20),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyProductsList(),
          _buildAddProductForm(),
        ],
      ),
    );
  }

  Widget _buildMyProductsList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2E7D32),
        ),
      );
    }

    if (_myProducts.isEmpty) {
      return _buildEmptyProductsState();
    }

    return RefreshIndicator(
      onRefresh: _loadMyProducts,
      color: Color(0xFF2E7D32),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _myProducts.length,
        itemBuilder: (context, index) {
          final product = _myProducts[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildEmptyProductsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No tienes productos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Agrega tu primer producto usando la pestaña "Agregar Nuevo"',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _tabController.animateTo(1),
            icon: Icon(Icons.add),
            label: Text('Agregar Producto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final isAvailable = product['available'] as bool;
    final stock = product['stock'] as int;
    final deliveryConfig = product['delivery_config'] as String;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: Colors.grey[600],
                    size: 30,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        '${product['category']} - ${product['subcategory']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: deliveryConfig == 'own' ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              deliveryConfig == 'own' ? 'ENTREGA PROPIA' : 'ENTREGA SISTEMA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: deliveryConfig == 'own' ? Colors.blue : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${product['price'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    ),
                    Text(
                      'Stock: $stock',
                      style: TextStyle(
                        fontSize: 12,
                        color: stock > 0 ? Colors.green[600] : Colors.red[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Description and Details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Text(
                      'Tiempo de preparación: ${product['preparation_time']} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editProduct(product),
                        icon: Icon(Icons.edit, size: 18),
                        label: Text('Editar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFF2E7D32),
                          side: BorderSide(color: Color(0xFF2E7D32)),
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleProductAvailability(product),
                        icon: Icon(
                          isAvailable ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                        ),
                        label: Text(isAvailable ? 'Desactivar' : 'Activar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAvailable ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.add_box,
                      color: Color(0xFF2E7D32),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Agregar Nuevo Producto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                
                // Imagen del producto
                _buildImageUploadSection(),
                
                SizedBox(height: 20),
                
                // Información básica
                _buildBasicInfoSection(),
                
                SizedBox(height: 20),
                
                // Configuración de entrega
                _buildDeliveryConfigSection(),
                
                SizedBox(height: 24),
                
                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveNewProduct,
                    icon: Icon(Icons.save),
                    label: Text('Guardar Producto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen del Producto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: _pickProductImage,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: Colors.grey[600],
                ),
                SizedBox(height: 8),
                Text(
                  'Toca para agregar imagen',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Nombre del Producto',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Descripción',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 3,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Precio',
                  prefixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Stock',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Tiempo de Preparación (minutos)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildDeliveryConfigSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración de Entrega',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              RadioListTile<String>(
                title: Text('Entrega por el Sistema'),
                subtitle: Text('Un repartidor recogerá y entregará el pedido'),
                value: 'system',
                groupValue: 'system',
                onChanged: (value) {},
                activeColor: Color(0xFF2E7D32),
              ),
              RadioListTile<String>(
                title: Text('Entrega Propia'),
                subtitle: Text('Yo entregaré el pedido directamente'),
                value: 'own',
                groupValue: 'system',
                onChanged: (value) {},
                activeColor: Color(0xFF2E7D32),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editProduct(Map<String, dynamic> product) {
    // TODO: Implementar edición de producto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editando producto: ${product['name']}'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  void _toggleProductAvailability(Map<String, dynamic> product) {
    setState(() {
      product['available'] = !product['available'];
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          product['available'] 
            ? 'Producto activado: ${product['name']}'
            : 'Producto desactivado: ${product['name']}'
        ),
        backgroundColor: product['available'] ? Colors.green : Colors.red,
      ),
    );
  }

  void _pickProductImage() async {
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Agregar imagen del producto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Color(0xFF2E7D32)),
              title: Text('Tomar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Color(0xFF2E7D32)),
              title: Text('Elegir de galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final image = await _picker.pickImage(source: result);
      if (image != null) {
        // TODO: Procesar imagen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imagen seleccionada'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    }
  }

  void _saveNewProduct() {
    // TODO: Implementar guardar producto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funcionalidad próximamente'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}