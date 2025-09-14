import 'package:flutter/material.dart';
import 'package:cubalink23/models/user.dart';

class Transaction {
  String id;
  String userId;
  String userEmail;
  String userName;
  double amount;
  String type; // 'add', 'subtract', 'transfer'
  String description;
  DateTime date;
  String adminEmail;

  Transaction({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    required this.adminEmail,
  });
}

class WalletManagementScreen extends StatefulWidget {
  const WalletManagementScreen({super.key});

  @override
  _WalletManagementScreenState createState() => _WalletManagementScreenState();
}

class _WalletManagementScreenState extends State<WalletManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  List<Transaction> _transactions = [];
  User? _selectedUser;

  @override
  void initState() {
    super.initState();
    _loadSampleData();
    _filteredUsers = _allUsers;
  }

  void _loadSampleData() {
    // ELIMINADO: Todos los datos falsos de ejemplo removidos
    _allUsers = [];
    _transactions = [];
    print('⚠️ [ADMIN] DEMO DATA ELIMINADO - Solo datos reales de Firebase');
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_allUsers);
      } else {
        _filteredUsers = _allUsers.where((user) {
          return user.name.toLowerCase().contains(query.toLowerCase()) ||
                 user.email.toLowerCase().contains(query.toLowerCase()) ||
                 user.phone.contains(query);
        }).toList();
      }
    });
  }

  void _selectUser(User user) {
    setState(() {
      _selectedUser = user;
    });
  }

  void _addBalance(User user) {
    _showBalanceDialog(user, 'add');
  }

  void _subtractBalance(User user) {
    _showBalanceDialog(user, 'subtract');
  }

  void _showBalanceDialog(User user, String type) {
    TextEditingController amountController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == 'add' ? 'Agregar Saldo' : 'Quitar Saldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Usuario: ${user.name}'),
            Text('Saldo actual: \$${user.balance.toStringAsFixed(2)}'),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Cantidad (\$)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(type == 'add' ? Icons.add : Icons.remove),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
                hintText: 'Motivo del ajuste...',
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
            style: ElevatedButton.styleFrom(
              backgroundColor: type == 'add' ? Colors.green : Colors.red,
            ),
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                setState(() {
                  if (type == 'add') {
                    user.balance += amount;
                  } else {
                    user.balance = (user.balance - amount).clamp(0.0, double.infinity);
                  }

                  // Agregar transacción
                  final transaction = Transaction(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: user.id,
                    userEmail: user.email,
                    userName: user.name,
                    amount: amount,
                    type: type,
                    description: descriptionController.text.isEmpty 
                        ? (type == 'add' ? 'Saldo agregado por administrador' : 'Saldo descontado por administrador')
                        : descriptionController.text,
                    date: DateTime.now(),
                    adminEmail: 'landerlopez1992@gmail.com',
                  );
                  _transactions.insert(0, transaction);
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      type == 'add' 
                          ? 'Saldo agregado exitosamente' 
                          : 'Saldo descontado exitosamente'
                    ),
                  ),
                );
              }
            },
            child: Text(type == 'add' ? 'Agregar' : 'Quitar'),
          ),
        ],
      ),
    );
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
          'Gestión de Billetera',
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Panel izquierdo - Lista de usuarios
                  Expanded(
                    flex: isDesktop ? 1 : 1,
                    child: Column(
                      children: [
                        // Barra de búsqueda
                        Card(
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
                                      hintText: 'Buscar cliente...',
                                      border: InputBorder.none,
                                    ),
                                    onChanged: _filterUsers,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Estadísticas rápidas
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Text('Total Usuarios', style: TextStyle(fontSize: 12)),
                                      Text('${_allUsers.length}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                                      Text('Saldo Total', style: TextStyle(fontSize: 12)),
                                      Text('\$${_allUsers.fold(0.0, (sum, user) => sum + user.balance).toStringAsFixed(2)}',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        
                        // Lista de usuarios
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
                                    Icon(Icons.people, color: Theme.of(context).colorScheme.primary),
                                    SizedBox(width: 12),
                                    Text(
                                      'Clientes (${_filteredUsers.length})',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: isDesktop ? 400 : 300,
                                child: ListView.separated(
                                  itemCount: _filteredUsers.length,
                                  separatorBuilder: (context, index) => Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final user = _filteredUsers[index];
                                    final isSelected = _selectedUser?.id == user.id;
                                    return ListTile(
                                      selected: isSelected,
                                      selectedColor: Theme.of(context).colorScheme.primary,
                                      onTap: () => _selectUser(user),
                                      leading: CircleAvatar(
                                        backgroundColor: isSelected 
                                            ? Theme.of(context).colorScheme.primary 
                                            : Theme.of(context).colorScheme.primary.withOpacity( 0.2),
                                        child: Icon(
                                          Icons.person,
                                          color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      title: Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(user.email),
                                      trailing: Text(
                                        '\$${user.balance.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: user.balance > 0 ? Colors.green : Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (isDesktop) SizedBox(width: 24),
                  
                  // Panel derecho - Detalles y acciones
                  if (isDesktop || _selectedUser != null)
                    Expanded(
                      flex: isDesktop ? 1 : 1,
                      child: Column(
                        children: [
                          if (_selectedUser != null) ...[
                            // Información del usuario seleccionado
                            Card(
                              elevation: 4,
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity( 0.2),
                                      child: Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      _selectedUser!.name,
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _selectedUser!.email,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity( 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Saldo Actual',
                                            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                          ),
                                          Text(
                                            '\$${_selectedUser!.balance.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _addBalance(_selectedUser!),
                                            icon: Icon(Icons.add),
                                            label: Text('Agregar Saldo'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _subtractBalance(_selectedUser!),
                                            icon: Icon(Icons.remove),
                                            label: Text('Quitar Saldo'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                          ],
                          
                          // Historial de transacciones recientes
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
                                      Icon(Icons.history, color: Theme.of(context).colorScheme.primary),
                                      SizedBox(width: 12),
                                      Text(
                                        'Transacciones Recientes',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 300,
                                  child: _transactions.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No hay transacciones',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        )
                                      : ListView.separated(
                                          itemCount: _transactions.length,
                                          separatorBuilder: (context, index) => Divider(height: 1),
                                          itemBuilder: (context, index) {
                                            final transaction = _transactions[index];
                                            final isAdd = transaction.type == 'add';
                                            return ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: isAdd ? Colors.green.withOpacity( 0.2) : Colors.red.withOpacity( 0.2),
                                                child: Icon(
                                                  isAdd ? Icons.add : Icons.remove,
                                                  color: isAdd ? Colors.green : Colors.red,
                                                ),
                                              ),
                                              title: Text(transaction.userName),
                                              subtitle: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(transaction.description),
                                                  Text(
                                                    '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                              trailing: Text(
                                                '${isAdd ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isAdd ? Colors.green : Colors.red,
                                                ),
                                              ),
                                              isThreeLine: true,
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
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