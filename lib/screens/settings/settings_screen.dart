import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cubalink23/models/user.dart';
import 'package:cubalink23/screens/admin/admin_screen.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _pushNotifications = true;
  bool _emailPromotions = true;
  String _currentLanguage = 'Español';
  bool _isAdmin = false;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload settings when screen becomes visible again
    _loadSettings();
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Reload user data from Supabase to get updated role
    await SupabaseAuthService.instance.loadCurrentUserData();
    final currentUser = SupabaseAuthService.instance.currentUser;
    
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _emailPromotions = prefs.getBool('email_promotions') ?? true;
      _currentLanguage = prefs.getString('language') ?? 'Español';
      _userEmail = currentUser?.email ?? '';
      
      // Check admin status from current user's role (from Supabase)
      _isAdmin = currentUser?.role == 'admin' || User.isAdminEmail(_userEmail);
      
      print('📊 Usuario actual: ${currentUser?.name}, Email: $_userEmail, Role: ${currentUser?.role}, IsAdmin: $_isAdmin');
    });
  }

  _saveSetting(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Text(
          'Ajustes',
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
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Botón de Administración (solo visible para admins)
          if (_isAdmin) ...[
            Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withOpacity( 0.1),
                      Colors.orange.withOpacity( 0.05),
                    ],
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.orange,
                    size: 28,
                  ),
                  title: Text(
                    'Administración',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.orange[800],
                    ),
                  ),
                  subtitle: Text(
                    'Panel de control administrativo',
                    style: TextStyle(
                      color: Colors.orange[600],
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.orange,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          
          // Idioma
          Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Icon(
                Icons.language,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Idioma',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(_currentLanguage),
              trailing: Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(),
            ),
          ),
          
          // Modo día/noche
          Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 16),
            child: SwitchListTile(
              secondary: Icon(
                _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Modo Oscuro',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(_isDarkMode ? 'Activado' : 'Desactivado'),
              value: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                });
                _saveSetting('dark_mode', value);
              },
              activeThumbColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          
          // Notificaciones push
          Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 16),
            child: SwitchListTile(
              secondary: Icon(
                Icons.notifications,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Notificaciones Push',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(_pushNotifications ? 'Activadas' : 'Desactivadas'),
              value: _pushNotifications,
              onChanged: (bool value) {
                setState(() {
                  _pushNotifications = value;
                });
                _saveSetting('push_notifications', value);
                
                // Mostrar confirmación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value 
                        ? 'Notificaciones push activadas'
                        : 'Notificaciones push desactivadas'
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              activeThumbColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          
          // Emails promocionales
          Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 16),
            child: SwitchListTile(
              secondary: Icon(
                Icons.email,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Emails Promocionales',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(_emailPromotions ? 'Activados' : 'Desactivados'),
              value: _emailPromotions,
              onChanged: (bool value) {
                setState(() {
                  _emailPromotions = value;
                });
                _saveSetting('email_promotions', value);
                
                // Mostrar confirmación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value 
                        ? 'Emails promocionales activados'
                        : 'Emails promocionales desactivados'
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              activeThumbColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Idioma'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Español'),
                leading: Radio<String>(
                  value: 'Español',
                  groupValue: _currentLanguage,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _currentLanguage = value;
                      });
                      _saveSetting('language', value);
                      Navigator.of(context).pop();
                      
                      // Mostrar confirmación
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Idioma cambiado a Español'),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                  },
                ),
              ),
              ListTile(
                title: Text('English'),
                leading: Radio<String>(
                  value: 'English',
                  groupValue: _currentLanguage,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _currentLanguage = value;
                      });
                      _saveSetting('language', value);
                      Navigator.of(context).pop();
                      
                      // Mostrar confirmación
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Language changed to English'),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}