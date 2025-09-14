import 'package:flutter/material.dart';
import 'package:cubalink23/models/user.dart';
import 'package:cubalink23/models/contact.dart';
import 'package:cubalink23/models/operator.dart';
import 'package:cubalink23/screens/recharge/recharge_screen.dart';

class ContactsScreen extends StatefulWidget {
  final User user;

  const ContactsScreen({super.key, required this.user});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late List<Contact> _contacts;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _contacts = Contact.getSampleContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Contact> get _filteredContacts {
    if (_searchQuery.isEmpty) return _contacts;
    return _contacts.where((contact) {
      return contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          contact.phone.contains(_searchQuery);
    }).toList();
  }

  void _navigateToRecharge(Contact contact) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RechargeScreen(
          user: widget.user,
          preselectedContact: contact,
        ),
      ),
    );
  }

  void _addNewContact() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) {
          return AddContactBottomSheet(
            onContactAdded: (contact) {
              setState(() {
                _contacts.add(contact);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Contacto agregado correctamente')),
              );
            },
          );
        },
      ),
    );
  }

  void _deleteContact(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar contacto'),
        content: Text('¿Estás seguro de que deseas eliminar a ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _contacts.remove(contact);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Contacto eliminado')),
              );
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredContacts = _filteredContacts;

    return Scaffold(
      appBar: AppBar(
        title: Text('Contactos', style: TextStyle(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar contactos...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Lista de contactos
          Expanded(
            child: filteredContacts.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    return ContactCard(
                      contact: contact,
                      onTap: () => _navigateToRecharge(contact),
                      onDelete: () => _deleteContact(contact),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewContact,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity( 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.contacts_outlined,
              size: 40,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(height: 20),
          Text(
            _searchQuery.isEmpty ? 'No tienes contactos' : 'No se encontraron contactos',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
              ? 'Agrega contactos para realizar recargas más fácilmente'
              : 'Intenta con otro término de búsqueda',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity( 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) ...[
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addNewContact,
              icon: Icon(Icons.person_add),
              label: Text('Agregar contacto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final operators = Operator.getOperatorsByCountry(contact.countryCode);
    final operator = operators.firstWhere(
      (op) => op.id == contact.operatorId,
      orElse: () => operators.first,
    );
    final country = Country.getCountries().firstWhere(
      (c) => c.code == contact.countryCode,
    );

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primary.withOpacity( 0.1),
                radius: 25,
                child: Text(
                  contact.name.split(' ').map((n) => n[0]).take(2).join(),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${country.prefix} ${contact.phone}',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity( 0.7),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Text(operator.logo, style: TextStyle(fontSize: 16)),
                        SizedBox(width: 4),
                        Text(
                          operator.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity( 0.6),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(country.flag, style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: onTap,
                    child: Row(
                      children: [
                        Icon(Icons.phone_android, size: 18),
                        SizedBox(width: 8),
                        Text('Recargar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: onDelete,
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: colorScheme.error),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: colorScheme.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddContactBottomSheet extends StatefulWidget {
  final Function(Contact) onContactAdded;

  const AddContactBottomSheet({super.key, required this.onContactAdded});

  @override
  State<AddContactBottomSheet> createState() => _AddContactBottomSheetState();
}

class _AddContactBottomSheetState extends State<AddContactBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  Country? _selectedCountry;
  Operator? _selectedOperator;

  @override
  void initState() {
    super.initState();
    _selectedCountry = Country.getCountries().first;
    _updateOperators();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateOperators() {
    if (_selectedCountry != null) {
      final operators = Operator.getOperatorsByCountry(_selectedCountry!.code);
      _selectedOperator = operators.first;
    }
  }

  void _saveContact() {
    if (!_formKey.currentState!.validate()) return;

    final contact = Contact(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      countryCode: _selectedCountry!.code,
      operatorId: _selectedOperator!.id,
      createdAt: DateTime.now(),
    );

    widget.onContactAdded(contact);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Agregar contacto',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            
            // Nombre
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el nombre';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            
            SizedBox(height: 16),
            
            // País
            DropdownButtonFormField<Country>(
              initialValue: _selectedCountry,
              decoration: InputDecoration(
                labelText: 'País',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: Country.getCountries().map((country) {
                return DropdownMenuItem(
                  value: country,
                  child: Row(
                    children: [
                      Text(country.flag, style: TextStyle(fontSize: 20)),
                      SizedBox(width: 12),
                      Text('${country.name} (${country.prefix})'),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (country) {
                setState(() {
                  _selectedCountry = country;
                  _updateOperators();
                });
              },
            ),
            
            SizedBox(height: 16),
            
            // Operador
            if (_selectedCountry != null)
              DropdownButtonFormField<Operator>(
                initialValue: _selectedOperator,
                decoration: InputDecoration(
                  labelText: 'Operador',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: Operator.getOperatorsByCountry(_selectedCountry!.code).map((operator) {
                  return DropdownMenuItem(
                    value: operator,
                    child: Row(
                      children: [
                        Text(operator.logo, style: TextStyle(fontSize: 20)),
                        SizedBox(width: 12),
                        Text(operator.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (operator) {
                  setState(() {
                    _selectedOperator = operator;
                  });
                },
              ),
            
            SizedBox(height: 16),
            
            // Teléfono
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                  ),
                  child: Text(
                    _selectedCountry?.prefix ?? '+1',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: 'Número de teléfono',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el teléfono';
                      }
                      if (value.length < 10) {
                        return 'Número muy corto';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            Spacer(),
            
            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveContact,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: Text('Guardar'),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}