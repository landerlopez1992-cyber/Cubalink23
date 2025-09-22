import 'package:flutter/material.dart';
import 'package:cubalink23/models/user.dart';
import 'package:cubalink23/models/operator.dart';
import 'package:cubalink23/models/contact.dart';
import 'package:cubalink23/models/recharge_history.dart';
import 'package:cubalink23/screens/payment/payment_method_screen.dart';

class RechargeScreen extends StatefulWidget {
  final User user;
  final Contact? preselectedContact;

  const RechargeScreen({
    super.key,
    required this.user,
    this.preselectedContact,
  });

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  Country? _selectedCountry;
  Operator? _selectedOperator;
  RechargeAmount? _selectedAmount;
  bool _fromContacts = false;
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _contacts = Contact.getSampleContacts();
    
    // Si viene un contacto preseleccionado
    if (widget.preselectedContact != null) {
      final contact = widget.preselectedContact!;
      _phoneController.text = contact.phone;
      _selectedCountry = Country.getCountries().firstWhere(
        (c) => c.code == contact.countryCode,
        orElse: () => Country.getCountries().first,
      );
      _updateOperators();
      _selectedOperator = Operator.getOperatorsByCountry(contact.countryCode).firstWhere(
        (op) => op.id == contact.operatorId,
        orElse: () => Operator.getOperatorsByCountry(contact.countryCode).first,
      );
    } else {
      _selectedCountry = Country.getCountries().first;
      _updateOperators();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _updateOperators() {
    if (_selectedCountry != null) {
      final operators = Operator.getOperatorsByCountry(_selectedCountry!.code);
      _selectedOperator = operators.first;
      _selectedAmount = null; // Reset amount when changing operator
    }
  }

  void _selectFromContacts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Seleccionar contacto',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
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
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity( 0.1),
                            child: Text(
                              contact.name.split(' ').map((n) => n[0]).take(2).join(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(contact.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${country.prefix} ${contact.phone}'),
                              Text(
                                '${operator.logo} ${operator.name}',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _phoneController.text = contact.phone;
                              _selectedCountry = country;
                              _updateOperators();
                              _selectedOperator = operator;
                              _fromContacts = true;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _proceedToPayment() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona un monto')),
      );
      return;
    }

    final transaction = RechargeTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      recipientPhone: '${_selectedCountry!.prefix} ${_phoneController.text}',
      recipientName: _fromContacts ? _contacts.firstWhere(
        (c) => c.phone == _phoneController.text,
        orElse: () => Contact(
          id: 'temp',
          name: 'Nuevo contacto',
          phone: _phoneController.text,
          countryCode: _selectedCountry!.code,
          operatorId: _selectedOperator!.id,
          createdAt: DateTime.now(),
        ),
      ).name : 'Nuevo contacto',
      countryCode: _selectedCountry!.code,
      operatorId: _selectedOperator!.id,
      amount: _selectedAmount!.amount,
      cost: _selectedAmount!.cost,
      status: RechargeStatus.pending,
      paymentMethod: PaymentMethod.paypal,
      createdAt: DateTime.now(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(
          amount: _selectedAmount!.amount,
          fee: _selectedAmount!.cost - _selectedAmount!.amount,
          total: _selectedAmount!.cost,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva recarga', style: TextStyle(color: Colors.white)), // Texto blanco sobre header oscuro
        backgroundColor: Color(0xFF37474F), // Azul gris oscuro oficial Cubalink23
        iconTheme: IconThemeData(color: Colors.white), // Iconos blancos sobre header oscuro
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información de recarga card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF37474F).withOpacity(0.1), Color(0xFF4CAF50).withOpacity(0.1)], // Colores Cubalink23
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(0xFF37474F).withOpacity(0.2), // Azul gris oscuro Cubalink23
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Información de Recarga',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Envía una recarga a un móvil. Recuerda que las recargas son irreversibles por lo que te recomendamos que verifique el número al cual desea enviar la recarga.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity( 0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Selección de país
              Text(
                'País *',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<Country>(
                initialValue: _selectedCountry,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              
              SizedBox(height: 20),
              
              // Selección de operador
              Text(
                'Operador *',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              if (_selectedCountry != null)
                DropdownButtonFormField<Operator>(
                  initialValue: _selectedOperator,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      _selectedAmount = null;
                    });
                  },
                ),
              
              SizedBox(height: 20),
              
              // Opción de escoger de contactos
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.secondary.withOpacity( 0.2),
                  ),
                ),
                child: InkWell(
                  onTap: _selectFromContacts,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.contacts_outlined,
                          color: colorScheme.secondary,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Escoger de la lista de contactos',
                            style: TextStyle(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: colorScheme.secondary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Número de teléfono
              Text(
                'Número *',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
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
                        hintText: _selectedCountry?.code == 'MX' ? '5512345678' : '1234567890',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un número';
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
              
              SizedBox(height: 24),
              
              // Cantidad a enviar
              Text(
                'Cantidad a enviar *',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 12),
              if (_selectedOperator != null)
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: _selectedOperator!.amounts.length,
                  itemBuilder: (context, index) {
                    final amount = _selectedOperator!.amounts[index];
                    final isSelected = _selectedAmount == amount;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAmount = amount;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? colorScheme.primary.withOpacity( 0.1)
                            : colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                              ? colorScheme.primary
                              : colorScheme.outline.withOpacity( 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              amount.description,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (amount.bonus != null) ...[
                              SizedBox(height: 4),
                              Text(
                                amount.bonus!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.secondary,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              
              SizedBox(height: 24),
              
              // Resumen del costo
              if (_selectedAmount != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity( 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity( 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Usted paga:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${_selectedAmount!.cost.toStringAsFixed(2)} USD',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: 32),
              
              // Botón de proceder
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedAmount != null ? _proceedToPayment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continuar al pago',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}