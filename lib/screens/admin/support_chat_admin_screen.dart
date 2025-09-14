import 'package:flutter/material.dart';
import 'package:cubalink23/services/supabase_service.dart';
import 'package:cubalink23/services/supabase_database_service.dart';

class ChatMessage {
  String id;
  String userId;
  String userEmail;
  String userName;
  String message;
  DateTime timestamp;
  bool isFromUser;
  bool isRead;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.message,
    required this.timestamp,
    required this.isFromUser,
    this.isRead = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    return ChatMessage(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      message: data['message'] ?? '',
      timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
      isFromUser: data['isFromUser'] ?? true,
      isRead: data['isRead'] ?? false,
    );
  }
}

class ChatConversation {
  String id;
  String userId;
  String userEmail;
  String userName;
  List<ChatMessage> messages;
  DateTime lastMessage;
  int unreadCount;
  String status;

  ChatConversation({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.messages,
    required this.lastMessage,
    required this.unreadCount,
    required this.status,
  });

  factory ChatConversation.fromMap(Map<String, dynamic> data) {
    return ChatConversation(
      id: data['id'] ?? '',
      userId: data['user_id'] ?? '',
      userEmail: data['user_email'] ?? '',
      userName: data['user_name'] ?? '',
      messages: [],
      lastMessage: data['last_message_time']?.toDate() ?? DateTime.now(),
      unreadCount: data['unread_count'] ?? 0,
      status: data['status'] ?? 'pending',
    );
  }
}

class SupportChatAdminScreen extends StatefulWidget {
  const SupportChatAdminScreen({super.key});

  @override
  _SupportChatAdminScreenState createState() => _SupportChatAdminScreenState();
}

class _SupportChatAdminScreenState extends State<SupportChatAdminScreen> {
  List<ChatConversation> _conversations = [];
  ChatConversation? _selectedConversation;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messagesScrollController = ScrollController();
  bool _isLoading = true;
  bool _isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _loadRealConversations();
  }

  Future<void> _loadRealConversations() async {
    try {
      setState(() => _isLoading = true);
      
      // Cargar conversaciones reales desde Supabase
      final conversationsData = await SupabaseService.instance.select(
        'support_conversations',
        orderBy: 'last_message_time',
        ascending: false,
      );
      
      final conversations = conversationsData.map((data) => ChatConversation.fromMap(data)).toList();
      
      // Cargar mensajes para cada conversación
      for (final conversation in conversations) {
        final messagesData = await SupabaseService.instance.select(
          'support_messages',
          where: 'conversation_id',
          equals: conversation.id,
          orderBy: 'created_at',
          ascending: true,
        );
        
        conversation.messages = messagesData.map((msgData) => ChatMessage.fromMap(msgData)).toList();
      }
      
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
      
      print('✅ Loaded ${conversations.length} real support conversations');
    } catch (e) {
      print('❌ Error loading conversations: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando conversaciones: $e')),
      );
    }
  }

  Future<void> _selectConversation(ChatConversation conversation) async {
    try {
      setState(() => _selectedConversation = conversation);
      
      // TODO: Replace with Supabase implementation
      await Future.delayed(Duration(milliseconds: 300));
      
      // Update local state
      setState(() {
        conversation.unreadCount = 0;
        for (var message in conversation.messages) {
          if (message.isFromUser) {
            message.isRead = true;
          }
        }
      });
      
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_messagesScrollController.hasClients) {
          _messagesScrollController.animateTo(
            _messagesScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('❌ Error selecting conversation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar conversación')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || _selectedConversation == null) return;
    
    final messageText = _messageController.text;
    _messageController.clear();
    
    try {
      setState(() => _isSendingMessage = true);
      
      // Enviar mensaje real a Supabase
      await SupabaseService.instance.insert('support_messages', {
        'conversation_id': _selectedConversation!.id,
        'user_id': 'admin',
        'user_email': 'landerlopez1992@gmail.com',
        'user_name': 'Administrador',
        'message': messageText,
        'is_from_user': false,
        'is_read': true,
      });
      
      // Actualizar estado de la conversación
      await SupabaseService.instance.update('support_conversations', _selectedConversation!.id, {
        'last_message_time': DateTime.now().toIso8601String(),
        'status': 'active',
      });
      
      // Create local message for immediate UI update
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'admin',
        userEmail: 'landerlopez1992@gmail.com',
        userName: 'Administrador',
        message: messageText,
        timestamp: DateTime.now(),
        isFromUser: false,
        isRead: true,
      );

      setState(() {
        _selectedConversation!.messages.add(newMessage);
        _selectedConversation!.lastMessage = DateTime.now();
        _selectedConversation!.status = 'active';
        _isSendingMessage = false;
      });
      
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_messagesScrollController.hasClients) {
          _messagesScrollController.animateTo(
            _messagesScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      
      print('✅ Admin message sent successfully');
    } catch (e) {
      print('❌ Error sending message: $e');
      setState(() => _isSendingMessage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enviando mensaje: $e')),
      );
    }
  }

  Future<void> _changeConversationStatus(String status) async {
    if (_selectedConversation == null) return;
    
    try {
      // Actualizar estado real en Supabase
      await SupabaseService.instance.update('support_conversations', _selectedConversation!.id, {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      setState(() {
        _selectedConversation!.status = status;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Estado cambiado a $status')),
      );
    } catch (e) {
      print('❌ Error changing conversation status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cambiando estado: $e')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'ACTIVO';
      case 'pending':
        return 'PENDIENTE';
      case 'resolved':
        return 'RESUELTO';
      default:
        return status.toUpperCase();
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final totalUnread = _conversations.fold(0, (sum, conv) => sum + conv.unreadCount);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Soporte Chat - TIEMPO REAL',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (totalUnread > 0) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalUnread',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        centerTitle: false,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadRealConversations,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando conversaciones reales desde Firebase...'),
                ],
              ),
            )
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_outlined, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'No hay conversaciones de soporte',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Los usuarios pueden contactar soporte desde la app',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    // Panel izquierdo - Lista de conversaciones
                    Container(
                      width: isDesktop ? 350 : MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.grey[300]!)),
                      ),
                      child: Column(
                        children: [
                          // Header de estadísticas REAL
                          Container(
                            padding: EdgeInsets.all(16),
                            color: Theme.of(context).colorScheme.primary.withOpacity( 0.1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '${_conversations.where((c) => c.status == 'active').length}',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    Text('Activos', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${_conversations.where((c) => c.status == 'pending').length}',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    Text('Pendientes', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${_conversations.where((c) => c.status == 'resolved').length}',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    Text('Resueltos', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Lista de conversaciones REALES
                          Expanded(
                            child: ListView.separated(
                              itemCount: _conversations.length,
                              separatorBuilder: (context, index) => Divider(height: 1),
                              itemBuilder: (context, index) {
                                final conversation = _conversations[index];
                                final isSelected = _selectedConversation?.id == conversation.id;
                                
                                return ListTile(
                                  selected: isSelected,
                                  selectedColor: Theme.of(context).colorScheme.primary,
                                  onTap: () => _selectConversation(conversation),
                                  leading: Stack(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: _getStatusColor(conversation.status).withOpacity( 0.2),
                                        child: Icon(
                                          Icons.person,
                                          color: _getStatusColor(conversation.status),
                                        ),
                                      ),
                                      if (conversation.unreadCount > 0)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            constraints: BoxConstraints(
                                              minWidth: 18,
                                              minHeight: 18,
                                            ),
                                            child: Text(
                                              '${conversation.unreadCount}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  title: Text(
                                    conversation.userName,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        conversation.userEmail,
                                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                      ),
                                      Text(
                                        conversation.messages.isNotEmpty
                                            ? conversation.messages.last.message
                                            : 'No hay mensajes',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(conversation.status),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _getStatusText(conversation.status),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    _formatTime(conversation.lastMessage),
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  isThreeLine: true,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Panel derecho - Chat seleccionado
                    Expanded(
                      child: _selectedConversation == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Selecciona una conversación',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                // Header del chat con usuario REAL
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity( 0.1),
                                    border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: _getStatusColor(_selectedConversation!.status).withOpacity( 0.2),
                                        child: Icon(
                                          Icons.person,
                                          color: _getStatusColor(_selectedConversation!.status),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedConversation!.userName,
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            Text(
                                              _selectedConversation!.userEmail,
                                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                            ),
                                            Text(
                                              'ID: ${_selectedConversation!.userId}',
                                              style: TextStyle(color: Colors.grey[500], fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: _changeConversationStatus,
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'active',
                                            child: Row(
                                              children: [
                                                Icon(Icons.circle, color: Colors.green, size: 12),
                                                SizedBox(width: 8),
                                                Text('Marcar como Activo'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'pending',
                                            child: Row(
                                              children: [
                                                Icon(Icons.circle, color: Colors.orange, size: 12),
                                                SizedBox(width: 8),
                                                Text('Marcar como Pendiente'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'resolved',
                                            child: Row(
                                              children: [
                                                Icon(Icons.circle, color: Colors.blue, size: 12),
                                                SizedBox(width: 8),
                                                Text('Marcar como Resuelto'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Mensajes REALES
                                Expanded(
                                  child: ListView.builder(
                                    controller: _messagesScrollController,
                                    padding: EdgeInsets.all(16),
                                    itemCount: _selectedConversation!.messages.length,
                                    itemBuilder: (context, index) {
                                      final message = _selectedConversation!.messages[index];
                                      final isFromUser = message.isFromUser;
                                      
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 16),
                                        child: Row(
                                          mainAxisAlignment: isFromUser 
                                              ? MainAxisAlignment.start 
                                              : MainAxisAlignment.end,
                                          children: [
                                            if (!isFromUser) Spacer(),
                                            Container(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context).size.width * 0.7,
                                              ),
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: isFromUser 
                                                    ? Colors.grey[200] 
                                                    : Theme.of(context).colorScheme.primary,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    message.message,
                                                    style: TextStyle(
                                                      color: isFromUser ? Colors.black : Colors.white,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: isFromUser 
                                                          ? Colors.grey[600] 
                                                          : Colors.white.withOpacity( 0.7),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isFromUser) Spacer(),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                
                                // Input de mensaje FUNCIONAL
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _messageController,
                                          decoration: InputDecoration(
                                            hintText: 'Escribe tu respuesta al cliente...',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                          ),
                                          onSubmitted: (_) => _sendMessage(),
                                          enabled: !_isSendingMessage,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      FloatingActionButton(
                                        mini: true,
                                        onPressed: _isSendingMessage ? null : _sendMessage,
                                        child: _isSendingMessage
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : Icon(Icons.send),
                                      ),
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

  @override
  void dispose() {
    _messageController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }
}