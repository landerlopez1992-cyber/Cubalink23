import 'package:flutter/material.dart';
import 'package:cubalink23/screens/payment/payment_method_screen.dart';
import 'package:cubalink23/models/recharge_history.dart';
import 'package:cubalink23/models/operator.dart';
import 'package:cubalink23/models/user.dart';
import 'package:cubalink23/services/ding_connect_service.dart';

class RechargeHomeScreen extends StatefulWidget {
  const RechargeHomeScreen({super.key});

  @override
  _RechargeHomeScreenState createState() => _RechargeHomeScreenState();
}

class _RechargeHomeScreenState extends State<RechargeHomeScreen> {
  final TextEditingController _phoneController1 = TextEditingController();
  final TextEditingController _phoneController2 = TextEditingController();
  String? _selectedCountry = 'CU'; // Default to Cuba
  Map<String, dynamic>? _selectedProduct;

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _cubaOffers = [];
  bool _isLoadingProducts = false;
  bool _isLoadingOffers = true;
  bool _isValidatingNumber = false;
  bool _isPhoneValid = false;
  String? _validationMessage;
  Map<String, dynamic>? _lastOrder;

  final Map<String, String> _countries = {
    'CU': '🇨🇺 Cuba',
    'US': '🇺🇸 Estados Unidos',
    'MX': '🇲🇽 México',
    'ES': '🇪🇸 España',
    'CO': '🇨🇴 Colombia',
    'VE': '🇻🇪 Venezuela',
    'AR': '🇦🇷 Argentina',
    'PE': '🇵🇪 Perú',
  };

  @override
  void initState() {
    super.initState();
    _testApiAndLoadData();
  }

  /// Verificar API y cargar datos
  Future<void> _testApiAndLoadData() async {
    try {
      print('🧪 Iniciando verificación de API DingConnect...');
      
      // Verificar conectividad de API
      final isConnected = await DingConnectService.instance.testApiConnection();
      print('🧪 API Conectada: $isConnected');
      
      if (isConnected) {
        // Cargar datos reales de la API
        await _loadCubaOffers();
        await _loadProductsForCountry(_selectedCountry!);
      } else {
        print('❌ No se pudo conectar a DingConnect API');
        
        if (mounted) {
          // Mostrar mensaje de error al usuario
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '❌ Error: No se puede conectar a DingConnect API. Verifica tu conexión a internet o contacta soporte.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red[600],
              duration: Duration(seconds: 10),
              action: SnackBarAction(
                label: 'Reintentar',
                textColor: Colors.white,
                onPressed: () => _testApiAndLoadData(),
              ),
            ),
          );
        }
        
        // Limpiar listas y mostrar estado vacío
        setState(() {
          _cubaOffers = [];
          _products = [];
          _isLoadingOffers = false;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      print('❌ Error en inicialización: $e');
      
      // En caso de error, limpiar y mostrar error
      setState(() {
        _cubaOffers = [];
        _products = [];
        _isLoadingOffers = false;
        _isLoadingProducts = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error de conexión: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () => _testApiAndLoadData(),
            ),
          ),
        );
      }
    }
  }


  /// Cargar ofertas específicas para Cuba desde DingConnect
  Future<void> _loadCubaOffers() async {
    try {
      print('🇨🇺 Cargando ofertas especiales para Cuba...');
      setState(() => _isLoadingOffers = true);

      final products = await DingConnectService.instance.getCubaProducts();

      // Formatear productos para mostrar como ofertas
      final offers = products.take(6).map((product) {
        return DingConnectService.formatProductForUI(product);
      }).toList();

      if (mounted) {
        setState(() {
          _cubaOffers = offers;
          _isLoadingOffers = false;
        });
        print('✅ Cargadas ${offers.length} ofertas para Cuba');
      }
    } catch (e) {
      print('❌ Error cargando ofertas de Cuba: $e');
      if (mounted) {
        setState(() => _isLoadingOffers = false);
      }
    }
  }

  /// Cargar productos disponibles para un país
  Future<void> _loadProductsForCountry(String countryCode) async {
    try {
      print('🌍 Cargando productos para $countryCode...');
      setState(() => _isLoadingProducts = true);

      final products = await DingConnectService.instance.getProducts(
        countryCode: countryCode,
      );

      // Formatear productos para el selector
      final formattedProducts = products.map((product) {
        return DingConnectService.formatProductForUI(product);
      }).toList();

      if (mounted) {
        setState(() {
          _products = formattedProducts;
          _selectedProduct = null; // Reset selection
          _isLoadingProducts = false;
        });
        print(
            '✅ Cargados ${formattedProducts.length} productos para $countryCode');
      }
    } catch (e) {
      print('❌ Error cargando productos para $countryCode: $e');
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  void _selectFromContacts() {
    // Simular selección de contactos (aquí iría la integración real con contactos)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Acceso a Contactos'),
        content: Text(
            'Función de contactos se integrará con los permisos del dispositivo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCountrySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Selecciona un país',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 15),
            ...(_countries.entries
                .map((entry) => ListTile(
                      title: Text(entry.value),
                      onTap: () {
                        setState(() {
                          _selectedCountry = entry.key;
                        });
                        Navigator.pop(context);
                        _loadProductsForCountry(entry.key);
                      },
                    ))
                .toList()),
          ],
        ),
      ),
    );
  }

  void _showProductSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Selecciona un producto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 15),
            if (_isLoadingProducts)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_products.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No hay productos disponibles para este país',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: _products
                        .map((product) => _buildProductOption(product))
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductOption(Map<String, dynamic> product) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: Colors.grey.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity( 0.1),
          child: Text(
            product['title'].toString().substring(0, 1),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          product['title'],
          style: TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          product['description'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${product['price'].toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (product['discount'] != null && product['discount'] > 0)
              Text(
                '-${product['discount']}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        onTap: () {
          setState(() {
            _selectedProduct = product;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity( 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con descuento
            if (offer['discount'] != null && offer['discount'] > 0)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 4),
                color: Colors.red,
                child: Text(
                  '-${offer['discount']}% OFF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Contenido de la oferta
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    offer['title'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 6),

                  // Descripción
                  Text(
                    offer['description'],
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 8),

                  // Precios
                  Row(
                    children: [
                      if (offer['originalPrice'] != null &&
                          offer['originalPrice'] > offer['price'])
                        Text(
                          '\$${offer['originalPrice'].toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      SizedBox(width: 4),
                      Text(
                        '\$${offer['price'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nueva Recarga',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de ofertas especiales para Cuba
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity( 0.1),
                    Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity( 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity( 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('🇨🇺', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ofertas Especiales para Cuba',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
  // Botones de acción
                      Row(
                        children: [
                          // Botón de balance de cuenta
                          IconButton(
                            onPressed: () => _checkAccountBalance(),
                            icon: Icon(
                              Icons.account_balance_wallet,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            tooltip: 'Ver balance DingConnect',
                          ),
                          // Botón de refrescar
                          IconButton(
                            onPressed: () => _testApiAndLoadData(),
                            icon: Icon(
                              Icons.refresh,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            tooltip: 'Refrescar ofertas',
                          ),
                          // Botón de consultar orden
                          IconButton(
                            onPressed: () => _showOrderStatusDialog(),
                            icon: Icon(
                              Icons.search,
                              color: Colors.orange,
                            ),
                            tooltip: 'Consultar estado de orden',
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Powered by LandGo Travel - Reacargas Telefonicas',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: _isLoadingOffers
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                                Text(
                                  'Cargando ofertas reales...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _cubaOffers.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.wifi_off,
                                      color: Colors.grey[400],
                                      size: 32,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'No hay ofertas disponibles',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Verifica tu conexión a internet',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _cubaOffers.length,
                                itemBuilder: (context, index) {
                                  final offer = _cubaOffers[index];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedProduct = offer;
                                        _selectedCountry = 'CU';
                                        _phoneController1.text = '';
                                        _phoneController2.text = '';
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '✅ Oferta seleccionada: ${offer['title']}',
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: _buildOfferCard(offer),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),

            // Botón para seleccionar de contactos
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _selectFromContacts,
                icon: Icon(Icons.contacts,
                    color: Theme.of(context).colorScheme.onPrimary),
                label: Text(
                  'Seleccionar de Contactos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            SizedBox(height: 30),

            // Texto separador
            Center(
              child: Text(
                'O ingresa manualmente',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            SizedBox(height: 25),

            // Selector de país
            Text(
              'País de destino',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _showCountrySelector,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Icon(Icons.public,
                        color: Theme.of(context).colorScheme.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _countries[_selectedCountry] ?? 'Selecciona un país',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down,
                        color: Colors.grey.shade500),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Primer campo de teléfono
            Text(
              'Número de teléfono',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _phoneController1,
              keyboardType: TextInputType.phone,
              onChanged: (value) => _validatePhoneNumber(value),
              decoration: InputDecoration(
                hintText: 'Ej: 53123456789',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: _isValidatingNumber 
                  ? Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Icon(
                      _isPhoneValid ? Icons.phone : Icons.phone,
                      color: _isPhoneValid ? Colors.green : Theme.of(context).colorScheme.primary,
                    ),
                suffixIcon: _phoneController1.text.isNotEmpty
                  ? Icon(
                      _isPhoneValid ? Icons.check_circle : Icons.error,
                      color: _isPhoneValid ? Colors.green : Colors.red,
                    )
                  : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _isPhoneValid ? Colors.green : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _isPhoneValid ? Colors.green : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: _isPhoneValid ? Colors.green : Theme.of(context).colorScheme.primary, 
                      width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              ),
            ),
            
            // Mensaje de validación
            if (_validationMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 8, left: 4),
                child: Row(
                  children: [
                    Icon(
                      _isPhoneValid ? Icons.check_circle : Icons.error,
                      size: 16,
                      color: _isPhoneValid ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _validationMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _isPhoneValid ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 20),

            // Segundo campo de teléfono (confirmación)
            Text(
              'Confirmar número de teléfono',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _phoneController2,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Confirma el número',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.phone_callback,
                    color: Theme.of(context).colorScheme.secondary),
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
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              ),
            ),

            SizedBox(height: 30),

            // Selector de producto/paquete
            Text(
              'Producto de recarga',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _showProductSelector,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedProduct != null
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity( 0.5)
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _selectedProduct != null
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity( 0.05)
                      : Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Icon(
                      _isLoadingProducts
                          ? Icons.hourglass_empty
                          : Icons.card_giftcard,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _isLoadingProducts
                          ? Text(
                              'Cargando productos...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade400,
                              ),
                            )
                          : Text(
                              _selectedProduct != null
                                  ? _selectedProduct!['title']
                                  : 'Selecciona un producto',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedProduct != null
                                    ? Colors.black87
                                    : Colors.grey.shade400,
                                fontWeight: _selectedProduct != null
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                    ),
                    Icon(Icons.keyboard_arrow_down,
                        color: Colors.grey.shade500),
                  ],
                ),
              ),
            ),

            // Mostrar detalles del producto seleccionado
            if (_selectedProduct != null) ...[
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity( 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity( 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Producto seleccionado:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_selectedProduct!['discount'] != null &&
                            _selectedProduct!['discount'] > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${_selectedProduct!['discount']}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      _selectedProduct!['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        if (_selectedProduct!['originalPrice'] != null &&
                            _selectedProduct!['originalPrice'] >
                                _selectedProduct!['price'])
                          Text(
                            '\$${_selectedProduct!['originalPrice'].toStringAsFixed(2)} ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          '\$${_selectedProduct!['price'].toStringAsFixed(2)} USD',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 40),

            // Botón de continuar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (_phoneController1.text.isNotEmpty &&
                        _phoneController2.text.isNotEmpty &&
                        _phoneController1.text == _phoneController2.text &&
                        _selectedProduct != null &&
                        _selectedCountry != null &&
                        _isPhoneValid &&
                        !_isValidatingNumber)
                    ? () {
                        _proceedToPayment();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Continuar con Recarga Real',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Nota informativa
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity( 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity( 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Los números deben coincidir para confirmar la recarga. Asegúrate de verificar el número antes de continuar.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.verified, color: Colors.green, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }

  /// Validar número de teléfono usando DingConnect API
  Future<void> _validatePhoneNumber(String phoneNumber) async {
    if (phoneNumber.length < 8) {
      setState(() {
        _isPhoneValid = false;
        _validationMessage = null;
        _isValidatingNumber = false;
      });
      return;
    }
    
    setState(() {
      _isValidatingNumber = true;
      _validationMessage = 'Validando número...';
    });
    
    try {
      final result = await DingConnectService.instance.validatePhoneNumber(
        phoneNumber, 
        _selectedCountry ?? 'CU'
      );
      
      if (mounted) {
        setState(() {
          _isValidatingNumber = false;
          if (result != null && result['isValid'] == true) {
            _isPhoneValid = true;
            _validationMessage = '✅ Número válido para ${result['provider']}';
          } else {
            _isPhoneValid = false;
            _validationMessage = '❌ ${result?['error'] ?? 'Número no válido'}';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidatingNumber = false;
          _isPhoneValid = false;
          _validationMessage = '❌ Error validando número';
        });
      }
    }
  }
  
  /// Verificar estado de una orden
  Future<void> _checkOrderStatus(String orderId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('🔍 Verificando Orden'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Consultando estado de la orden...'),
          ],
        ),
      ),
    );
    
    try {
      final result = await DingConnectService.instance.getOrderStatus(orderId);
      
      Navigator.pop(context); // Cerrar dialog de loading
      
      if (result != null && result['success'] == true) {
        final status = result['status'];
        String statusMessage = '';
        Color statusColor = Colors.blue;
        
        switch (status) {
          case 'SUCCESS':
            statusMessage = '✅ Recarga completada exitosamente';
            statusColor = Colors.green;
            break;
          case 'FAILED':
            statusMessage = '❌ Recarga falló';
            statusColor = Colors.red;
            break;
          case 'PROCESSING':
          default:
            statusMessage = '🔄 Recarga en proceso';
            statusColor = Colors.orange;
            break;
        }
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Estado de la Orden'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: $orderId'),
                SizedBox(height: 8),
                Text(
                  statusMessage,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cerrar'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error consultando estado: ${result?['error'] ?? 'Error desconocido'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Cerrar dialog de loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController1.dispose();
    _phoneController2.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Por favor selecciona un producto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar que los teléfonos coincidan
    if (_phoneController1.text != _phoneController2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Los números de teléfono deben coincidir'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Validar que el número sea válido
    if (!_isPhoneValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ El número de teléfono debe ser válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Usar datos del producto seleccionado de DingConnect
    final amount = _selectedProduct!['price'].toDouble();
    final fee = amount * 0.05; // 5% fee de servicio
    final total = amount + fee;

    // Mostrar confirmación antes de proceder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📱 Confirmar Recarga'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('País: ${_countries[_selectedCountry]}'),
            Text('Teléfono: ${_phoneController1.text}'),
            Text('Producto: ${_selectedProduct!['title']}'),
            Text('Descripción: ${_selectedProduct!['description']}'),
            SizedBox(height: 8),
            Divider(),
            Text(
              'Total a pagar: \$${total.toStringAsFixed(2)} USD',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Recarga real vía DingConnect',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToPayment(amount, fee, total);
            },
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  /// Verificar balance de cuenta DingConnect
  Future<void> _checkAccountBalance() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('💰 Verificando Balance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Consultando balance de cuenta DingConnect...'),
          ],
        ),
      ),
    );
    
    try {
      final balance = await DingConnectService.instance.getAccountBalance();
      
      Navigator.pop(context); // Cerrar dialog de loading
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.green),
              SizedBox(width: 10),
              Text('Balance DingConnect'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '\$${balance.toStringAsFixed(2)} USD',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Balance disponible para recargas',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Cerrar dialog de loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error consultando balance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  /// Mostrar diálogo para consultar estado de orden
  void _showOrderStatusDialog() {
    final TextEditingController orderIdController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🔍 Consultar Orden'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ingresa el ID de la orden para consultar su estado:'),
            SizedBox(height: 16),
            TextField(
              controller: orderIdController,
              decoration: InputDecoration(
                labelText: 'Order ID',
                hintText: 'Ej: ORD_1234567890',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (orderIdController.text.isNotEmpty) {
                Navigator.pop(context);
                _checkOrderStatus(orderIdController.text.trim());
              }
            },
            child: Text('Consultar'),
          ),
        ],
      ),
    );
  }
  
  void _navigateToPayment(double amount, double fee, double total) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(
          amount: amount,
          fee: fee,
          total: total,
          metadata: {
            'phoneNumber': _phoneController1.text,
            'countryCode': _selectedCountry,
            'skuCode': _selectedProduct!['skuCode'],
            'productTitle': _selectedProduct!['title'],
            'productDescription': _selectedProduct!['description'],
            'provider': _selectedProduct!['provider'],
            'isDingConnectTransaction': true,
          },
        ),
      ),
    );
  }
}
