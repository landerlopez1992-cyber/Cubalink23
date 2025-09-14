import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cubalink23/screens/admin/user_management_screen.dart';
import 'package:cubalink23/screens/admin/store_settings_screen.dart';
import 'package:cubalink23/screens/admin/wallet_management_screen.dart';
import 'package:cubalink23/screens/admin/support_chat_admin_screen.dart';
import 'package:cubalink23/screens/admin/recharge_management_screen.dart';
import 'package:cubalink23/screens/admin/travel_management_screen.dart';
import 'package:cubalink23/screens/admin/push_management_screen.dart';
import 'package:cubalink23/screens/admin/order_management_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String _currentUserEmail = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserEmail = prefs.getString('user_email') ?? '';
    });
  }

  bool _isMobileDevice(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 600;
  }

  Widget _buildMobileBlockedView() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Text(
          'Acceso Restringido',
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
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.desktop_access_disabled,
                size: 80,
                color: Colors.red[400],
              ),
              SizedBox(height: 24),
              Text(
                'Acceso No Permitido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'El panel de administración solo está disponible desde tablets, laptops o computadoras de escritorio.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text(
                'Por favor, accede desde un dispositivo con pantalla más grande para usar estas funciones.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back),
                label: Text('Regresar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bloquear acceso desde dispositivos móviles
    if (_isMobileDevice(context)) {
      return _buildMobileBlockedView();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    // Removed unused variable: isTablet
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Text(
          'Panel de Administración - Tu Recarga',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: isDesktop ? 20 : 18,
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
                  // Header del administrador actual
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isDesktop ? 24 : 20),
                    margin: EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity( 0.15),
                          Theme.of(context).colorScheme.primary.withOpacity( 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          color: Theme.of(context).colorScheme.primary,
                          size: isDesktop ? 48 : 40,
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Panel de Administración',
                                style: TextStyle(
                                  fontSize: isDesktop ? 24 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Administrador: $_currentUserEmail',
                                style: TextStyle(
                                  fontSize: isDesktop ? 16 : 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (isDesktop) ...[
                                SizedBox(height: 8),
                                Text(
                                  'Gestiona todos los aspectos del sistema Tu Recarga',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Grid de funciones administrativas específicas
                  isDesktop
                      ? _buildDesktopGrid()
                      : _buildTabletGrid(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      childAspectRatio: 1.2,
      children: [
        _buildAdminCard(
          icon: Icons.people_alt,
          title: 'Gestión de Usuarios',
          subtitle: 'Eliminar, bloquear\ny enviar mensajes\na usuarios',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => UserManagementScreen()),
          ),
        ),
        _buildAdminCard(
          icon: Icons.store,
          title: 'Ajustes de la Tienda',
          subtitle: 'Subir productos, precios,\nfotos y métodos de envío',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => StoreSettingsScreen()),
          ),
        ),
        _buildAdminCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Billetera',
          subtitle: 'Consultar saldo, enviar\ny quitar saldo a clientes',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => WalletManagementScreen()),
          ),
        ),
        _buildAdminCard(
          icon: Icons.support_agent,
          title: 'Soporte Chat',
          subtitle: 'Recibir y responder\nchats de clientes',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => SupportChatAdminScreen()),
          ),
        ),
        _buildAdminCard(
          icon: Icons.phone_android,
          title: 'Recargas',
          subtitle: 'Administrar estado\nde recargas de clientes',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => RechargeManagementScreen()),
          ),
        ),
        _buildAdminCard(
          icon: Icons.flight,
          title: 'Viajes',
          subtitle: 'Administrar estado\nde pasajes aéreos',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => TravelManagementScreen()),
          ),
        ),
        _buildAdminCard(
          icon: Icons.campaign,
          title: 'Push',
          subtitle: 'Gestionar banners\ny actualizaciones\nforzosas',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PushManagementScreen()),
          ),
        ),
        _buildAdminCard(
          icon: Icons.shopping_bag_outlined,
          title: 'Órdenes/Pedidos',
          subtitle: 'Administrar estados\nde órdenes, pagos\ny cancelaciones',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => OrderManagementScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildAdminCard(
          icon: Icons.people_alt,
          title: 'Gestión de Usuarios',
          subtitle: 'Eliminar, bloquear y enviar\nmensajes a usuarios',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => UserManagementScreen()),
          ),
        ),
        _buildAdminCard(
          icon: Icons.store,
          title: 'Ajustes de la Tienda',
          subtitle: 'Subir productos, precios\ny métodos de envío',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => StoreSettingsScreen()),
          ),
        ),
        _buildAdminCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Billetera',
          subtitle: 'Consultar y administrar\nsaldo de clientes',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => WalletManagementScreen()),
          ),
        ),
        _buildAdminCard(
          icon: Icons.support_agent,
          title: 'Soporte Chat',
          subtitle: 'Chat de soporte\ncon clientes',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => SupportChatAdminScreen()),
          ),
        ),
        _buildAdminCard(
          icon: Icons.phone_android,
          title: 'Recargas',
          subtitle: 'Administrar estado\nde recargas',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => RechargeManagementScreen()),
          ),
        ),
        _buildAdminCard(
          icon: Icons.flight,
          title: 'Viajes',
          subtitle: 'Administrar pasajes\naéreos',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => TravelManagementScreen()),
          ),
        ),
        _buildAdminCard(
          icon: Icons.campaign,
          title: 'Push',
          subtitle: 'Gestionar banners\ny actualizaciones\nforzosas',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PushManagementScreen()),
          ),
        ),
        _buildAdminCard(
          icon: Icons.shopping_bag_outlined,
          title: 'Órdenes/Pedidos',
          subtitle: 'Administrar estados\nde órdenes, pagos\ny cancelaciones',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => OrderManagementScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity( 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}