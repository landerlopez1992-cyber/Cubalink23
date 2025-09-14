import 'package:flutter/material.dart';
import 'package:cubalink23/services/user_role_service.dart';
import 'package:cubalink23/screens/wallet/saved_cards_screen.dart';

class DeliveryWalletScreen extends StatefulWidget {
  const DeliveryWalletScreen({super.key});

  @override
  _DeliveryWalletScreenState createState() => _DeliveryWalletScreenState();
}

class _DeliveryWalletScreenState extends State<DeliveryWalletScreen> {
  final UserRoleService _roleService = UserRoleService();
  double _currentBalance = 1250.75;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);
    
    try {
      // Simular datos de billetera
      // En producción, esto vendría de Supabase
      await Future.delayed(Duration(seconds: 1));
      
      setState(() {
        _transactions = [
          {
            'id': '1',
            'type': 'earning',
            'amount': 15.50,
            'description': 'Entrega completada - ORD-12345',
            'timestamp': DateTime.now().subtract(Duration(hours: 2)),
            'status': 'completed',
          },
          {
            'id': '2',
            'type': 'earning',
            'amount': 12.00,
            'description': 'Entrega completada - ORD-12340',
            'timestamp': DateTime.now().subtract(Duration(hours: 4)),
            'status': 'completed',
          },
          {
            'id': '3',
            'type': 'withdrawal',
            'amount': -100.00,
            'description': 'Retiro a tarjeta ****1234',
            'timestamp': DateTime.now().subtract(Duration(days: 1)),
            'status': 'completed',
          },
          {
            'id': '4',
            'type': 'earning',
            'amount': 18.75,
            'description': 'Entrega completada - ORD-12335',
            'timestamp': DateTime.now().subtract(Duration(days: 1, hours: 3)),
            'status': 'completed',
          },
          {
            'id': '5',
            'type': 'transfer',
            'amount': -25.00,
            'description': 'Transferencia a María González',
            'timestamp': DateTime.now().subtract(Duration(days: 2)),
            'status': 'completed',
          },
          {
            'id': '6',
            'type': 'earning',
            'amount': 22.50,
            'description': 'Entrega completada - ORD-12330',
            'timestamp': DateTime.now().subtract(Duration(days: 2, hours: 5)),
            'status': 'completed',
          },
          {
            'id': '7',
            'type': 'withdrawal',
            'amount': -200.00,
            'description': 'Retiro a tarjeta ****5678',
            'timestamp': DateTime.now().subtract(Duration(days: 3)),
            'status': 'pending',
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos de billetera: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Color(0xFF1976D2),
        title: Text(
          'Mi Billetera',
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
            onPressed: _loadWalletData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1976D2),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Balance Card
                  _buildBalanceCard(),
                  
                  // Quick Actions
                  _buildQuickActions(),
                  
                  // Transaction History
                  _buildTransactionHistory(),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1976D2).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Saldo Disponible',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            '\$${_currentBalance.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Ganancias de entregas',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones Rápidas',
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
                child: _buildActionCard(
                  icon: Icons.credit_card,
                  title: 'Retirar',
                  subtitle: 'A tarjeta',
                  color: Colors.green,
                  onTap: _showWithdrawDialog,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.send,
                  title: 'Transferir',
                  subtitle: 'A usuario',
                  color: Colors.blue,
                  onTap: _showTransferDialog,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.credit_card,
                  title: 'Mis Tarjetas',
                  subtitle: 'Gestionar',
                  color: Colors.indigo,
                  onTap: _goToSavedCards,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.analytics,
                  title: 'Estadísticas',
                  subtitle: 'Ganancias',
                  color: Colors.purple,
                  onTap: _showStatistics,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historial Reciente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _transactions.length,
            itemBuilder: (context, index) {
              final transaction = _transactions[index];
              return _buildTransactionCard(transaction);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final type = transaction['type'] as String;
    final amount = transaction['amount'] as double;
    final isPositive = amount > 0;
    final timestamp = transaction['timestamp'] as DateTime;
    final status = transaction['status'] as String;
    
    Color amountColor;
    IconData icon;
    String typeText;
    
    switch (type) {
      case 'earning':
        amountColor = Colors.green;
        icon = Icons.trending_up;
        typeText = 'Ganancia';
        break;
      case 'withdrawal':
        amountColor = Colors.red;
        icon = Icons.credit_card;
        typeText = 'Retiro';
        break;
      case 'transfer':
        amountColor = Colors.blue;
        icon = Icons.send;
        typeText = 'Transferencia';
        break;
      default:
        amountColor = Colors.grey;
        icon = Icons.help;
        typeText = 'Otro';
    }

    Color statusColor;
    String statusText;
    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Completado';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        break;
      case 'failed':
        statusColor = Colors.red;
        statusText = 'Fallido';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Desconocido';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: amountColor,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['description'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      typeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}\$${amount.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    final amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Retirar Dinero'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad a retirar',
                prefixText: '\$',
                border: OutlineInputBorder(),
                helperText: 'Saldo disponible: \$${_currentBalance.toStringAsFixed(2)}',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Selecciona o agrega una tarjeta para el retiro',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
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
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0 && amount <= _currentBalance) {
                Navigator.pop(context);
                _selectCardForWithdrawal(amount);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cantidad inválida o insuficiente'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            child: Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _selectCardForWithdrawal(double amount) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedCardsScreen(
          isForWithdrawal: true,
          withdrawalAmount: amount,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final card = result['card'] as Map<String, dynamic>;
      final withdrawAmount = result['amount'] as double;
      _processWithdrawal(withdrawAmount, card);
    }
  }

  void _showTransferDialog() {
    final amountController = TextEditingController();
    final userController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transferir Dinero'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad a transferir',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: userController,
              decoration: InputDecoration(
                labelText: 'Email del usuario',
                hintText: 'usuario@ejemplo.com',
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
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0 && amount <= _currentBalance) {
                Navigator.pop(context);
                _processTransfer(amount, userController.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cantidad inválida o insuficiente'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            child: Text('Transferir'),
          ),
        ],
      ),
    );
  }

  void _processWithdrawal(double amount, Map<String, dynamic> card) {
    final cardNumber = card['cardNumber'] as String;
    final cardNickname = card['nickname'] ?? 'Tarjeta ${card['cardType']}';
    final maskedNumber = cardNumber.length > 4 ? cardNumber.substring(cardNumber.length - 4) : cardNumber;
    
    setState(() {
      _currentBalance -= amount;
      _transactions.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'withdrawal',
        'amount': -amount,
        'description': 'Retiro a $cardNickname (****$maskedNumber)',
        'timestamp': DateTime.now(),
        'status': 'pending',
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Retiro de \$${amount.toStringAsFixed(2)} procesado a $cardNickname. Se completará en 1-2 días hábiles.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _processTransfer(double amount, String userEmail) {
    setState(() {
      _currentBalance -= amount;
      _transactions.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'transfer',
        'amount': -amount,
        'description': 'Transferencia a $userEmail',
        'timestamp': DateTime.now(),
        'status': 'completed',
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transferencia completada a $userEmail'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showFullHistory() {
    // TODO: Implementar pantalla completa de historial
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Historial completo próximamente'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _goToSavedCards() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedCardsScreen(),
      ),
    );
  }

  void _showStatistics() {
    // TODO: Implementar pantalla de estadísticas
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estadísticas próximamente'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }
}
