import 'package:flutter/material.dart';
import 'package:cubalink23/services/supabase_service.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/screens/communication/chat_conversation_screen.dart';
import 'package:cubalink23/models/user.dart' as UserModel;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> conversations = [];
  List<UserModel.User> searchResults = [];
  bool isLoading = true;
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      setState(() => isLoading = true);
      
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return;
      
      final loadedConversations = <Map<String, dynamic>>[];
      // Simulado: await SupabaseService.instance.getUserConversations(currentUser.id);
      
      setState(() {
        conversations = loadedConversations;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading conversations: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }
    
    try {
      setState(() => isSearching = true);
      
      final results = <Map<String, dynamic>>[];
      // Simulado: await SupabaseService.instance.searchUsers(query);
      final users = results.map((userData) => UserModel.User(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        phone: userData['phone'] ?? '',
        balance: (userData['balance'] ?? 0.0).toDouble(),
        // isActive removido del constructor
        createdAt: DateTime.parse(userData['created_at']),
      )).toList();
      
      setState(() {
        searchResults = users;
        isSearching = false;
      });
    } catch (e) {
      print('Error searching users: $e');
      setState(() => isSearching = false);
    }
  }

  Future<void> _startConversation(UserModel.User otherUser) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) return;
      
      // Crear o encontrar conversación existente
      final conversationId = 'conversation_${currentUser.id}_${otherUser.id}';
      // Simulado: await SupabaseService.instance.createOrFindConversation(currentUser.id, otherUser.id);
      
      // Navegar a la pantalla de conversación
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatConversationScreen(
            conversationId: conversationId,
            otherUser: otherUser,
          ),
        ),
      );
    } catch (e) {
      print('Error starting conversation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error iniciando conversación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Fondo general Cubalink23
      appBar: AppBar(
        backgroundColor: Color(0xFF37474F), // Azul gris oscuro oficial Cubalink23
        foregroundColor: Colors.white, // Texto blanco sobre header oscuro
        title: Text(
          'Mensajes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar usuarios...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              onChanged: _searchUsers,
            ),
          ),
          
          // Contenido principal
          Expanded(
            child: _searchController.text.isNotEmpty
                ? _buildSearchResults()
                : _buildConversationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (isSearching) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            SizedBox(height: 16),
            Text(
              'No se encontraron usuarios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final user = searchResults[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildConversationsList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            SizedBox(height: 16),
            Text(
              'Sin conversaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Busca usuarios para iniciar una conversación',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _buildConversationTile(conversation);
      },
    );
  }

  Widget _buildUserTile(UserModel.User user) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user.name.substring(0, 1).toUpperCase()),
        ),
        title: Text(
          user.name,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(user.email),
        trailing: Icon(Icons.chat),
        onTap: () => _startConversation(user),
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation) {
    final otherUserName = conversation['other_user_name'] ?? 'Usuario';
    final lastMessage = conversation['last_message'] ?? '';
    final timestamp = DateTime.parse(conversation['updated_at'] ?? DateTime.now().toIso8601String());
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(otherUserName.substring(0, 1).toUpperCase()),
        ),
        title: Text(
          otherUserName,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatTime(timestamp),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        onTap: () {
          // Reconstruir el usuario desde los datos de la conversación
          final otherUser = UserModel.User(
            id: conversation['other_user_id'] ?? '',
            name: otherUserName,
            email: conversation['other_user_email'] ?? '',
            phone: conversation['other_user_phone'] ?? '',
            createdAt: DateTime.now(),
            country: '',
            city: '',
          );
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatConversationScreen(
                conversationId: conversation['id'],
                otherUser: otherUser,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }
}