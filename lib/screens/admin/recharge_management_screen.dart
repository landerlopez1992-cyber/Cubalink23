import 'package:flutter/material.dart';

class RechargeRecord {
  String id;
  String userId;
  String userEmail;
  String userName;
  String phoneNumber;
  String operator;
  String country;
  double amount;
  String status; // 'pending', 'processing', 'completed', 'failed', 'refunded'
  DateTime requestDate;
  DateTime? completedDate;
  String? failureReason;
  String transactionId;

  RechargeRecord({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.phoneNumber,
    required this.operator,
    required this.country,
    required this.amount,
    required this.status,
    required this.requestDate,
    this.completedDate,
    this.failureReason,
    required this.transactionId,
  });
}

class RechargeManagementScreen extends StatefulWidget {
  const RechargeManagementScreen({super.key});

  @override
  _RechargeManagementScreenState createState() => _RechargeManagementScreenState();
}

class _RechargeManagementScreenState extends State<RechargeManagementScreen> {
  List<RechargeRecord> _allRecharges = [];
  List<RechargeRecord> _filteredRecharges = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadSampleData();
    _filteredRecharges = _allRecharges;
  }

  void _loadSampleData() {
    // ELIMINADO: Todos los datos falsos de ejemplo removidos
    _allRecharges = [];
    print('⚠️ [ADMIN] DEMO DATA ELIMINADO - Solo datos reales de Firebase');
  }

  void _filterRecharges() {
    setState(() {
      _filteredRecharges = _allRecharges.where((recharge) {
        bool matchesSearch = _searchController.text.isEmpty ||
            recharge.userName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            recharge.userEmail.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            recharge.phoneNumber.contains(_searchController.text) ||
            recharge.transactionId.toLowerCase().contains(_searchController.text.toLowerCase());

        bool matchesStatus = _selectedStatus == 'all' || recharge.status == _selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _changeRechargeStatus(RechargeRecord recharge, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cambiar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Cambiar estado de la recarga a "${_getStatusText(newStatus)}"?'),
            SizedBox(height: 8),
            Text('Transacción: ${recharge.transactionId}'),
            Text('Usuario: ${recharge.userName}'),
            Text('Teléfono: ${recharge.phoneNumber}'),
            Text('Monto: \$${recharge.amount.toStringAsFixed(2)}'),
            if (newStatus == 'failed') ...[
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Motivo del fallo (opcional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  recharge.failureReason = value;
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                recharge.status = newStatus;
                if (newStatus == 'completed') {
                  recharge.completedDate = DateTime.now();
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Estado actualizado a ${_getStatusText(newStatus)}')),
              );
            },
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _processRefund(RechargeRecord recharge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Procesar Reembolso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Procesar reembolso para esta recarga?'),
            SizedBox(height: 8),
            Text('Usuario: ${recharge.userName}'),
            Text('Monto: \$${recharge.amount.toStringAsFixed(2)}'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity( 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'El monto será devuelto a la billetera del usuario.',
                style: TextStyle(color: Colors.orange[800]),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              setState(() {
                recharge.status = 'refunded';
                recharge.completedDate = DateTime.now();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Reembolso procesado exitosamente')),
              );
            },
            child: Text('Procesar Reembolso'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'PENDIENTE';
      case 'processing':
        return 'PROCESANDO';
      case 'completed':
        return 'COMPLETADA';
      case 'failed':
        return 'FALLIDA';
      case 'refunded':
        return 'REEMBOLSADA';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Text(
          'Gestión de Recargas',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : double.infinity),
              child: Column(
                children: [
                  // Filtros y búsqueda
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.grey[600]),
                                SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Buscar por nombre, email, teléfono o ID...',
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (_) => _filterRecharges(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: DropdownButton<String>(
                              value: _selectedStatus,
                              isExpanded: true,
                              underline: SizedBox(),
                              items: [
                                DropdownMenuItem(value: 'all', child: Text('Todos los estados')),
                                DropdownMenuItem(value: 'pending', child: Text('Pendientes')),
                                DropdownMenuItem(value: 'processing', child: Text('Procesando')),
                                DropdownMenuItem(value: 'completed', child: Text('Completadas')),
                                DropdownMenuItem(value: 'failed', child: Text('Fallidas')),
                                DropdownMenuItem(value: 'refunded', child: Text('Reembolsadas')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value!;
                                });
                                _filterRecharges();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  
                  // Estadísticas
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text('Total', style: TextStyle(fontSize: 14)),
                                Text('${_allRecharges.length}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text('Pendientes', style: TextStyle(fontSize: 14)),
                                Text('${_allRecharges.where((r) => r.status == 'pending').length}',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text('Completadas', style: TextStyle(fontSize: 14)),
                                Text('${_allRecharges.where((r) => r.status == 'completed').length}',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text('Fallidas', style: TextStyle(fontSize: 14)),
                                Text('${_allRecharges.where((r) => r.status == 'failed').length}',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  
                  // Lista de recargas
                  Card(
                    elevation: 2,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity( 0.1),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.phone_android, color: Theme.of(context).colorScheme.primary),
                              SizedBox(width: 12),
                              Text(
                                'Recargas (${_filteredRecharges.length})',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        if (_filteredRecharges.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'No se encontraron recargas',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _filteredRecharges.length,
                            separatorBuilder: (context, index) => Divider(height: 1),
                            itemBuilder: (context, index) {
                              final recharge = _filteredRecharges[index];
                              return ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(recharge.status).withOpacity( 0.2),
                                  child: Icon(
                                    Icons.phone_android,
                                    color: _getStatusColor(recharge.status),
                                  ),
                                ),
                                title: Text(
                                  '${recharge.userName} - ${recharge.phoneNumber}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${recharge.operator} (${recharge.country}) - \$${recharge.amount.toStringAsFixed(2)}'),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(recharge.status),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _getStatusText(recharge.status),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'ID: ${recharge.transactionId}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  _formatDateTime(recharge.requestDate),
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Información Detallada:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  SizedBox(height: 8),
                                                  Text('Usuario: ${recharge.userEmail}'),
                                                  Text('Teléfono: ${recharge.phoneNumber}'),
                                                  Text('Operador: ${recharge.operator}'),
                                                  Text('País: ${recharge.country}'),
                                                  Text('Monto: \$${recharge.amount.toStringAsFixed(2)}'),
                                                  Text('Solicitado: ${_formatDateTime(recharge.requestDate)}'),
                                                  if (recharge.completedDate != null)
                                                    Text('Completado: ${_formatDateTime(recharge.completedDate!)}'),
                                                  if (recharge.failureReason != null)
                                                    Text('Motivo fallo: ${recharge.failureReason}', style: TextStyle(color: Colors.red)),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Column(
                                              children: [
                                                if (recharge.status == 'pending') ...[
                                                  ElevatedButton.icon(
                                                    onPressed: () => _changeRechargeStatus(recharge, 'processing'),
                                                    icon: Icon(Icons.play_arrow),
                                                    label: Text('Procesar'),
                                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                                  ),
                                                  SizedBox(height: 8),
                                                  ElevatedButton.icon(
                                                    onPressed: () => _changeRechargeStatus(recharge, 'failed'),
                                                    icon: Icon(Icons.close),
                                                    label: Text('Marcar Fallida'),
                                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  ),
                                                ],
                                                if (recharge.status == 'processing') ...[
                                                  ElevatedButton.icon(
                                                    onPressed: () => _changeRechargeStatus(recharge, 'completed'),
                                                    icon: Icon(Icons.check),
                                                    label: Text('Completar'),
                                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                                  ),
                                                  SizedBox(height: 8),
                                                  ElevatedButton.icon(
                                                    onPressed: () => _changeRechargeStatus(recharge, 'failed'),
                                                    icon: Icon(Icons.close),
                                                    label: Text('Marcar Fallida'),
                                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  ),
                                                ],
                                                if (recharge.status == 'failed' || recharge.status == 'completed') ...[
                                                  ElevatedButton.icon(
                                                    onPressed: () => _processRefund(recharge),
                                                    icon: Icon(Icons.money_off),
                                                    label: Text('Reembolsar'),
                                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}