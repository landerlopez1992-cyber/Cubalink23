import 'package:flutter/material.dart';
import 'package:cubalink23/services/supabase_service.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/models/recharge_history.dart';
// Removed unused import: package:cubalink23/models/order.dart
import 'package:cubalink23/services/auth_guard_service.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<RechargeTransaction> activities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
  }

  Future<void> _checkAuthAndLoad() async {
    final hasAuth = await AuthGuardService.instance.requireAuth(context, serviceName: 'la Actividad');
    if (hasAuth) {
      _loadUserActivity();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _loadUserActivity() async {
    try {
      setState(() => isLoading = true);
      
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser != null) {
        print('=== LOADING ACTIVITY FOR USER: ${currentUser.id} ===');
        
        final List<RechargeTransaction> loadedActivities = [];
        
        // 1. Cargar historial de recargas reales
        final recharges = await SupabaseService.instance.getUserRechargeHistoryRaw(currentUser.id);
        print('📱 Recharges loaded: ${recharges.length}');
        
        for (final recharge in recharges) {
          loadedActivities.add(RechargeTransaction(
            id: recharge['id'] ?? '',
            recipientPhone: recharge['phone_number'] ?? '',
            recipientName: 'Recarga a ${recharge['phone_number']}',
            countryCode: recharge['country_code'] ?? 'CU',
            operatorId: recharge['operator'] ?? 'cubacel',
            amount: (recharge['amount'] ?? 0.0).toDouble(),
            cost: (recharge['amount'] ?? 0.0).toDouble(),
            status: recharge['status'] == 'completed' ? RechargeStatus.completed : RechargeStatus.failed,
            paymentMethod: PaymentMethod.creditCard,
            createdAt: DateTime.parse(recharge['created_at'] ?? DateTime.now().toIso8601String()),
            completedAt: DateTime.parse(recharge['created_at'] ?? DateTime.now().toIso8601String()),
          ));
        }
        
        // 2. Cargar órdenes reales
        final orders = await SupabaseService.instance.getUserOrdersRaw(currentUser.id);
        print('🛒 Orders loaded: ${orders.length}');
        
        for (final order in orders) {
          final orderStatus = order['order_status'] ?? 'pending';
          loadedActivities.add(RechargeTransaction(
            id: order['id'] ?? '',
            recipientPhone: 'Orden ${order['order_number'] ?? ''}',
            recipientName: 'Compra Amazon - ${order['total'] ?? 0}',
            countryCode: 'ORDER',
            operatorId: 'amazon',
            amount: (order['total'] ?? 0.0).toDouble(),
            cost: (order['total'] ?? 0.0).toDouble(),
            status: orderStatus == 'delivered' ? RechargeStatus.completed : RechargeStatus.pending,
            paymentMethod: order['payment_method'] == 'zelle' ? PaymentMethod.bankTransfer : PaymentMethod.creditCard,
            createdAt: DateTime.parse(order['created_at'] ?? DateTime.now().toIso8601String()),
            completedAt: DateTime.parse(order['updated_at'] ?? order['created_at'] ?? DateTime.now().toIso8601String()),
          ));
        }
        
        // 3. Cargar transferencias reales
        final transfers = await SupabaseService.instance.getUserTransfers(currentUser.id);
        print('💸 Transfers loaded: ${transfers.length}');
        
        for (final transfer in transfers) {
          final direction = transfer['direction'] ?? 'sent';
          loadedActivities.add(RechargeTransaction(
            id: transfer['id'] ?? '',
            recipientPhone: transfer['phone_number'] ?? 'N/A',
            recipientName: '${direction == 'sent' ? 'Envío a' : 'Recibido de'} ${transfer['recipient_name'] ?? 'Usuario'}',
            countryCode: 'TRANSFER',
            operatorId: direction == 'sent' ? 'envio_saldo' : 'recibo_saldo',
            amount: (transfer['amount'] ?? 0.0).toDouble(),
            cost: (transfer['amount'] ?? 0.0).toDouble(),
            status: transfer['status'] == 'completed' ? RechargeStatus.completed : RechargeStatus.failed,
            paymentMethod: PaymentMethod.wallet,
            createdAt: DateTime.parse(transfer['created_at'] ?? DateTime.now().toIso8601String()),
            completedAt: DateTime.parse(transfer['created_at'] ?? DateTime.now().toIso8601String()),
          ));
        }
        
        // Ordenar actividades por fecha
        loadedActivities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        print('📈 TOTAL ACTIVITIES: ${loadedActivities.length}');
        
        setState(() {
          activities = loadedActivities;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ ERROR LOADING ACTIVITY: $e');
      setState(() {
        activities = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Fondo general oficial Cubalink23
      appBar: AppBar(
        backgroundColor: Color(0xFF37474F), // Header oficial Cubalink23
        title: Text(
          'Mi Actividad',
          style: TextStyle(
            color: Colors.white, // Texto sobre header oficial
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white, // Texto sobre header oficial
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white, // Texto sobre header oficial
            ),
            onPressed: _loadUserActivity,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF37474F), // Header oficial Cubalink23
              ),
            )
          : activities.isEmpty
              ? _buildEmptyState()
              : _buildActivityList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              size: 60,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Sin actividad reciente',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Cuando realices recargas, aparecerán aquí',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/recharge'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Hacer Primera Recarga',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return RefreshIndicator(
      onRefresh: _loadUserActivity,
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _buildActivityCard(activity);
        },
      ),
    );
  }

  Widget _buildActivityCard(RechargeTransaction activity) {
    final isSuccess = activity.status == RechargeStatus.completed;
    final statusColor = isSuccess ? Colors.green : Colors.red;
    final statusIcon = isSuccess ? Icons.check_circle : Icons.error;

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
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      activity.statusText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatDate(activity.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getActivityIcon(activity),
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.recipientPhone,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${activity.operatorId} - ${activity.paymentMethodText}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${activity.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes} min';
      }
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  IconData _getActivityIcon(RechargeTransaction activity) {
    if (activity.countryCode == 'ORDER') {
      return Icons.shopping_bag;
    } else if (activity.countryCode == 'TRANSFER') {
      return Icons.swap_horiz;
    } else {
      return Icons.phone_android;
    }
  }
}