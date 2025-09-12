import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cubalink23/services/referral_service.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:intl/intl.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  _ReferralScreenState createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  bool _isLoading = true;
  String _referralCode = '';
  Map<String, dynamic> _stats = {};
  
  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }
  
  Future<void> _loadReferralData() async {
    try {
      setState(() => _isLoading = true);
      
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return;
      
      // Crear código de referido si no existe
      _referralCode = await ReferralService.instance.createReferralCode(
        currentUser.id, 
        currentUser.name
      );
      
      // Obtener estadísticas
      _stats = await ReferralService.instance.getReferralStats(currentUser.id);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando datos de referidos: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _copyReferralCode() {
    Clipboard.setData(ClipboardData(text: _referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('¡Código copiado!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _shareReferralCode() {
    final message = '''🎉 ¡Te invito a CubaLink23!

✨ Usa mi código de referido: $_referralCode

📱 Descarga CubaLink23 y úsalo al registrarte
💰 ¡Cuando hagas tu primera recarga ganamos \$5.00 cada uno!

🔗 Regístrate y empieza a ahorrar en recargas, viajes y compras Amazon.

¡Nos vemos en CubaLink23! 🚀''';

    Share.share(message, subject: 'Te invito a CubaLink23 - Código: $_referralCode');
  }
  
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    try {
      DateTime date;
      if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        date = timestamp.toDate();
      }
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Refiere y Gana',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadReferralData,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card
                    _buildHeaderCard(),
                    SizedBox(height: 20),
                    
                    // Referral Code Card
                    _buildReferralCodeCard(),
                    SizedBox(height: 20),
                    
                    // Stats Cards
                    _buildStatsCards(),
                    SizedBox(height: 20),
                    
                    // How it works
                    _buildHowItWorksCard(),
                    SizedBox(height: 20),
                    
                    // Referred Users List
                    _buildReferredUsersList(),
                    SizedBox(height: 20),
                    
                    // Reward History
                    _buildRewardHistoryCard(),
                  ],
                ),
              ),
      ),
    );
  }
  
  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.card_giftcard,
            size: 48,
            color: Colors.white,
          ),
          SizedBox(height: 12),
          Text(
            '¡Invita Amigos y Gana!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Comparte tu código y recibe \$5.00 cuando tus amigos hagan su primera compra',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildReferralCodeCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.qr_code, color: Theme.of(context).primaryColor, size: 28),
                SizedBox(width: 12),
                Text(
                  'Tu Código de Referido',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Código grande y visible
            Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Text(
                _referralCode.isNotEmpty ? _referralCode : 'Cargando...',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: 16),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _referralCode.isNotEmpty ? _copyReferralCode : null,
                    icon: Icon(Icons.copy, size: 20),
                    label: Text('Copiar'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _referralCode.isNotEmpty ? _shareReferralCode : null,
                    icon: Icon(Icons.share, size: 20),
                    label: Text('Compartir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsCards() {
    final totalReferred = _stats['totalReferred'] ?? 0;
    final totalRewards = (_stats['totalRewards'] ?? 0.0) as double;
    
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.people,
                    size: 32,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$totalReferred',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'Amigos\nReferidos',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 32,
                    color: Colors.green,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$${totalRewards.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Total\nGanado',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildHowItWorksCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: Theme.of(context).primaryColor, size: 24),
                SizedBox(width: 8),
                Text(
                  '¿Cómo Funciona?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            _buildStep('1', '🎯', 'Comparte tu código con amigos y familiares'),
            _buildStep('2', '📱', 'Ellos se registran usando tu código de referido'),
            _buildStep('3', '💸', 'Cuando hacen su primera compra o recarga'),
            _buildStep('4', '🎉', '¡Recibes \$5.00 automáticamente en tu billetera!'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStep(String number, String emoji, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Text(
            emoji,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReferredUsersList() {
    final referredUsers = List<Map<String, dynamic>>.from(_stats['referredUsers'] ?? []);
    
    if (referredUsers.isEmpty) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.person_add,
                size: 48,
                color: Colors.grey[400],
              ),
              SizedBox(height: 12),
              Text(
                'Aún no has referido amigos',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Comparte tu código para comenzar a ganar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Theme.of(context).primaryColor, size: 24),
                SizedBox(width: 8),
                Text(
                  'Amigos Referidos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            ...referredUsers.map((user) => _buildReferredUserTile(user)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReferredUserTile(Map<String, dynamic> user) {
    final hasUsedService = user['hasUsedService'] ?? false;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: hasUsedService ? Colors.green : Colors.orange,
            child: Icon(
              hasUsedService ? Icons.check : Icons.hourglass_empty,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'Usuario',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                Text(
                  hasUsedService 
                      ? '✅ Ya usó servicios - Recompensa otorgada'
                      : '⏳ Pendiente de usar servicios',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasUsedService ? Colors.green : Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(user['registrationDate']),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRewardHistoryCard() {
    final rewardHistory = List<Map<String, dynamic>>.from(_stats['rewardHistory'] ?? []);
    
    if (rewardHistory.isEmpty) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: Colors.grey[400],
              ),
              SizedBox(height: 12),
              Text(
                'Sin recompensas aún',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Las recompensas aparecerán aquí cuando tus referidos usen servicios',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Theme.of(context).primaryColor, size: 24),
                SizedBox(width: 8),
                Text(
                  'Historial de Recompensas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            ...rewardHistory.take(5).map((reward) => _buildRewardTile(reward)),
            
            if (rewardHistory.length > 5)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'Y ${rewardHistory.length - 5} recompensas más...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRewardTile(Map<String, dynamic> reward) {
    final amount = (reward['amount'] ?? 0.0) as double;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Icon(
            Icons.attach_money,
            color: Colors.green,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Recompensa por referido',
              style: TextStyle(fontSize: 14),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 14,
                ),
              ),
              Text(
                _formatDate(reward['date']),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}