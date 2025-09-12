import 'package:flutter/material.dart';
import 'package:cubalink23/services/user_role_service.dart';

class VendorSupportScreen extends StatefulWidget {
  const VendorSupportScreen({super.key});

  @override
  _VendorSupportScreenState createState() => _VendorSupportScreenState();
}

class _VendorSupportScreenState extends State<VendorSupportScreen> {
  final UserRoleService _roleService = UserRoleService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    setState(() => _isLoading = true);
    
    try {
      // Simular historial de chat
      // En producción, esto vendría de Supabase
      await Future.delayed(Duration(seconds: 1));
      
      setState(() {
        _messages = [
          {
            'id': '1',
            'text': 'Hola, soy Lander Lopez, vendedor. Tengo una consulta sobre mi cuenta de vendedor.',
            'isFromUser': true,
            'timestamp': DateTime.now().subtract(Duration(hours: 2)),
            'status': 'delivered',
          },
          {
            'id': '2',
            'text': 'Hola Lander! Soy María del equipo de soporte. ¿En qué puedo ayudarte?',
            'isFromUser': false,
            'timestamp': DateTime.now().subtract(Duration(hours: 2, minutes: -5)),
            'status': 'delivered',
            'senderName': 'María - Soporte',
          },
          {
            'id': '3',
            'text': '¿Cómo puedo cambiar la configuración de entrega de mis productos? Algunos quiero entregarlos yo mismo.',
            'isFromUser': true,
            'timestamp': DateTime.now().subtract(Duration(hours: 1, minutes: 30)),
            'status': 'delivered',
          },
          {
            'id': '4',
            'text': 'En esos casos, debes intentar contactar al cliente por teléfono. Si no responde, marca la orden como "Cliente no disponible" y regresa al punto de recogida.',
            'isFromUser': false,
            'timestamp': DateTime.now().subtract(Duration(hours: 1, minutes: 25)),
            'status': 'delivered',
            'senderName': 'María - Soporte',
          },
          {
            'id': '5',
            'text': 'Perfecto, ya lo hice. ¿Hay algún problema si regreso la orden al restaurante?',
            'isFromUser': true,
            'timestamp': DateTime.now().subtract(Duration(hours: 1, minutes: 20)),
            'status': 'delivered',
          },
          {
            'id': '6',
            'text': 'No hay problema. Es el procedimiento correcto. El restaurante se encargará de contactar al cliente para reprogramar la entrega.',
            'isFromUser': false,
            'timestamp': DateTime.now().subtract(Duration(hours: 1, minutes: 15)),
            'status': 'delivered',
            'senderName': 'María - Soporte',
          },
          {
            'id': '7',
            'text': 'Gracias por la ayuda!',
            'isFromUser': true,
            'timestamp': DateTime.now().subtract(Duration(hours: 1, minutes: 10)),
            'status': 'delivered',
          },
          {
            'id': '8',
            'text': '¡De nada! Si tienes más consultas, no dudes en escribirme. ¡Buen trabajo!',
            'isFromUser': false,
            'timestamp': DateTime.now().subtract(Duration(hours: 1, minutes: 5)),
            'status': 'delivered',
            'senderName': 'María - Soporte',
          },
        ];
        _isLoading = false;
      });
      
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Error cargando historial de chat: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF2E7D32),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soporte Técnico',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'En línea',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showChatOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1976D2),
                    ),
                  )
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length && _isTyping) {
                            return _buildTypingIndicator();
                          }
                          return _buildMessageBubble(_messages[index]);
                        },
                      ),
          ),
          
          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Inicia una conversación',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Escribe tu consulta y nuestro equipo de soporte te ayudará',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isFromUser = message['isFromUser'] as bool;
    final text = message['text'] as String;
    final timestamp = message['timestamp'] as DateTime;
    final status = message['status'] as String;
    final senderName = message['senderName'] as String?;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF2E7D32),
              child: Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 16,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFromUser ? Color(0xFF1976D2) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(isFromUser ? 18 : 4),
                  bottomRight: Radius.circular(isFromUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isFromUser && senderName != null)
                    Text(
                      senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  if (!isFromUser && senderName != null) SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isFromUser ? Colors.white : Colors.grey[800],
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTimestamp(timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isFromUser ? Colors.white70 : Colors.grey[500],
                        ),
                      ),
                      if (isFromUser) ...[
                        SizedBox(width: 4),
                        Icon(
                          _getStatusIcon(status),
                          size: 12,
                          color: Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isFromUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person,
                color: Colors.grey[600],
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF2E7D32),
            child: Icon(
              Icons.support_agent,
              color: Colors.white,
              size: 16,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'María está escribiendo',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  height: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTypingDot(0),
                      _buildTypingDot(1),
                      _buildTypingDot(2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF1976D2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': text,
        'isFromUser': true,
        'timestamp': DateTime.now(),
        'status': 'sending',
      });
    });

    _messageController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate typing indicator
    setState(() {
      _isTyping = true;
    });

    // Simulate response after delay
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isTyping = false;
        _messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': 'Gracias por tu mensaje. Nuestro equipo de soporte te responderá pronto.',
          'isFromUser': false,
          'timestamp': DateTime.now(),
          'status': 'delivered',
          'senderName': 'María - Soporte',
        });
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.history, color: Color(0xFF1976D2)),
              title: Text('Historial de conversaciones'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar historial
              },
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Color(0xFF1976D2)),
              title: Text('Llamar a soporte'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar llamada
              },
            ),
            ListTile(
              leading: Icon(Icons.email, color: Color(0xFF1976D2)),
              title: Text('Enviar email'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar email
              },
            ),
            ListTile(
              leading: Icon(Icons.help, color: Color(0xFF1976D2)),
              title: Text('Preguntas frecuentes'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar FAQ
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'sending':
        return Icons.access_time;
      case 'delivered':
        return Icons.done;
      case 'read':
        return Icons.done_all;
      default:
        return Icons.access_time;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
