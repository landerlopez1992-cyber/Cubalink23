import 'package:flutter/material.dart';
import 'package:cubalink23/services/auth_service.dart';
import 'package:cubalink23/services/supabase_service.dart';
import 'package:cubalink23/models/user.dart';
import 'dart:async';
import 'package:cubalink23/services/auth_guard_service.dart';

class Message {
  final String id;
  final String content;
  final bool isFromUser;
  final DateTime timestamp;
  final MessageStatus status;

  Message({
    required this.id,
    required this.content,
    required this.isFromUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });
}

enum MessageStatus { sending, sent, delivered, read }

class SupportChatScreen extends StatefulWidget {
  final String? orderNumber;
  final String? autoMessage;
  
  const SupportChatScreen({
    super.key,
    this.orderNumber,
    this.autoMessage,
  });

  @override
  _SupportChatScreenState createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  // REMOVED: final FirebaseRepository _repository = FirebaseRepository.instance;
  
  User? currentUser;
  bool isLoading = true;
  bool isTyping = false;
  bool isSendingMessage = false;
  String? conversationId;
  StreamSubscription<List<Map<String, dynamic>>>? _messagesSubscription;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Obtener argumentos de navegación si existen
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['autoMessage'] != null && _messages.isEmpty && currentUser != null && mounted) {
      // Enviar mensaje automáticamente después de un pequeño delay
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          _sendAutoMessage(args['autoMessage'] as String);
        }
      });
    }
  }

  Future<void> _checkAuthAndLoadData() async {
    final hasAuth = await AuthGuardService.instance.requireAuth(context, serviceName: 'el Chat de Soporte');
    if (!hasAuth) {
      Navigator.pop(context);
      return;
    }
    
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      await AuthService.instance.loadCurrentUserData();
      final user = AuthService.instance.currentUser;
      setState(() {
        currentUser = user;
        isLoading = false;
      });
      _initializeRealChat();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _initializeRealChat() async {
    if (currentUser == null) return;
    
    try {
      // Buscar o crear conversación real en Supabase
      final existingConversations = await SupabaseService.instance.select(
        'support_conversations',
        where: 'user_id',
        equals: currentUser!.id,
      );
      
      if (existingConversations.isNotEmpty) {
        conversationId = existingConversations.first['id'];
        print('✅ Conversación existente encontrada: $conversationId');
      } else {
        // Crear nueva conversación
        final newConversation = await SupabaseService.instance.insert('support_conversations', {
          'user_id': currentUser!.id,
          'user_email': currentUser!.email,
          'user_name': currentUser!.name,
          'status': 'pending',
          'last_message_time': DateTime.now().toIso8601String(),
          'unread_count': 0,
        });
        
        conversationId = newConversation?['id'];
        print('✅ Nueva conversación creada: $conversationId');
      }
      
      _loadExistingMessages();
      _listenToMessages();
    } catch (e) {
      print('❌ Error initializing chat: $e');
    }
  }

  Future<void> _createNewConversation() async {
    if (currentUser == null) return;
    
    try {
      // MOCK: Simulate conversation creation
      conversationId = 'mock_conversation_${currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}';
      print('✅ New conversation created: $conversationId');
    } catch (e) {
      print('❌ Error creating conversation: $e');
    }
  }

  Future<void> _loadExistingMessages() async {
    if (conversationId == null) return;
    
    try {
      // Cargar mensajes reales desde Supabase
      final messagesData = await SupabaseService.instance.select(
        'support_messages',
        where: 'conversation_id',
        equals: conversationId,
        orderBy: 'created_at',
        ascending: true,
      );
      
      final messages = messagesData.map((msgData) => Message(
        id: msgData['id'],
        content: msgData['message'],
        isFromUser: msgData['is_from_user'] ?? true,
        timestamp: DateTime.parse(msgData['created_at']),
      )).toList();
      
      setState(() {
        _messages.clear();
        _messages.addAll(messages);
      });
      
      _scrollToBottom();
    } catch (e) {
      print('❌ Error loading messages: $e');
    }
  }

  void _listenToMessages() {
    if (conversationId == null) return;
    
    // MOCK: Simulate real-time message listening
    // In a real implementation, this would listen to Supabase real-time updates
    print('✅ Mock message listener initialized for conversation: $conversationId');
  }

  Future<void> _sendRealMessage(String content) async {
    if (conversationId == null || currentUser == null) return;
    
    setState(() {
      isSendingMessage = true;
    });
    
    try {
      // Enviar mensaje real a Supabase
      await SupabaseService.instance.insert('support_messages', {
        'conversation_id': conversationId,
        'user_id': currentUser!.id,
        'user_email': currentUser!.email,
        'user_name': currentUser!.name,
        'message': content,
        'is_from_user': true,
        'is_read': false,
      });
      
      // Actualizar conversación
      await SupabaseService.instance.update('support_conversations', conversationId!, {
        'last_message_time': DateTime.now().toIso8601String(),
        'unread_count': 1,
        'status': 'pending',
      });
      
      // Add user message to local list
      final userMessage = Message(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        content: content,
        isFromUser: true,
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _messages.add(userMessage);
      });
      
      // Enviar mensaje automático de bienvenida si es el primer mensaje
      if (_messages.length == 1) {
        Future.delayed(Duration(seconds: 1), () async {
          await SupabaseService.instance.insert('support_messages', {
            'conversation_id': conversationId,
            'user_id': 'system',
            'user_email': 'support@turecarga.com',
            'user_name': 'Soporte Tu Recarga',
            'message': 'Gracias por contactarnos. Un agente de soporte revisará tu mensaje y te responderá pronto.',
            'is_from_user': false,
            'is_read': true,
          });
          
          final autoReply = Message(
            id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
            content: 'Gracias por contactarnos. Un agente de soporte revisará tu mensaje y te responderá pronto.',
            isFromUser: false,
            timestamp: DateTime.now(),
          );
          
          setState(() {
            _messages.add(autoReply);
          });
          
          _scrollToBottom();
        });
      }
      
      print('✅ Mock message sent successfully');
      _scrollToBottom();
      
    } catch (e) {
      print('❌ Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error enviando mensaje: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSendingMessage = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && !isSendingMessage) {
      _sendRealMessage(message);
      _messageController.clear();
    }
  }

  void _sendAutoMessage(String message) {
    if (message.isNotEmpty && !isSendingMessage) {
      _sendRealMessage(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Fondo general oficial Cubalink23
      appBar: AppBar(
        backgroundColor: Color(0xFF37474F), // Header oficial Cubalink23
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soporte Chat',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              conversationId != null ? 'Conectado • Chat en tiempo real' : 'Conectando...',
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
            onPressed: () {
              _showOptionsMenu();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Barra de entrada de mensaje
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment: message.isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: message.isFromUser 
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: Radius.circular(message.isFromUser ? 4 : 18),
            bottomLeft: Radius.circular(message.isFromUser ? 18 : 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: message.isFromUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: message.isFromUser 
                        ? Colors.white70 
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (message.isFromUser) ...[
                  SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    color: Colors.white70,
                    size: 16,
                  ),
                ],
              ],
            ),
          ],
        ),
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
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu mensaje...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[600]),
                  ),
                  maxLines: null,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: isSendingMessage ? null : _sendMessage,
                icon: isSendingMessage
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text('Reiniciar Chat'),
              onTap: () {
                Navigator.pop(context);
                _clearChat();
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Preguntas Frecuentes'),
              onTap: () {
                Navigator.pop(context);
                _showFAQ();
              },
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Contacto Directo'),
              onTap: () {
                Navigator.pop(context);
                _showContactInfo();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearChat() {
    // No se puede limpiar el chat real, solo recargar mensajes
    _loadExistingMessages();
  }

  void _showFAQ() {
    // Enviar mensaje FAQ como mensaje real
    _sendRealMessage("Necesito ver las preguntas frecuentes sobre Tu Recarga.");
  }

  void _showContactInfo() {
    // Enviar mensaje de contacto como mensaje real
    _sendRealMessage("¿Podrían proporcionarme información de contacto adicional?");
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}