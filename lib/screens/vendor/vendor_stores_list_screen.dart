import 'package:flutter/material.dart';
import 'package:cubalink23/models/vendor_store.dart';
import 'package:cubalink23/services/vendor_store_service.dart';
import 'package:cubalink23/screens/vendor/vendor_store_screen.dart';

class VendorStoresListScreen extends StatefulWidget {
  @override
  _VendorStoresListScreenState createState() => _VendorStoresListScreenState();
}

class _VendorStoresListScreenState extends State<VendorStoresListScreen> {
  final VendorStoreService _vendorStoreService = VendorStoreService();
  List<VendorStore> _stores = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadVendorStores();
  }

  Future<void> _loadVendorStores() async {
    try {
      setState(() {
        _isLoading = true;
      });

      _stores = await _vendorStoreService.getAllVendorStores();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando tiendas: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchStores(String query) async {
    if (query.isEmpty) {
      _loadVendorStores();
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      _stores = await _vendorStoreService.searchVendorStores(query);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error buscando tiendas: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToStore(VendorStore store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorStoreScreen(
          vendorId: store.id,
          vendorName: store.name,
          vendorImage: store.imageUrl,
          rating: store.rating,
          deliveryTime: store.deliveryTime,
          deliveryCost: store.deliveryCost,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Tiendas de Vendedores',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _searchStores(value);
              },
              decoration: InputDecoration(
                hintText: 'Buscar tiendas...',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _stores.isEmpty
              ? _buildEmptyState()
              : _buildStoresList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty 
                ? 'No hay tiendas disponibles'
                : 'No se encontraron tiendas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Los vendedores aún no han creado sus tiendas'
                : 'Intenta con otro término de búsqueda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
                _loadVendorStores();
              },
              child: Text('Ver todas las tiendas'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStoresList() {
    return RefreshIndicator(
      onRefresh: _loadVendorStores,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _stores.length,
        itemBuilder: (context, index) {
          final store = _stores[index];
          return _buildStoreCard(store);
        },
      ),
    );
  }

  Widget _buildStoreCard(VendorStore store) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToStore(store),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Imagen de la tienda
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 80,
                    child: store.imageUrl.isNotEmpty
                        ? Image.network(
                            store.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildStorePlaceholder(),
                          )
                        : _buildStorePlaceholder(),
                  ),
                ),
                SizedBox(width: 16),
                
                // Información de la tienda
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        store.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            store.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '(${store.reviewCount} reseñas)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.grey.shade600, size: 14),
                          SizedBox(width: 4),
                          Text(
                            store.deliveryTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.local_shipping, color: Colors.grey.shade600, size: 14),
                          SizedBox(width: 4),
                          Text(
                            '\$${store.deliveryCost.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Flecha de navegación
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStorePlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store,
            size: 32,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 4),
          Text(
            'CubaLink23',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
