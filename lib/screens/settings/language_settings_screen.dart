import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  _LanguageSettingsScreenState createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'es';
  bool _isLoading = true;

  final List<Map<String, dynamic>> _languages = [
    {
      'code': 'es',
      'name': 'Español',
      'nativeName': 'Español',
      'flag': '🇪🇸',
      'description': 'Idioma principal de la aplicación',
    },
    {
      'code': 'en',
      'name': 'English',
      'nativeName': 'English',
      'flag': '🇺🇸',
      'description': 'English language support',
    },
    {
      'code': 'fr',
      'name': 'Français',
      'nativeName': 'Français',
      'flag': '🇫🇷',
      'description': 'Support de la langue française',
    },
    {
      'code': 'pt',
      'name': 'Português',
      'nativeName': 'Português',
      'flag': '🇧🇷',
      'description': 'Suporte para português brasileiro',
    },
    {
      'code': 'it',
      'name': 'Italiano',
      'nativeName': 'Italiano',
      'flag': '🇮🇹',
      'description': 'Supporto per la lingua italiana',
    },
    {
      'code': 'de',
      'name': 'Deutsch',
      'nativeName': 'Deutsch',
      'flag': '🇩🇪',
      'description': 'Deutsche Sprachunterstützung',
    },
    {
      'code': 'zh',
      'name': '中文',
      'nativeName': '中文',
      'flag': '🇨🇳',
      'description': '中文语言支持',
    },
    {
      'code': 'ja',
      'name': '日本語',
      'nativeName': '日本語',
      'flag': '🇯🇵',
      'description': '日本語サポート',
    },
    {
      'code': 'ko',
      'name': '한국어',
      'nativeName': '한국어',
      'flag': '🇰🇷',
      'description': '한국어 지원',
    },
    {
      'code': 'ar',
      'name': 'العربية',
      'nativeName': 'العربية',
      'flag': '🇸🇦',
      'description': 'دعم اللغة العربية',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('selected_language') ?? 'es';
      setState(() {
        _selectedLanguage = savedLanguage;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando idioma: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', languageCode);
      setState(() {
        _selectedLanguage = languageCode;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Idioma cambiado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error guardando idioma: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar idioma'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Fondo general oficial Cubalink23
      appBar: AppBar(
        backgroundColor: Color(0xFF37474F), // Header oficial Cubalink23
        title: Text(
          'Configuración de Idioma',
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
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: _applyLanguage,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF37474F), // Header oficial Cubalink23
              ),
            )
          : _buildLanguageList(),
    );
  }

  Widget _buildLanguageList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _languages.length,
      itemBuilder: (context, index) {
        final language = _languages[index];
        final isSelected = _selectedLanguage == language['code'];
        
        return _buildLanguageItem(language, isSelected);
      },
    );
  }

  Widget _buildLanguageItem(Map<String, dynamic> language, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _saveLanguage(language['code']),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF2E7D32).withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Color(0xFF2E7D32) : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                _buildFlagContainer(language['flag']),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            language['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Color(0xFF2E7D32) : Colors.grey[800],
                            ),
                          ),
                          if (language['code'] == 'es') ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'PREDETERMINADO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        language['nativeName'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        language['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlagContainer(String flag) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Text(
          flag,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  void _applyLanguage() {
    // TODO: Implementar lógica para aplicar el idioma seleccionado
    // Esto podría incluir:
    // 1. Recargar la app con el nuevo idioma
    // 2. Actualizar todas las cadenas de texto
    // 3. Guardar la configuración en el backend
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Idioma aplicado. Reinicia la app para ver los cambios completos.'),
        backgroundColor: Color(0xFF2E7D32),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Reiniciar',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Implementar reinicio de la app
          },
        ),
      ),
    );
  }
}




