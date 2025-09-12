import 'package:flutter/material.dart';
import 'package:cubalink23/services/cart_service.dart';
import 'package:cubalink23/models/cart_item.dart';
import 'package:cubalink23/models/order.dart';
import 'package:cubalink23/models/payment_card.dart';
import 'package:cubalink23/services/firebase_repository.dart';
import 'package:cubalink23/services/auth_service.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/widgets/zelle_payment_dialog.dart';
import 'package:cubalink23/screens/payment/payment_method_screen.dart';
import 'dart:io';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({super.key});

  @override
  _ShippingScreenState createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  final CartService _cartService = CartService();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  
  String _selectedShippingMethod = 'express';
  String? _selectedAddress;
  String? _selectedPaymentMethod;
  
  List<Map<String, dynamic>> _savedAddresses = [];
  List<Map<String, dynamic>> _paymentMethods = [];
  final FirebaseRepository _repository = FirebaseRepository.instance;
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isProcessingPayment = false;
  double _userBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = SupabaseAuthService.instance.getCurrentUser();
      if (currentUser != null) {
        print('======= LOADING USER DATA =======');
        print('Loading data for user: ${currentUser.id}');
        
        // Load addresses with forced refresh
        print('Loading addresses...');
        final addresses = await SupabaseAuthService.instance.getUserAddresses(currentUser.id);
        print('✅ Loaded ${addresses.length} addresses');
        for (var addr in addresses) {
          print('   📍 ${addr['fullName']} - ${addr['city']}, ${addr['province']}');
        }
        
        // ELIMINADO: Ya no se crean tarjetas de muestra
        
        // Load payment methods after ensuring sample data exists
        final paymentCards = await SupabaseAuthService.instance.getUserPaymentCards(currentUser.id);
        final paymentMethods = paymentCards.map((card) => {
          'id': card.id,
          'name': '**** ${card.last4}',
          'type': card.cardType,
        }).toList();
        print('✅ Loaded ${paymentMethods.length} payment methods');
        for (var method in paymentMethods) {
          print('   💳 ${method['name']}');
        }
        
        // Load user balance
        final userData = {'balance': SupabaseAuthService.instance.userBalance};
        // Simulado: await SupabaseService.instance.getUserData(currentUser.id);
        final userBalance = userData['balance'] ?? 0.0;
        print('✅ User balance: \$${userBalance.toStringAsFixed(2)}');
        
        if (mounted) {
          setState(() {
            _savedAddresses = addresses;
            _paymentMethods = paymentMethods;
            _userBalance = userBalance;
            _selectedPaymentMethod = 'zelle'; // Default to Zelle
            _isLoading = false;
          });
        }
        
        print('📊 Final UI State:');
        print('   - ${_savedAddresses.length} direcciones guardadas');
        print('   - ${_paymentMethods.length} métodos de pago');
        print('   - Saldo: \$${_userBalance.toStringAsFixed(2)}');
        print('======= USER DATA LOADED =======');
      } else {
        print('❌ No current user found');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // ELIMINADO: No crear tarjetas de muestra automáticamente

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _phoneController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Color(0xFF232F3E),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isProcessingPayment ? null : () => Navigator.pop(context),
        ),
        title: Text(
          'Información de Envío',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Método de envío
                  _buildShippingMethodSelector(),
                  
                  // Cálculo de envío
                  _buildShippingCalculation(),
                  
                  // Direcciones guardadas
                  _buildSavedAddresses(),
                  
                  // Dirección manual (si no selecciona guardada)
                  if (_selectedAddress == null) _buildManualAddress(),
                  
                  // Métodos de pago
                  _buildPaymentMethods(),
                  
                  // Resumen del pedido
                  _buildOrderSummary(),
                ],
              ),
            ),
      bottomNavigationBar: _buildContinueButton(),
    );
  }

  Widget _buildShippingMethodSelector() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF067D62), Color(0xFF0A9B7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona método de envío',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          // Express
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedShippingMethod = 'express';
              });
            },
            child: Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _selectedShippingMethod == 'express' 
                    ? Colors.white 
                    : Colors.white.withOpacity( 0.2),
                borderRadius: BorderRadius.circular(8),
                border: _selectedShippingMethod == 'express'
                    ? Border.all(color: Color(0xFF0A9B7A), width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: 'express',
                    groupValue: _selectedShippingMethod,
                    onChanged: (value) => setState(() => _selectedShippingMethod = value!),
                    activeColor: Color(0xFF0A9B7A),
                  ),
                  Icon(
                    Icons.flight_takeoff,
                    color: _selectedShippingMethod == 'express' ? Color(0xFF0A9B7A) : Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Envío Express',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedShippingMethod == 'express' ? Color(0xFF232F3E) : Colors.white,
                          ),
                        ),
                        Text(
                          '48-72 horas • Peso × \$5.50/lb + \$10 base',
                          style: TextStyle(
                            fontSize: 12,
                            color: _selectedShippingMethod == 'express' ? Colors.grey[600] : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Marítimo
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedShippingMethod = 'maritime';
              });
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedShippingMethod == 'maritime' 
                    ? Colors.white 
                    : Colors.white.withOpacity( 0.2),
                borderRadius: BorderRadius.circular(8),
                border: _selectedShippingMethod == 'maritime'
                    ? Border.all(color: Color(0xFF0A9B7A), width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: 'maritime',
                    groupValue: _selectedShippingMethod,
                    onChanged: (value) => setState(() => _selectedShippingMethod = value!),
                    activeColor: Color(0xFF0A9B7A),
                  ),
                  Icon(
                    Icons.directions_boat,
                    color: _selectedShippingMethod == 'maritime' ? Color(0xFF0A9B7A) : Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Envío Marítimo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedShippingMethod == 'maritime' ? Color(0xFF232F3E) : Colors.white,
                          ),
                        ),
                        Text(
                          '3-5 semanas • Peso × \$2.50/lb',
                          style: TextStyle(
                            fontSize: 12,
                            color: _selectedShippingMethod == 'maritime' ? Colors.grey[600] : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingCalculation() {
    double totalWeightKg = 0.0;
    int itemsWithRealWeight = 0;
    int totalItems = 0;
    List<String> debugInfo = [];
    
    // Calcular peso total y contar productos con peso real
    for (var item in _cartService.items) {
      totalItems++;
      double itemWeightKg = 0.0;
      bool hasRealWeight = false;
      
      print('🔍 ANALIZANDO PRODUCTO: ${item.name}');
      print('   - Peso original: ${item.weight}');
      print('   - Tipo peso: ${item.weight.runtimeType}');
      
      // Verificar si tiene peso real de la API
      if (item.weight != null) {
        if (item.weight is double && item.weight! > 0) {
          itemWeightKg = item.weight!;
          hasRealWeight = true;
          itemsWithRealWeight++;
          print('   ✅ Peso doble válido: $itemWeightKg kg');
        } else if (item.weight is String) {
          String weightStr = item.weight.toString().trim();
          print('   - Peso string: "$weightStr"');
          
          if (!weightStr.contains('PESO_NO_DISPONIBLE') && weightStr.isNotEmpty) {
            // Extraer número del peso y convertir a kg
            itemWeightKg = _parseWeightString(weightStr);
            if (itemWeightKg > 0) {
              hasRealWeight = true;
              itemsWithRealWeight++;
              print('   ✅ Peso parseado: $itemWeightKg kg');
            } else {
              print('   ❌ No se pudo parsear el peso: $weightStr');
            }
          } else {
            print('   ⚠️ Peso no disponible en API');
          }
        }
      }
      
      // Si no tiene peso real, usar estimado realista
      if (!hasRealWeight) {
        itemWeightKg = _getEstimatedWeight(item);
        print('   📊 Usando peso estimado: $itemWeightKg kg');
      }
      
      double totalItemWeight = itemWeightKg * item.quantity;
      totalWeightKg += totalItemWeight;
      
      debugInfo.add('${item.name}: ${itemWeightKg.toStringAsFixed(2)}kg × ${item.quantity} = ${totalItemWeight.toStringAsFixed(2)}kg ${hasRealWeight ? '(Real)' : '(Estimado)'}');
      print('   📦 Total item: $totalItemWeight kg (${item.quantity} unidades)');
    }
    
    print('\n🏋️ PESO TOTAL: $totalWeightKg kg (${(totalWeightKg * 2.20462).toStringAsFixed(1)} lbs)');
    print('📊 Items con peso real: $itemsWithRealWeight de $totalItems');
    for (var info in debugInfo) {
      print('   - $info');
    }
    
    double shippingCost = _calculateShippingCost(totalWeightKg);
    bool hasUnknownWeights = itemsWithRealWeight < totalItems;
    bool hasHeavyItems = totalWeightKg > 31.75; // 70 lbs en kg
    
    print('💰 CÁLCULO DE ENVÍO:');
    print('   - Método: $_selectedShippingMethod');
    print('   - Peso total: $totalWeightKg kg (${(totalWeightKg * 2.20462).toStringAsFixed(1)} lbs)');
    print('   - Costo envío: \$${shippingCost.toStringAsFixed(2)}');
    if (_selectedShippingMethod == 'express') {
      double weightLbs = totalWeightKg * 2.20462;
      double calculation = (weightLbs * 5.50) + 10.0;
      print('   - Fórmula Express: ${weightLbs.toStringAsFixed(1)} lbs × \$5.50 + \$10 = \$${calculation.toStringAsFixed(2)}');
    } else {
      double weightLbs = totalWeightKg * 2.20462;
      double calculation = weightLbs * 2.50;
      print('   - Fórmula Marítimo: ${weightLbs.toStringAsFixed(1)} lbs × \$2.50 = \$${calculation.toStringAsFixed(2)}');
    }
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity( 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cálculo de Envío',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF232F3E),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _selectedShippingMethod == 'express' ? Colors.blue[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedShippingMethod == 'express' ? Colors.blue[200]! : Colors.orange[200]!,
                  ),
                ),
                child: Text(
                  _selectedShippingMethod == 'express' ? 'EXPRESS' : 'MARÍTIMO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _selectedShippingMethod == 'express' ? Colors.blue[700] : Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Peso total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.scale, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peso total:',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      Text(
                        '$itemsWithRealWeight de $totalItems productos con peso real',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '${totalWeightKg.toStringAsFixed(2)} kg (${(totalWeightKg * 2.20462).toStringAsFixed(1)} lbs)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF232F3E),
                ),
              ),
            ],
          ),
          
          if (hasUnknownWeights) ...[
            SizedBox(height: 12),
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
                      Icon(Icons.info, color: Colors.orange[600], size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Aviso sobre el peso:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'El sistema no logró calcular el peso exacto de algunos productos. Hemos estimado el peso basado en el tipo de producto. Una vez que recibamos el pedido en nuestra bodega, antes de preparar el envío, el cliente será contactado en caso de diferencia de peso para cobrar más o desembolsar la diferencia.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange[700],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          SizedBox(height: 16),
          
          if (hasHeavyItems && _selectedShippingMethod == 'express') ...[
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[600], size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Los productos que pesan más de 70 libras deben enviarse vía marítima.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Desglose del cálculo
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedShippingMethod == 'express' ? 'Envío Express' : 'Envío Marítimo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF232F3E),
                          ),
                        ),
                        Text(
                          _selectedShippingMethod == 'express' 
                              ? '${(totalWeightKg * 2.20462).toStringAsFixed(1)} lbs × \$5.50 + \$10.00'
                              : '${(totalWeightKg * 2.20462).toStringAsFixed(1)} lbs × \$2.50',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${shippingCost.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB12704),
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

  Widget _buildSavedAddresses() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity( 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Direcciones Guardadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF232F3E),
            ),
          ),
          SizedBox(height: 16),
          
          ..._savedAddresses.map((address) => GestureDetector(
            onTap: () {
              setState(() {
                _selectedAddress = address['id']?.toString();
              });
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedAddress == address['id']?.toString() ? Colors.green[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedAddress == address['id']?.toString() ? Colors.green[300]! : Colors.grey[200]!,
                  width: _selectedAddress == address['id']?.toString() ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: address['id']?.toString() ?? '',
                    groupValue: _selectedAddress,
                    onChanged: (value) => setState(() => _selectedAddress = value),
                    activeColor: Colors.green[600],
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address['fullName']?.toString() ?? address['recipient']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF232F3E),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          address['address']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${address['city']?.toString() ?? ''}, ${address['state']?.toString() ?? address['province']?.toString() ?? ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          address['phone']?.toString() ?? '',
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
            ),
          )),
          
          SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _selectedAddress = null),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedAddress == null ? Colors.blue[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedAddress == null ? Colors.blue[300]! : Colors.grey[200]!,
                  width: _selectedAddress == null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Radio<String?>(
                    value: null,
                    groupValue: _selectedAddress,
                    onChanged: (value) => setState(() => _selectedAddress = value),
                    activeColor: Colors.blue[600],
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.add_location, color: Colors.blue[600], size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Usar nueva dirección',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualAddress() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity( 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dirección de Entrega en Cuba',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF232F3E),
            ),
          ),
          SizedBox(height: 16),
          
          TextField(
            controller: _recipientController,
            decoration: InputDecoration(
              labelText: 'Nombre del destinatario *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          SizedBox(height: 16),
          
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Teléfono del destinatario *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 16),
          
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Dirección completa *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.home),
            ),
            maxLines: 2,
          ),
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Ciudad *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.location_city),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _provinceController,
                  decoration: InputDecoration(
                    labelText: 'Provincia *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.map),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    double totalCost = _cartService.subtotal + _calculateShippingCost(_cartService.items.fold(0.0, (total, item) {
      double itemWeight = _getItemWeight(item);
      return total + (itemWeight * item.quantity);
    }));
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity( 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Método de Pago',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF232F3E),
            ),
          ),
          SizedBox(height: 16),
          
          // Zelle
          GestureDetector(
            onTap: () => setState(() => _selectedPaymentMethod = 'zelle'),
            child: Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedPaymentMethod == 'zelle' ? Colors.purple[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedPaymentMethod == 'zelle' ? Colors.purple[300]! : Colors.grey[200]!,
                  width: _selectedPaymentMethod == 'zelle' ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: 'zelle',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value),
                    activeColor: Colors.purple[600],
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.account_balance,
                      color: Colors.purple[600],
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zelle',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF232F3E),
                          ),
                        ),
                        Text(
                          'Transfiere directamente desde tu banco',
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
            ),
          ),
          
          // Tarjetas de Crédito/Débito
          GestureDetector(
            onTap: () => setState(() => _selectedPaymentMethod = 'card'),
            child: Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedPaymentMethod == 'card' ? Colors.blue[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedPaymentMethod == 'card' ? Colors.blue[300]! : Colors.grey[200]!,
                  width: _selectedPaymentMethod == 'card' ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: 'card',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value),
                    activeColor: Colors.blue[600],
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.credit_card,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tarjeta de Crédito/Débito',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF232F3E),
                          ),
                        ),
                        Text(
                          'Paga con cualquier tarjeta',
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
            ),
          ),
          
          // Billetera
          GestureDetector(
            onTap: () => setState(() => _selectedPaymentMethod = 'wallet'),
            child: Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedPaymentMethod == 'wallet' ? Colors.green[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedPaymentMethod == 'wallet' ? Colors.green[300]! : Colors.grey[200]!,
                  width: _selectedPaymentMethod == 'wallet' ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: 'wallet',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value),
                    activeColor: Colors.green[600],
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.green[600],
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Billetera',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF232F3E),
                          ),
                        ),
                        Text(
                          'Saldo disponible: \$${_userBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _userBalance >= totalCost ? Colors.green[600] : Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 8),
          InkWell(
            onTap: () async {
              // Navegar a agregar nueva tarjeta
              final result = await Navigator.pushNamed(context, '/add-card');
              if (result != null) {
                // Recargar métodos de pago si se agregó una nueva tarjeta
                _loadUserData();
              }
            },
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.blue[600], size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Agregar nueva tarjeta',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del Pedido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF232F3E),
            ),
          ),
          SizedBox(height: 16),
          
          // Lista de productos
          ...(_cartService.items.take(3)).map((item) => Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: item.imageUrl.isNotEmpty
                        ? Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                item.type == 'recharge' ? Icons.phone : Icons.image,
                                color: Colors.grey[400],
                                size: 20,
                              );
                            },
                          )
                        : Icon(
                            item.type == 'recharge' ? Icons.phone : Icons.image,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF232F3E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Cantidad: ${item.quantity}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB12704),
                  ),
                ),
              ],
            ),
          )).toList(),
          
          if (_cartService.items.length > 3) ...[
            SizedBox(height: 8),
            Text(
              '... y ${_cartService.items.length - 3} producto${_cartService.items.length - 3 != 1 ? 's' : ''} más',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          
          Divider(height: 24, color: Colors.grey[300]),
          
          // Totales
          _buildSummaryRow('Subtotal', _cartService.subtotal),
          SizedBox(height: 8),
          _buildSummaryRow(
            _selectedShippingMethod == 'express' ? 'Envío Express' : 'Envío Marítimo', 
            _calculateShippingCost(_cartService.items.fold(0.0, (total, item) {
              double itemWeight = _getItemWeight(item);
              return total + (itemWeight * item.quantity);
            }))
          ),
          Divider(height: 16, color: Colors.grey[300]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF232F3E),
                ),
              ),
              Text(
                '\$${(_cartService.subtotal + _calculateShippingCost(_cartService.items.fold(0.0, (total, item) {
                  double itemWeight = _getItemWeight(item);
                  return total + (itemWeight * item.quantity);
                }))).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB12704),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF232F3E),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: (_isFormValid() && !_isProcessingPayment) ? _proceedToPayment : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF9900),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isProcessingPayment
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Procesando...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Proceder al Pago - \$${(_cartService.subtotal + _calculateShippingCost(_cartService.items.fold(0.0, (total, item) {
                      double itemWeight = _getItemWeight(item);
                      return total + (itemWeight * item.quantity);
                    }))).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  bool _isFormValid() {
    if (_selectedAddress != null) {
      return _selectedPaymentMethod != null;
    }
    return _recipientController.text.trim().isNotEmpty &&
           _phoneController.text.trim().isNotEmpty &&
           _addressController.text.trim().isNotEmpty &&
           _cityController.text.trim().isNotEmpty &&
           _provinceController.text.trim().isNotEmpty &&
           _selectedPaymentMethod != null;
  }

  void _proceedToPayment() async {
    if (_isProcessingPayment) return;
    
    setState(() => _isProcessingPayment = true);
    
    try {
      final currentUser = SupabaseAuthService.instance.getCurrentUser();
      if (currentUser == null) {
        _showErrorSnackBar('Usuario no autenticado');
        return;
      }

      double totalWeight = _cartService.items.fold(0.0, (total, item) {
        double itemWeight = _getItemWeight(item);
        return total + (itemWeight * item.quantity);
      });
      
      // Prepare address data
      OrderAddress shippingAddress;
      if (_selectedAddress != null) {
        var selectedAddr = _savedAddresses.firstWhere((addr) => addr['id']?.toString() == _selectedAddress);
        shippingAddress = OrderAddress(
          recipient: selectedAddr['fullName']?.toString() ?? selectedAddr['recipient']?.toString() ?? '',
          phone: selectedAddr['phone']?.toString() ?? '',
          address: selectedAddr['address']?.toString() ?? '',
          city: selectedAddr['city']?.toString() ?? '',
          province: selectedAddr['state']?.toString() ?? selectedAddr['province']?.toString() ?? '',
        );
      } else {
        shippingAddress = OrderAddress(
          recipient: _recipientController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          province: _provinceController.text.trim(),
        );
      }
      
      double subtotal = _cartService.subtotal;
      double shipping = _calculateShippingCost(totalWeight);
      double total = subtotal + shipping;
      
      // Convert cart items to order items
      List<OrderItem> orderItems = _cartService.items.map((cartItem) => OrderItem(
        id: cartItem.id,
        productId: cartItem.id,
        name: cartItem.name,
        imageUrl: cartItem.imageUrl,
        price: cartItem.price,
        quantity: cartItem.quantity,
        category: cartItem.category ?? 'general',
        type: cartItem.type,
      )).toList();

      // Calculate estimated delivery
      DateTime estimatedDelivery = DateTime.now();
      if (_selectedShippingMethod == 'express') {
        estimatedDelivery = estimatedDelivery.add(Duration(days: 3));
      } else {
        estimatedDelivery = estimatedDelivery.add(Duration(days: 21));
      }

      // Generate order number
      String orderNumber = await _repository.generateOrderNumber();
      
      // Create order
      Order newOrder = Order(
        id: '',
        userId: currentUser.id,
        orderNumber: orderNumber,
        items: orderItems,
        shippingAddress: shippingAddress,
        shippingMethod: _selectedShippingMethod,
        subtotal: subtotal,
        shippingCost: shipping,
        total: total,
        paymentMethod: _selectedPaymentMethod ?? '',
        paymentStatus: 'pending',
        orderStatus: 'created',
        createdAt: DateTime.now(),
        estimatedDelivery: estimatedDelivery,
      );

      if (_selectedPaymentMethod == 'zelle') {
        _handleZellePayment(newOrder);
      } else if (_selectedPaymentMethod == 'card') {
        _handleCardPayment(newOrder);
      } else if (_selectedPaymentMethod == 'wallet') {
        _handleWalletPayment(newOrder);
      } else {
        _showErrorSnackBar('Por favor seleccione un método de pago');
      }
      
    } catch (e) {
      print('Error proceeding to payment: $e');
      _showErrorSnackBar('Error al procesar la orden: $e');
    } finally {
      setState(() => _isProcessingPayment = false);
    }
  }

  void _handleZellePayment(Order order) async {
    try {
      print('🟡 ===== INICIANDO PAGO ZELLE =====');
      print('   💰 Total: \$${order.total.toStringAsFixed(2)}');
      print('   📱 Usuario: ${order.userId}');
      print('   📦 Orden: ${order.orderNumber}');
      
      String? orderId;
      
      // Show Zelle payment dialog
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ZellePaymentDialog(
          totalAmount: order.total,
          order: order,
          onCancel: () async {
            try {
              if (orderId != null) {
                print('❌ Cancelando orden: $orderId');
                await _repository.updateOrderStatus(orderId!, 'cancelled');
              }
            } catch (e) {
              print('❌ Error cancelando orden: $e');
            }
          },
          onOrderCreated: (String createdOrderId) async {
            try {
              orderId = createdOrderId;
              print('✅ Orden creada con ID: $orderId');
              
              // Force refresh activities to show immediately
              print('📝 Registrando actividades...');
              
              // Add a small delay to ensure order is properly saved
              await Future.delayed(Duration(milliseconds: 500));
              
              // Registrar actividad de creación de orden
              await _repository.addActivity(
                order.userId,
                'order_created',
                'Orden #${order.orderNumber} creada con pago Zelle pendiente',
                amount: order.total,
              );
              print('✅ Actividad order_created registrada');
              
              // Registrar transacción de compra Amazon
              await _repository.addActivity(
                order.userId,
                'amazon_purchase',
                'Compra en Amazon por \$${order.total.toStringAsFixed(2)}',
                amount: order.total,
              );
              print('✅ Actividad amazon_purchase registrada');
              
            } catch (e) {
              print('❌ Error procesando creación de orden: $e');
              throw Exception('Error al procesar la orden: ${e.toString()}');
            }
          },
        ),
      );
      
      if (result == true && orderId != null) {
        print('✅ Orden creada exitosamente');
        _cartService.clearCart();
        print('🛒 Carrito limpiado');
        
        _showSuccessDialog(order.orderNumber, 'zelle');
      } else if (result == false || result == null) {
        print('❌ Pago cancelado por el usuario');
        if (orderId != null) {
          await _repository.updateOrderStatus(orderId!, 'cancelled');
        }
        _showErrorSnackBar('Pago cancelado');
      }
      
      print('🟡 ===== PAGO ZELLE FINALIZADO =====');
      
    } catch (e) {
      print('❌ Error en pago Zelle: $e');
      _showErrorSnackBar('Error al procesar el pago: ${e.toString()}');
    }
  }

  void _showSuccessDialog(String orderNumber, String paymentType) {
    String message = '';
    if (paymentType == 'zelle') {
      message = 'Procesaremos su pago una vez que recibamos y verifiquemos el comprobante de Zelle.';
    } else if (paymentType == 'wallet') {
      message = 'Su pago ha sido procesado exitosamente usando el saldo de su billetera.';
    } else if (paymentType == 'card') {
      message = 'Su pago con tarjeta ha sido procesado exitosamente.';
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 28),
            SizedBox(width: 8),
            Text('¡Orden Creada!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Su orden $orderNumber ha sido creada exitosamente.'),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[600], size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Su orden aparecerá en:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Actividad: Registro de transacción creada\n• Historial: Lista completa de compras\n• Rastreo de Mi Orden: Estados de envío',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/order-tracking');
            },
            child: Text('Ver Mi Orden'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to main screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _handleCardPayment(Order order) async {
    try {
      print('💳 ===== INICIANDO PAGO CON TARJETA =====');
      print('   💰 Total: \$${order.total.toStringAsFixed(2)}');
      print('   📱 Usuario: ${order.userId}');
      print('   📦 Orden: ${order.orderNumber}');
      
      // Navigate to the existing payment method screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentMethodScreen(
            amount: order.subtotal,
            fee: order.shippingCost,
            total: order.total,
          ),
        ),
      );
      
      if (result == true) {
        print('✅ Pago con tarjeta exitoso, creando orden...');
        
        // Payment was successful, create the order
        final orderData = order.toMap();
        orderData['payment_status'] = 'completed';
        orderData['order_status'] = 'payment_confirmed';
        orderData['payment_method'] = 'card';
        
        String orderId = await _repository.createOrder(orderData);
        print('✅ Orden creada con pago exitoso: $orderId');
        
        // Add delay to ensure proper saving
        await Future.delayed(Duration(milliseconds: 500));
        
        // Registrar actividades
        await _repository.addActivity(
          order.userId,
          'order_created',
          'Orden #${order.orderNumber} creada y pagada con tarjeta',
          amount: order.total,
        );
        print('✅ Actividad order_created registrada');
        
        await _repository.addActivity(
          order.userId,
          'amazon_purchase',
          'Compra en Amazon por \$${order.total.toStringAsFixed(2)}',
          amount: order.total,
        );
        print('✅ Actividad amazon_purchase registrada');
        
        // 🎯 NOTIFICAR SERVICIO USADO PARA RECOMPENSAS DE REFERIDOS
        await AuthService.instance.notifyServiceUsed();
        print('✅ Compra Amazon completada - Recompensas de referidos procesadas');
        
        _cartService.clearCart();
        print('🛒 Carrito limpiado');
        _showSuccessDialog(order.orderNumber, 'card');
      } else {
        print('❌ Pago con tarjeta cancelado');
        _showErrorSnackBar('Pago con tarjeta cancelado');
      }
      
      print('💳 ===== PAGO CON TARJETA FINALIZADO =====');
      
    } catch (e) {
      print('❌ Error en pago con tarjeta: $e');
      _showErrorSnackBar('Error al procesar el pago con tarjeta: ${e.toString()}');
    }
  }

  void _handleWalletPayment(Order order) async {
    try {
      print('👛 ===== INICIANDO PAGO CON BILLETERA =====');
      print('   💰 Total: \$${order.total.toStringAsFixed(2)}');
      print('   💳 Saldo disponible: \$${_userBalance.toStringAsFixed(2)}');
      
      // Verificar si el usuario tiene suficiente saldo
      if (_userBalance < order.total) {
        print('❌ Saldo insuficiente');
        _showErrorSnackBar('Saldo insuficiente. Tu saldo es \$${_userBalance.toStringAsFixed(2)} y el total es \$${order.total.toStringAsFixed(2)}');
        return;
      }
      
      final currentUser = SupabaseAuthService.instance.getCurrentUser();
      if (currentUser != null) {
        // Crear la orden con pago completo
        final orderData = order.toMap();
        orderData['payment_status'] = 'completed';
        orderData['order_status'] = 'payment_confirmed';
        orderData['payment_method'] = 'wallet';
        
        String orderId = await _repository.createOrder(orderData);
        print('✅ Orden creada con pago billetera: $orderId');
        
        // Descontar del saldo del usuario
        final newBalance = _userBalance - order.total;
        await _repository.updateUserBalance(currentUser.id, newBalance);
        print('✅ Saldo actualizado');
        
        // Add delay to ensure proper saving
        await Future.delayed(Duration(milliseconds: 500));
        
        // Registrar actividades
        await _repository.addActivity(
          order.userId,
          'order_created',
          'Orden #${order.orderNumber} pagada con billetera',
          amount: order.total,
        );
        print('✅ Actividad order_created registrada');
        
        await _repository.addActivity(
          order.userId,
          'amazon_purchase',
          'Compra en Amazon por \$${order.total.toStringAsFixed(2)}',
          amount: order.total,
        );
        print('✅ Actividad amazon_purchase registrada');
        
        // 🎯 NOTIFICAR SERVICIO USADO PARA RECOMPENSAS DE REFERIDOS
        await AuthService.instance.notifyServiceUsed();
        print('✅ Compra con billetera completada - Recompensas de referidos procesadas');
        
        // Limpiar carrito
        _cartService.clearCart();
        print('🛒 Carrito limpiado');
        
        // Mostrar diálogo de éxito
        _showSuccessDialog(order.orderNumber, 'wallet');
      }
      
      print('👛 ===== PAGO CON BILLETERA FINALIZADO =====');
      
    } catch (e) {
      print('❌ Error en pago con billetera: $e');
      _showErrorSnackBar('Error al procesar el pago con billetera: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Obtener peso de un item del carrito en kilogramos
  double _getItemWeight(CartItem item) {
    if (item.weight != null) {
      if (item.weight is double && item.weight! > 0) {
        return item.weight!;
      } else if (item.weight is String) {
        String weightStr = item.weight.toString().trim();
        if (!weightStr.contains('PESO_NO_DISPONIBLE') && weightStr.isNotEmpty) {
          double parsedWeight = _parseWeightString(weightStr);
          if (parsedWeight > 0) {
            return parsedWeight;
          }
        }
      }
    }
    return _getEstimatedWeight(item);
  }
  
  double _calculateShippingCost(double weightKg) {
    double weightLbs = weightKg * 2.20462; // Convertir kg a libras exactamente
    
    print('📦 CALCULANDO ENVÍO:');
    print('   - Peso: $weightKg kg = ${weightLbs.toStringAsFixed(1)} lbs');
    print('   - Método: $_selectedShippingMethod');
    
    if (_selectedShippingMethod == 'maritime') {
      double cost = weightLbs * 2.50; // $2.50 por libra
      print('   - Cálculo Marítimo: ${weightLbs.toStringAsFixed(1)} lbs × \$2.50 = \$${cost.toStringAsFixed(2)}');
      return cost;
    } else {
      // Express: peso × $5.50 por libra + $10 base
      double cost = (weightLbs * 5.50) + 10.0;
      print('   - Cálculo Express: ${weightLbs.toStringAsFixed(1)} lbs × \$5.50 + \$10.00 = \$${cost.toStringAsFixed(2)}');
      return cost;
    }
  }
  
  /// Parsear string de peso y convertir a kilogramos
  double _parseWeightString(String weightStr) {
    weightStr = weightStr.toLowerCase().trim();
    print('🔧 Parseando peso: "$weightStr"');
    
    // Extraer número
    RegExp numberPattern = RegExp(r'(\d+(?:\.\d+)?)');
    RegExpMatch? numberMatch = numberPattern.firstMatch(weightStr);
    
    if (numberMatch == null) {
      print('❌ No se pudo extraer número del peso');
      return 0.0;
    }
    
    double? weightValue = double.tryParse(numberMatch.group(1) ?? '0');
    if (weightValue == null || weightValue <= 0) {
      print('❌ Valor de peso inválido: ${numberMatch.group(1)}');
      return 0.0;
    }
    
    // Convertir a kg según la unidad
    double weightInKg;
    
    if (weightStr.contains('lb') || weightStr.contains('pound')) {
      // Libras a kilogramos
      weightInKg = weightValue * 0.453592;
      print('🔄 Convertido de $weightValue lbs a ${weightInKg.toStringAsFixed(3)} kg');
    } else if (weightStr.contains('oz') || weightStr.contains('ounce')) {
      // Onzas a kilogramos
      weightInKg = weightValue * 0.0283495;
      print('🔄 Convertido de $weightValue oz a ${weightInKg.toStringAsFixed(3)} kg');
    } else if (weightStr.contains('g') && !weightStr.contains('kg')) {
      // Gramos a kilogramos
      weightInKg = weightValue / 1000;
      print('🔄 Convertido de $weightValue g a ${weightInKg.toStringAsFixed(3)} kg');
    } else {
      // Ya está en kilogramos
      weightInKg = weightValue;
      print('✅ Peso ya en kilogramos: ${weightInKg.toStringAsFixed(3)} kg');
    }
    
    return weightInKg;
  }
  
  /// Obtener peso estimado realista por categoría y nombre del producto
  double _getEstimatedWeight(CartItem item) {
    String productName = item.name.toLowerCase();
    String? category = item.category?.toLowerCase();
    
    // Primero verificar por nombres específicos de productos pesados
    if (productName.contains('generator') || productName.contains('generador')) {
      if (productName.contains('westinghouse') || productName.contains('champion')) {
        return 45.0; // ~100 lbs para generadores grandes
      }
      return 25.0; // ~55 lbs para generadores medianos
    }
    
    if (productName.contains('refrigerator') || productName.contains('fridge') || productName.contains('nevera')) {
      return 68.0; // ~150 lbs para refrigeradores
    }
    
    if (productName.contains('washing machine') || productName.contains('lavadora')) {
      return 59.0; // ~130 lbs para lavadoras
    }
    
    if (productName.contains('treadmill') || productName.contains('cinta de correr')) {
      return 45.0; // ~100 lbs para cintas de correr
    }
    
    if (productName.contains('motorcycle') || productName.contains('motocicleta')) {
      return 136.0; // ~300 lbs para motocicletas
    }
    
    // Luego por categorías con pesos más realistas
    switch (category) {
      case 'electronics':
      case 'electrónicos':
        if (productName.contains('tv') || productName.contains('television')) {
          return 15.0; // ~33 lbs para TVs grandes
        }
        if (productName.contains('laptop') || productName.contains('computer')) {
          return 2.5; // ~5.5 lbs para laptops
        }
        return 1.0; // 2.2 lbs para electrónicos pequeños
      
      case 'appliances':
      case 'electrodomésticos':
        return 20.0; // ~44 lbs para electrodomésticos
      
      case 'tools':
      case 'herramientas':
        if (productName.contains('drill') || productName.contains('saw') || productName.contains('taladro')) {
          return 3.0; // ~6.6 lbs para herramientas eléctricas
        }
        return 1.5; // ~3.3 lbs para herramientas manuales
      
      case 'furniture':
      case 'muebles':
        return 25.0; // ~55 lbs para muebles
      
      case 'automotive':
      case 'automotriz':
        if (productName.contains('tire') || productName.contains('wheel') || productName.contains('llanta')) {
          return 9.0; // ~20 lbs para llantas
        }
        return 5.0; // ~11 lbs para repuestos automotrices
      
      case 'sports':
      case 'deportes':
        if (productName.contains('weight') || productName.contains('dumbbell') || productName.contains('pesa')) {
          return 10.0; // ~22 lbs para pesas
        }
        return 2.0; // ~4.4 lbs para artículos deportivos
      
      case 'fashion':
      case 'moda':
        return 0.5; // ~1.1 lbs para ropa
      
      case 'books':
      case 'libros':
        return 0.8; // ~1.8 lbs para libros
      
      case 'beauty':
      case 'belleza':
        return 0.3; // ~0.7 lbs para productos de belleza
      
      default:
        // Peso por defecto más realista
        if (productName.length > 50 || productName.contains('large') || productName.contains('grande')) {
          return 5.0; // ~11 lbs para productos grandes sin categoría
        }
        return 1.5; // ~3.3 lbs por defecto
    }
  }
}