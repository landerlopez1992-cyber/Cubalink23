import 'package:flutter/material.dart';
import 'package:cubalink23/services/supabase_database_service.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/models/user.dart';
import 'package:cubalink23/services/auth_guard_service.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final hasAuth = await AuthGuardService.instance.requireAuth(context, serviceName: 'las Transferencias de Saldo');
    if (!hasAuth) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Fondo general Cubalink23
      appBar: AppBar(
        backgroundColor: Color(0xFF37474F), // Azul gris oscuro oficial Cubalink23
        title: Text(
          'Transferir Saldo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: [
            Tab(
              icon: Icon(Icons.arrow_upward),
              text: 'Enviar',
            ),
            Tab(
              icon: Icon(Icons.arrow_downward),
              text: 'Recibir',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SendMoneyTab(),
          ReceiveMoneyTab(),
        ],
      ),
    );
  }
}

class SendMoneyTab extends StatefulWidget {
  const SendMoneyTab({super.key});

  @override
  _SendMoneyTabState createState() => _SendMoneyTabState();
}

class _SendMoneyTabState extends State<SendMoneyTab> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final SupabaseDatabaseService _repository = SupabaseDatabaseService.instance;
  
  // Métodos temporales simplificados hasta migración completa
  Future<User?> _findUserByEmail(String email) async {
    // TODO: Implementar búsqueda por email en Supabase
    return null;
  }
  
  Future<User?> _findUserByPhone(String phone) async {
    // TODO: Implementar búsqueda por teléfono en Supabase  
    return null;
  }
  
  Future<void> _createTransfer(String fromUserId, String toUserId, double amount, String type) async {
    // TODO: Implementar creación de transferencia en Supabase
    print('Transfer created: $fromUserId -> $toUserId, amount: $amount, type: $type');
  }
  
  Future<void> _createNotification(String userId, String type, String title, String message) async {
    // TODO: Implementar creación de notificación en Supabase
    print('Notification created for $userId: $title - $message');
  }
  
  bool _isSearching = false;
  final bool _isLoading = false;
  User? _selectedUser;
  User? _currentUser;
  double _currentBalance = 0.0;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      await SupabaseAuthService.instance.loadCurrentUserData();
      final user = SupabaseAuthService.instance.currentUser;
      setState(() {
        _currentUser = user;
        _currentBalance = SupabaseAuthService.instance.userBalance;
      });
    } catch (e) {
      setState(() {
        _currentBalance = 0.0;
      });
    }
  }

  Future<void> _searchUser() async {
    final searchText = _searchController.text.trim();
    if (searchText.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
      _selectedUser = null;
    });

    try {
      // Buscar usuario por email o teléfono
      User? user;
      if (searchText.contains('@')) {
        user = await _findUserByEmail(searchText);
      } else {
        user = await _findUserByPhone(searchText);
      }

      setState(() {
        if (user != null) {
          _selectedUser = user;
        } else {
          _searchError = 'Usuario no encontrado';
        }
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchError = 'Error al buscar usuario: ${e.toString()}';
        _isSearching = false;
      });
    }
  }

  Future<void> _sendMoney() async {
    if (_selectedUser == null) return;
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 5.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El monto mínimo es \$5.00'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (amount > _currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saldo insuficiente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar diálogo de carga bonito
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Enviando Saldo...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Procesando tu transferencia\nde \$${amount.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Esperar 1 segundo para mostrar el indicador de carga
      await Future.delayed(Duration(seconds: 1));
      
      // Crear transferencia en Supabase (TODO: implementar método)
      await _createTransfer(
        _currentUser?.id ?? 'demo_user',
        _selectedUser!.id,
        amount,
        'send',
      );

      // Crear notificación para el destinatario (TODO: implementar método)
      await _createNotification(
        _selectedUser!.id,
        'transfer_received',
        'Saldo recibido',
        'Has recibido \$${amount.toStringAsFixed(2)} de ${_currentUser?.name ?? "un usuario"}',
      );

      // Crear notificación para el remitente (TODO: implementar método)  
      await _createNotification(
        _currentUser?.id ?? 'demo_user',
        'transfer_sent',
        'Saldo enviado',
        'Has enviado \$${amount.toStringAsFixed(2)} a ${_selectedUser!.name}',
      );

      // Recargar datos del usuario para actualizar balance
      await _loadCurrentUser();


      // Cerrar diálogo de carga
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('¡Transferencia enviada exitosamente!'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Limpiar formulario
      _amountController.clear();
      _searchController.clear();
      setState(() {
        _selectedUser = null;
      });

    } catch (e) {
      // Cerrar diálogo de carga
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Error al enviar transferencia: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurple.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo disponible',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '\$${_currentBalance.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          // Search section
          Text(
            'Buscar destinatario',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Email o número de teléfono',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onSubmitted: (_) => _searchUser(),
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSearching ? null : _searchUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSearching 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.search),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Search result or error
          if (_searchError != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _searchError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            )
          else if (_selectedUser != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text(
                      _selectedUser!.name.split(' ').map((word) => word[0]).join(''),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedUser!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _selectedUser!.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _selectedUser!.phone,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
          
          SizedBox(height: 24),
          
          // Amount section
          Text(
            'Monto a enviar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '\$ ',
              suffixText: 'USD',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          
          SizedBox(height: 8),
          Text(
            'Monto mínimo: \$5.00',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          
          Spacer(),
          
          // Send button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedUser != null) ? _sendMoney : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send),
                  SizedBox(width: 12),
                  Text(
                    'Enviar Saldo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
}

class ReceiveMoneyTab extends StatefulWidget {
  const ReceiveMoneyTab({super.key});

  @override
  _ReceiveMoneyTabState createState() => _ReceiveMoneyTabState();
}

class _ReceiveMoneyTabState extends State<ReceiveMoneyTab> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final SupabaseDatabaseService _repository = SupabaseDatabaseService.instance;
  
  // Métodos temporales simplificados hasta migración completa
  Future<User?> _findUserByEmail(String email) async {
    // TODO: Implementar búsqueda por email en Supabase
    return null;
  }
  
  Future<User?> _findUserByPhone(String phone) async {
    // TODO: Implementar búsqueda por teléfono en Supabase  
    return null;
  }
  
  Future<void> _createTransfer(String fromUserId, String toUserId, double amount, String type) async {
    // TODO: Implementar creación de transferencia en Supabase
    print('Transfer created: $fromUserId -> $toUserId, amount: $amount, type: $type');
  }
  
  Future<void> _createNotification(String userId, String type, String title, String message) async {
    // TODO: Implementar creación de notificación en Supabase
    print('Notification created for $userId: $title - $message');
  }
  
  bool _isSearching = false;
  final bool _isLoading = false;
  User? _selectedUser;
  User? _currentUser;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      await SupabaseAuthService.instance.loadCurrentUserData();
      final user = SupabaseAuthService.instance.currentUser;
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      // Demo user si no hay usuario actual
    }
  }

  Future<void> _searchUser() async {
    final searchText = _searchController.text.trim();
    if (searchText.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
      _selectedUser = null;
    });

    try {
      // Buscar usuario por email o teléfono
      User? user;
      if (searchText.contains('@')) {
        user = await _findUserByEmail(searchText);
      } else {
        user = await _findUserByPhone(searchText);
      }

      setState(() {
        if (user != null) {
          _selectedUser = user;
        } else {
          _searchError = 'Usuario no encontrado';
        }
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchError = 'Error al buscar usuario: ${e.toString()}';
        _isSearching = false;
      });
    }
  }

  Future<void> _requestMoney() async {
    if (_selectedUser == null) return;
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 5.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El monto mínimo es \$5.00'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar diálogo de carga bonito
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Enviando Solicitud...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Enviando solicitud de\n\$${amount.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Esperar 1 segundo para mostrar el indicador de carga
      await Future.delayed(Duration(seconds: 1));
      // Crear solicitud de transferencia (TODO: implementar método)
      await _createTransfer(
        _selectedUser!.id,
        _currentUser?.id ?? 'demo_user',
        amount,
        'request',
      );

      // Crear notificación para el usuario solicitado (TODO: implementar método)
      await _createNotification(
        _selectedUser!.id,
        'money_request',
        'Solicitud de saldo',
        '${_currentUser?.name ?? "Un usuario"} te solicita \$${amount.toStringAsFixed(2)}',
      );

      // Cerrar diálogo de carga
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('¡Solicitud de saldo enviada!'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Limpiar formulario
      _amountController.clear();
      _searchController.clear();
      setState(() {
        _selectedUser = null;
      });

    } catch (e) {
      // Cerrar diálogo de carga
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Error al enviar solicitud: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Colors.teal.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.arrow_downward,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(height: 12),
                Text(
                  'Solicitar Saldo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Envía una solicitud de saldo a otro usuario',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          // Search section
          Text(
            'Buscar usuario',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Email o número de teléfono',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onSubmitted: (_) => _searchUser(),
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSearching ? null : _searchUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSearching 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.search),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Search result or error
          if (_searchError != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _searchError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            )
          else if (_selectedUser != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text(
                      _selectedUser!.name.split(' ').map((word) => word[0]).join(''),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedUser!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _selectedUser!.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _selectedUser!.phone,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
          
          SizedBox(height: 24),
          
          // Amount section
          Text(
            'Monto a solicitar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '\$ ',
              suffixText: 'USD',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          
          SizedBox(height: 8),
          Text(
            'Monto mínimo: \$5.00',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          
          Spacer(),
          
          // Request button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedUser != null) ? _requestMoney : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.request_page),
                  SizedBox(width: 12),
                  Text(
                    'Solicitar Saldo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
}