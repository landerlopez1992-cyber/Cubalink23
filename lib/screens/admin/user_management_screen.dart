import 'package:flutter/material.dart';
import 'package:cubalink23/models/user.dart';
import 'package:cubalink23/services/supabase_service.dart';
import 'package:cubalink23/services/supabase_database_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  String _selectedStatus = 'Todos';
  // final FirebaseService _firebaseService = FirebaseService.instance; // Commented out for compilation

  @override
  void initState() {
    super.initState();
    _loadRealUsers();
  }

  // Cargar usuarios reales desde Supabase
  void _loadRealUsers() async {
    setState(() => _isLoading = true);
    
    try {
      // Cargar usuarios reales desde Supabase
      final supabaseService = SupabaseService.instance;
      final users = await supabaseService.getAllUsers();
      
      _allUsers = users;
      _filteredUsers = List.from(_allUsers);
      print('✅ Usuarios reales cargados desde Supabase: ${_allUsers.length}');
    } catch (e) {
      print('❌ Error loading users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cargando usuarios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() => _isLoading = false);
  }

  void _filterUsers(String query) {
    setState(() {
      List<User> filteredByStatus = _allUsers;
      
      // Filtrar por estado usando status field
      if (_selectedStatus == 'Activos') {
        filteredByStatus = _allUsers.where((user) => 
          (user.status ?? 'Activo') == 'Activo').toList();
      } else if (_selectedStatus == 'Bloqueados') {
        filteredByStatus = _allUsers.where((user) => 
          (user.status ?? 'Activo') == 'Bloqueado').toList();
      } else if (_selectedStatus == 'Administradores') {
        filteredByStatus = _allUsers.where((user) => user.role == 'Administrador').toList();
      }
      
      // Filtrar por búsqueda
      if (query.isEmpty) {
        _filteredUsers = filteredByStatus;
      } else {
        _filteredUsers = filteredByStatus.where((user) {
          return user.name.toLowerCase().contains(query.toLowerCase()) ||
                 user.email.toLowerCase().contains(query.toLowerCase()) ||
                 user.phone.contains(query) ||
                 (user.address?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  void _filterByStatus(String status) {
    setState(() {
      _selectedStatus = status;
      _filterUsers(_searchController.text);
    });
  }

  void _blockUser(User user) async {
    final isBlocked = (user.status ?? 'Activo') == 'Bloqueado';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isBlocked ? 'Desbloquear' : 'Bloquear'} Usuario'),
        content: Text('¿Estás seguro de ${isBlocked ? 'desbloquear' : 'bloquear'} a ${user.name}?${!isBlocked ? '\n\nEsta acción suspenderá temporalmente el acceso del usuario.' : '\n\nEsta acción restaurará el acceso del usuario.'}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocked ? Colors.green : Colors.orange,
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final newStatus = isBlocked ? 'Activo' : 'Bloqueado';
                // Actualizar estado real en Supabase
                await SupabaseDatabaseService.instance.updateUserStatus(user.id, newStatus);
                
                setState(() {
                  final index = _allUsers.indexWhere((u) => u.id == user.id);
                  if (index != -1) {
                    _allUsers[index] = _allUsers[index].copyWith(status: newStatus);
                    _filterUsers(_searchController.text);
                  }
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Usuario ${newStatus == 'Bloqueado' ? 'bloqueado' : 'desbloqueado'} exitosamente (simulado)'),
                    backgroundColor: newStatus == 'Bloqueado' ? Colors.orange : Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error actualizando usuario: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(isBlocked ? 'Desbloquear' : 'Suspender'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Usuario'),
        content: Text('¿Estás seguro de eliminar permanentemente a ${user.name}? Esta acción no se puede deshacer y eliminará todos los datos asociados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Eliminar usuario real de Supabase
                await SupabaseDatabaseService.instance.deleteUserAccount(user.id);
                setState(() {
                  _allUsers.removeWhere((u) => u.id == user.id);
                  _filterUsers(_searchController.text);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Usuario eliminado exitosamente (simulado)'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error eliminando usuario: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _sendMessage(User user) {
    TextEditingController messageController = TextEditingController();
    String selectedType = 'Información';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Enviar Mensaje Administrativo'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: user.profileImageUrl != null 
                        ? NetworkImage(user.profileImageUrl!) 
                        : null,
                      child: user.profileImageUrl == null 
                        ? Icon(Icons.person) 
                        : null,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(user.email, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Mensaje',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Información', 'Advertencia', 'Promoción', 'Soporte'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedType = value!;
                    });
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Mensaje',
                    border: OutlineInputBorder(),
                    hintText: 'Escribe tu mensaje aquí...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (messageController.text.isNotEmpty) {
                  Navigator.pop(context);
                  try {
                    final fullMessage = '[$selectedType] ${messageController.text}';
                    // Enviar mensaje real a través de Supabase
                    await SupabaseDatabaseService.instance.sendAdminMessage(user.id, fullMessage);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mensaje "$selectedType" enviado exitosamente a ${user.name}'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error enviando mensaje: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  void _changeUserRole(User user) {
    String selectedRole = user.role;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Cambiar Rol de Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: user.profileImageUrl != null 
                      ? NetworkImage(user.profileImageUrl!) 
                      : null,
                    child: user.profileImageUrl == null 
                      ? Icon(Icons.person) 
                      : null,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Rol actual: ${_getRoleDisplayName(user.role)}'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Nuevo Rol',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'Usuario', child: Text('Usuario')),
                  DropdownMenuItem(value: 'Administrador', child: Text('Administrador')),
                  DropdownMenuItem(value: 'Repartidor', child: Text('Repartidor')),
                  DropdownMenuItem(value: 'Vendedor', child: Text('Vendedor')),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedRole = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  // Actualizar rol real en Supabase
                  await SupabaseService.instance.updateUserRole(user.email, selectedRole);
                  setState(() {
                    final userIndex = _allUsers.indexWhere((u) => u.id == user.id);
                    if (userIndex != -1) {
                      _allUsers[userIndex] = _allUsers[userIndex].copyWith(role: selectedRole);
                      _filterUsers(_searchController.text);
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Rol cambiado exitosamente a ${_getRoleDisplayName(selectedRole)}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error cambiando rol: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'Administrador': return 'Administrador';
      case 'Repartidor': return 'Repartidor';
      case 'Vendedor': return 'Vendedor';
      default: return 'Usuario';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Administrador': return Colors.red;
      case 'Repartidor': return Colors.blue;
      case 'Vendedor': return Colors.purple;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 2,
        title: Text(
          'Gestión de Usuarios',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 1400 : double.infinity),
            child: Column(
              children: [
                // Header con estadísticas
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity( 0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildStatCard('Total', '${_allUsers.length}', Icons.group, Colors.blue),
                      SizedBox(width: 16),
                      _buildStatCard('Activos', '${_allUsers.where((u) => (u.status ?? 'Activo') == 'Activo').length}', Icons.check_circle, Colors.green),
                      SizedBox(width: 16),
                      _buildStatCard('Bloqueados', '${_allUsers.where((u) => (u.status ?? 'Activo') == 'Bloqueado').length}', Icons.block, Colors.red),
                      SizedBox(width: 16),
                      _buildStatCard('Admins', '${_allUsers.where((u) => u.role == 'Administrador').length}', Icons.admin_panel_settings, Colors.purple),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                
                // Barra de búsqueda y filtros
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity( 0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Barra de búsqueda
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar usuarios por nombre, email, teléfono...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        onChanged: _filterUsers,
                      ),
                      SizedBox(height: 16),
                      
                      // Filtros
                      Row(
                        children: [
                          Text('Filtros:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _buildFilterChip('Todos', _selectedStatus == 'Todos', Colors.grey),
                                _buildFilterChip('Activos', _selectedStatus == 'Activos', Colors.green),
                                _buildFilterChip('Bloqueados', _selectedStatus == 'Bloqueados', Colors.red),
                                _buildFilterChip('Administradores', _selectedStatus == 'Administradores', Colors.purple),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                
                // Lista de usuarios
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity( 0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header de la lista
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity( 0.1),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.people_outline, color: Theme.of(context).colorScheme.primary),
                              SizedBox(width: 8),
                              Text(
                                'Usuarios Registrados (${_filteredUsers.length})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Lista
                        Expanded(
                          child: _isLoading
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text('Cargando usuarios desde Firebase...', 
                                         style: TextStyle(color: Colors.grey[600])),
                                  ],
                                ),
                              )
                            : _filteredUsers.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                                      SizedBox(height: 16),
                                      Text(
                                        'No se encontraron usuarios',
                                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: _loadRealUsers,
                                        child: Text('Recargar'),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  padding: EdgeInsets.all(8),
                                  itemCount: _filteredUsers.length,
                                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                                  itemBuilder: (context, index) {
                                    final user = _filteredUsers[index];
                                    return _buildUserTile(user);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity( 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity( 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Color color) {
    return GestureDetector(
      onTap: () => _filterByStatus(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildUserTile(User user) {
    final isBlocked = (user.status ?? 'Activo') == 'Bloqueado';
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBlocked ? Colors.red[50] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBlocked ? Colors.red[200]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          // Avatar con indicadores
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isBlocked ? Colors.red[100] : Colors.grey[200],
                backgroundImage: user.profileImageUrl != null 
                  ? NetworkImage(user.profileImageUrl!) 
                  : null,
                child: user.profileImageUrl == null
                  ? Icon(
                      Icons.person,
                      color: isBlocked ? Colors.red : Colors.grey[600],
                      size: 20,
                    )
                  : null,
              ),
              if (user.role != 'Usuario')
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Icon(
                      user.role == 'Administrador' ? Icons.admin_panel_settings
                        : user.role == 'Repartidor' ? Icons.delivery_dining
                        : Icons.store,
                      size: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16),
          
          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre y rol
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isBlocked ? Colors.red[700] : Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getRoleDisplayName(user.role),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                
                // Email
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        user.email,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                
                // Teléfono y saldo
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Text(
                      user.phone,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    SizedBox(width: 20),
                    Icon(Icons.account_balance_wallet_outlined, size: 14, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      '\$${(user.balance ?? 0.0).toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green[700]),
                    ),
                  ],
                ),
                if (user.address != null) ...[
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          user.address!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Estado y acciones
          Column(
            children: [
              if (isBlocked)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'SUSPENDIDO',
                    style: TextStyle(
                      color: Colors.red[800],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              SizedBox(height: 8),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'message': _sendMessage(user); break;
                    case 'role': _changeUserRole(user); break;
                    case 'block': _blockUser(user); break;
                    case 'delete': _deleteUser(user); break;
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.more_vert, size: 16, color: Colors.grey[600]),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'message',
                    child: Row(
                      children: [
                        Icon(Icons.message_outlined, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Enviar Mensaje', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'role',
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings_outlined, size: 16, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('Cambiar Rol', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        Icon(
                          isBlocked ? Icons.check_circle_outline : Icons.block_outlined, 
                          size: 16, 
                          color: isBlocked ? Colors.green : Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Text(
                          isBlocked ? 'Activar Usuario' : 'Suspender Usuario',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(fontSize: 14, color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}