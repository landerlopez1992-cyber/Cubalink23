import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cubalink23/services/user_role_service.dart';
import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavedCardsScreen extends StatefulWidget {
  final bool isForWithdrawal;
  final double? withdrawalAmount;

  const SavedCardsScreen({
    super.key,
    this.isForWithdrawal = false,
    this.withdrawalAmount,
  });

  @override
  _SavedCardsScreenState createState() => _SavedCardsScreenState();
}

class _SavedCardsScreenState extends State<SavedCardsScreen> {
  final UserRoleService _roleService = UserRoleService();
  List<Map<String, dynamic>> _savedCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  Future<void> _loadSavedCards() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = _roleService.displayName ?? 'default';
      final cardsJson = prefs.getString('saved_cards_$userEmail');
      
      if (cardsJson != null) {
        final cardsData = json.decode(cardsJson) as List;
        _savedCards = cardsData.map((card) => Map<String, dynamic>.from(card)).toList();
      } else {
        // Tarjetas de ejemplo para demo
        _savedCards = [
          {
            'id': '1',
            'cardNumber': '4532015112830366',
            'cardHolderName': 'LANDER LOPEZ',
            'expiryMonth': 12,
            'expiryYear': 2025,
            'cardType': 'visa',
            'isDefault': true,
            'lastUsed': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
            'nickname': 'Visa Principal',
          },
          {
            'id': '2',
            'cardNumber': '5555555555554444',
            'cardHolderName': 'LANDER LOPEZ',
            'expiryMonth': 8,
            'expiryYear': 2026,
            'cardType': 'mastercard',
            'isDefault': false,
            'lastUsed': DateTime.now().subtract(Duration(days: 10)).toIso8601String(),
            'nickname': 'MasterCard Backup',
          },
        ];
        await _saveSavedCards();
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error cargando tarjetas guardadas: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSavedCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = _roleService.displayName ?? 'default';
      final cardsJson = json.encode(_savedCards);
      await prefs.setString('saved_cards_$userEmail', cardsJson);
    } catch (e) {
      print('Error guardando tarjetas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: _roleService.isVendor ? Color(0xFF2E7D32) : Color(0xFF1976D2),
        title: Text(
          widget.isForWithdrawal ? 'Seleccionar Tarjeta' : 'Mis Tarjetas',
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
          if (!widget.isForWithdrawal)
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: _showAddCardDialog,
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: _roleService.isVendor ? Color(0xFF2E7D32) : Color(0xFF1976D2),
              ),
            )
          : _buildCardsList(),
      floatingActionButton: widget.isForWithdrawal
          ? null
          : FloatingActionButton(
              onPressed: _showAddCardDialog,
              backgroundColor: _roleService.isVendor ? Color(0xFF2E7D32) : Color(0xFF1976D2),
              child: Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildCardsList() {
    if (_savedCards.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _savedCards.length,
      itemBuilder: (context, index) {
        final card = _savedCards[index];
        return _buildCardItem(card, index);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No tienes tarjetas guardadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Agrega una tarjeta para realizar retiros fácilmente',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddCardDialog,
            icon: Icon(Icons.add),
            label: Text('Agregar Tarjeta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _roleService.isVendor ? Color(0xFF2E7D32) : Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(Map<String, dynamic> card, int index) {
    final cardType = card['cardType'] as String;
    final isDefault = card['isDefault'] as bool;
    final maskedNumber = _maskCardNumber(card['cardNumber']);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: widget.isForWithdrawal
            ? () => _selectCardForWithdrawal(card)
            : null,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: _getCardGradient(cardType),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _getCardTypeIcon(cardType),
                  if (isDefault)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'PRINCIPAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                maskedNumber,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TITULAR',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        card['cardHolderName'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'VENCE',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${card['expiryMonth'].toString().padLeft(2, '0')}/${card['expiryYear'].toString().substring(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (card['nickname'] != null) ...[
                SizedBox(height: 12),
                Text(
                  card['nickname'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (!widget.isForWithdrawal) ...[
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editCard(card, index),
                        icon: Icon(Icons.edit, size: 16, color: Colors.white),
                        label: Text('Editar', style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.5)),
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteCard(index),
                        icon: Icon(Icons.delete, size: 16, color: Colors.white),
                        label: Text('Eliminar', style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.5)),
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getCardGradient(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'mastercard':
        return LinearGradient(
          colors: [Color(0xFFBF360C), Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'amex':
        return LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [Color(0xFF424242), Color(0xFF757575)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Widget _getCardTypeIcon(String cardType) {
    String iconText;
    switch (cardType.toLowerCase()) {
      case 'visa':
        iconText = 'VISA';
        break;
      case 'mastercard':
        iconText = 'MC';
        break;
      case 'amex':
        iconText = 'AMEX';
        break;
      default:
        iconText = 'CARD';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        iconText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _maskCardNumber(String cardNumber) {
    if (cardNumber.length >= 4) {
      return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
    }
    return cardNumber;
  }

  void _selectCardForWithdrawal(Map<String, dynamic> card) {
    Navigator.pop(context, {
      'card': card,
      'amount': widget.withdrawalAmount,
    });
  }

  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCardDialog(
        onCardAdded: (newCard) {
          setState(() {
            _savedCards.add(newCard);
          });
          _saveSavedCards();
        },
        roleService: _roleService,
      ),
    );
  }

  void _editCard(Map<String, dynamic> card, int index) {
    showDialog(
      context: context,
      builder: (context) => EditCardDialog(
        card: card,
        onCardUpdated: (updatedCard) {
          setState(() {
            _savedCards[index] = updatedCard;
          });
          _saveSavedCards();
        },
        roleService: _roleService,
      ),
    );
  }

  void _deleteCard(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Tarjeta'),
        content: Text('¿Estás seguro de que deseas eliminar esta tarjeta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _savedCards.removeAt(index);
              });
              _saveSavedCards();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tarjeta eliminada'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// Dialog para agregar nueva tarjeta
class AddCardDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onCardAdded;
  final UserRoleService roleService;

  const AddCardDialog({
    super.key,
    required this.onCardAdded,
    required this.roleService,
  });

  @override
  _AddCardDialogState createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isDefault = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar Nueva Tarjeta'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CardNumberInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Número de Tarjeta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el número de tarjeta';
                  }
                  final cleanNumber = value.replaceAll(' ', '');
                  if (cleanNumber.length < 13 || cleanNumber.length > 19) {
                    return 'Número de tarjeta inválido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _cardHolderController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Titular',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el nombre del titular';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ExpiryDateInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: 'MM/YY',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Fecha requerida';
                        }
                        if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                          return 'Formato MM/YY';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.security),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'CVV requerido';
                        }
                        if (value.length < 3 || value.length > 4) {
                          return 'CVV inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: 'Apodo (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                  hintText: 'ej: Visa Principal',
                ),
              ),
              SizedBox(height: 16),
              CheckboxListTile(
                title: Text('Establecer como tarjeta principal'),
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value ?? false;
                  });
                },
                activeColor: widget.roleService.isVendor ? Color(0xFF2E7D32) : Color(0xFF1976D2),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveCard,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.roleService.isVendor ? Color(0xFF2E7D32) : Color(0xFF1976D2),
            foregroundColor: Colors.white,
          ),
          child: Text('Guardar'),
        ),
      ],
    );
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      final cardNumber = _cardNumberController.text.replaceAll(' ', '');
      final expiryParts = _expiryController.text.split('/');
      final cardType = _detectCardType(cardNumber);
      
      final newCard = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'cardNumber': cardNumber,
        'cardHolderName': _cardHolderController.text.toUpperCase(),
        'expiryMonth': int.parse(expiryParts[0]),
        'expiryYear': 2000 + int.parse(expiryParts[1]),
        'cardType': cardType,
        'isDefault': _isDefault,
        'lastUsed': DateTime.now().toIso8601String(),
        'nickname': _nicknameController.text.isNotEmpty ? _nicknameController.text : null,
      };
      
      widget.onCardAdded(newCard);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarjeta agregada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _detectCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'visa';
    if (cardNumber.startsWith('5') || cardNumber.startsWith('2')) return 'mastercard';
    if (cardNumber.startsWith('3')) return 'amex';
    return 'other';
  }
}

// Dialog para editar tarjeta
class EditCardDialog extends StatefulWidget {
  final Map<String, dynamic> card;
  final Function(Map<String, dynamic>) onCardUpdated;
  final UserRoleService roleService;

  const EditCardDialog({
    super.key,
    required this.card,
    required this.onCardUpdated,
    required this.roleService,
  });

  @override
  _EditCardDialogState createState() => _EditCardDialogState();
}

class _EditCardDialogState extends State<EditCardDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.card['nickname'] ?? '');
    _isDefault = widget.card['isDefault'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Tarjeta'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tarjeta: **** **** **** ${widget.card['cardNumber'].toString().substring(widget.card['cardNumber'].toString().length - 4)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: 'Apodo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
                hintText: 'ej: Visa Principal',
              ),
            ),
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text('Establecer como tarjeta principal'),
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value ?? false;
                });
              },
              activeColor: widget.roleService.isVendor ? Color(0xFF2E7D32) : Color(0xFF1976D2),
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
          onPressed: _updateCard,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.roleService.isVendor ? Color(0xFF2E7D32) : Color(0xFF1976D2),
            foregroundColor: Colors.white,
          ),
          child: Text('Actualizar'),
        ),
      ],
    );
  }

  void _updateCard() {
    final updatedCard = Map<String, dynamic>.from(widget.card);
    updatedCard['nickname'] = _nicknameController.text.isNotEmpty ? _nicknameController.text : null;
    updatedCard['isDefault'] = _isDefault;
    
    widget.onCardUpdated(updatedCard);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarjeta actualizada'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Formateador para el número de tarjeta
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Formateador para la fecha de expiración
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
