import 'package:flutter/material.dart';
import 'package:cubalink23/models/user.dart' as UserModel;
import 'package:cubalink23/models/recharge_history.dart';
import 'package:cubalink23/services/firebase_repository.dart';
// REMOVED: import 'package:firebase_auth/firebase_auth.dart' hide User;
// REMOVED: import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';

class HistoryScreen extends StatefulWidget {
  final UserModel.User? user;

  const HistoryScreen({super.key, this.user});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<RechargeTransaction> _transactions = [];
  String _selectedFilter = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      setState(() => _isLoading = true);
      
      // TEMPORALMENTE DESHABILITADO MIENTRAS SE MIGRA A SUPABASE
      setState(() {
        _transactions = [];
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading transactions: $e');
    }
  }

  Future<void> _deleteTransaction(RechargeTransaction transaction) async {
    try {
      final currentUser = null; // SupabaseAuthService.instance.getCurrentUser();
      if (currentUser != null) {
        setState(() {
          _transactions.removeWhere((t) => t.id == transaction.id);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Transacción eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<RechargeTransaction> get filteredTransactions {
    if (_selectedFilter == 'all') {
      return _transactions;
    } else if (_selectedFilter == 'completed') {
      return _transactions.where((t) => t.status == RechargeStatus.completed).toList();
    } else if (_selectedFilter == 'pending') {
      return _transactions.where((t) => t.status == RechargeStatus.pending).toList();
    } else if (_selectedFilter == 'failed') {
      return _transactions.where((t) => t.status == RechargeStatus.failed).toList();
    }
    return _transactions;
  }

  String _getOrderStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'payment_confirmed':
        return 'Pago Confirmado';
      case 'processing':
        return 'Procesando';
      case 'shipped':
        return 'Enviado';
      case 'in_transit':
        return 'En Tránsito';
      case 'delivered':
        return 'Entregado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Estado Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter buttons
          Container(
            color: Colors.blue[50],
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _selectedFilter = 'all'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedFilter == 'all' 
                        ? Colors.blue[600] 
                        : Colors.grey[200],
                      foregroundColor: _selectedFilter == 'all' 
                        ? Colors.white 
                        : Colors.black87,
                    ),
                    child: Text('Todas'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _selectedFilter = 'completed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedFilter == 'completed' 
                        ? Colors.green[600] 
                        : Colors.grey[200],
                      foregroundColor: _selectedFilter == 'completed' 
                        ? Colors.white 
                        : Colors.black87,
                    ),
                    child: Text('Completadas'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _selectedFilter = 'pending'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedFilter == 'pending' 
                        ? Colors.orange[600] 
                        : Colors.grey[200],
                      foregroundColor: _selectedFilter == 'pending' 
                        ? Colors.white 
                        : Colors.black87,
                    ),
                    child: Text('Pendientes'),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay transacciones',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Las transacciones aparecerán aquí',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTransactions,
                    child: ListView.builder(
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: transaction.status == RechargeStatus.completed
                                  ? Colors.green
                                  : transaction.status == RechargeStatus.pending
                                      ? Colors.orange
                                      : Colors.red,
                              child: Icon(
                                transaction.status == RechargeStatus.completed
                                    ? Icons.check
                                    : transaction.status == RechargeStatus.pending
                                        ? Icons.access_time
                                        : Icons.error,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(transaction.recipientName),
                            subtitle: Text(
                              '${transaction.recipientPhone} • ${transaction.statusText}',
                            ),
                            trailing: Text(
                              '\$${transaction.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: transaction.status == RechargeStatus.completed
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            onTap: () {
                              // Show transaction details
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}