import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:cubalink23/screens/splash/splash_screen.dart';
import 'package:cubalink23/screens/home/home_screen.dart';
import 'package:cubalink23/screens/profile/profile_screen.dart';
import 'package:cubalink23/screens/profile/account_screen.dart';
import 'package:cubalink23/screens/settings/settings_screen.dart';
import 'package:cubalink23/screens/referral/referral_screen.dart';
import 'package:cubalink23/screens/shopping/store_screen.dart';
import 'package:cubalink23/screens/shopping/cart_screen.dart';
import 'package:cubalink23/screens/balance/add_balance_screen.dart';
import 'package:cubalink23/screens/communication/communication_screen.dart';
import 'package:cubalink23/screens/history/history_screen.dart';
import 'package:cubalink23/screens/notifications/notifications_screen.dart';
import 'package:cubalink23/screens/help/help_screen.dart';
import 'package:cubalink23/screens/activity/activity_screen.dart';
import 'package:cubalink23/screens/transfer/transfer_screen.dart';
import 'package:cubalink23/screens/recharge/recharge_home_screen.dart';
import 'package:cubalink23/screens/profile/favorites_screen.dart';
import 'package:cubalink23/screens/travel/flight_booking_screen.dart';
import 'package:cubalink23/screens/travel/flight_results_screen.dart';
import 'package:cubalink23/screens/travel/flight_detail_simple.dart';
import 'package:cubalink23/screens/shopping/amazon_shopping_screen.dart';
import 'package:cubalink23/screens/welcome/welcome_screen.dart';
import 'package:cubalink23/screens/auth/login_screen.dart';
import 'package:cubalink23/screens/auth/register_screen.dart';
import 'package:cubalink23/screens/maintenance/maintenance_screen.dart';
import 'package:cubalink23/screens/update/force_update_screen.dart';
import 'package:cubalink23/screens/vendor/vendor_dashboard_screen.dart';
import 'package:cubalink23/screens/delivery/delivery_dashboard_screen.dart';
import 'package:cubalink23/screens/delivery/delivery_notifications_screen.dart';
import 'package:cubalink23/screens/delivery/delivery_assigned_orders_screen.dart';
import 'package:cubalink23/screens/delivery/delivery_wallet_screen.dart';
import 'package:cubalink23/screens/delivery/delivery_profile_screen.dart';
import 'package:cubalink23/screens/delivery/delivery_support_chat_screen.dart';
import 'package:cubalink23/screens/vendor/vendor_orders_screen.dart';
import 'package:cubalink23/screens/vendor/vendor_products_screen.dart';
import 'package:cubalink23/screens/vendor/vendor_wallet_screen.dart';
import 'package:cubalink23/screens/vendor/vendor_support_screen.dart';
import 'package:cubalink23/screens/vendor/vendor_notifications_screen.dart';
import 'package:cubalink23/screens/shopping/checkout_screen.dart';
import 'package:cubalink23/screens/shopping/order_confirmation_screen.dart';
import 'package:cubalink23/screens/settings/language_settings_screen.dart';
import 'package:cubalink23/screens/payment/payment_method_screen.dart';
import 'package:cubalink23/screens/support/support_chat_screen.dart';
import 'package:cubalink23/screens/auth/change_password_screen.dart';
import 'package:cubalink23/screens/shopping/shipping_screen.dart';
import 'package:cubalink23/screens/news/news_screen.dart';
import 'package:cubalink23/screens/communication/chat_screen.dart';
import 'package:cubalink23/screens/travel/flight_booking_enhanced.dart';
import 'package:cubalink23/models/flight_offer.dart';
import 'package:cubalink23/screens/work/work_selection_screen.dart';
import 'package:cubalink23/screens/work/seller_application_screen.dart';
import 'package:cubalink23/screens/work/delivery_application_screen.dart';
import 'package:cubalink23/screens/vendor/vendor_detail_screen.dart';
import 'package:cubalink23/screens/legal/terms_conditions_screen.dart';
import 'package:cubalink23/screens/legal/privacy_policy_screen.dart';
import 'package:cubalink23/screens/legal/vendor_terms_screen.dart';
import 'package:cubalink23/screens/legal/delivery_terms_screen.dart';
import 'package:cubalink23/theme.dart';
import 'package:cubalink23/models/user.dart';

/// Main application entry point with Supabase initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Inicializando CubaLink23...');
  
  // Initialize Firebase (temporalmente deshabilitado)
  try {
    await Firebase.initializeApp();
    print('✅ Firebase inicializado');
  } catch (e) {
    print('⚠️ Firebase no disponible: $e');
  }
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  print('✅ CubaLink23 listo para ejecutar');
  
  runApp(CubaLink23App());
}

/// Main CubaLink23 Application
class CubaLink23App extends StatelessWidget {
  const CubaLink23App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CubaLink23',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: SplashScreen(), // Will handle authentication flow
      routes: {
        '/home': (context) => HomeScreen(user: _getDemoUser()),
        '/profile': (context) => ProfileScreen(),
        '/account': (context) => AccountScreen(),
        '/settings': (context) => SettingsScreen(),
        '/referral': (context) => ReferralScreen(),
        '/store': (context) => StoreScreen(),
        '/cart': (context) => CartScreen(),
        '/add-balance': (context) => AddBalanceScreen(),
        '/communication': (context) => CommunicationScreen(),
        '/history': (context) => HistoryScreen(),
        '/notifications': (context) => NotificationsScreen(),
        '/help': (context) => HelpScreen(),
        '/activity': (context) => ActivityScreen(),
        '/transfer': (context) => TransferScreen(),
        '/recharge': (context) => RechargeHomeScreen(),
        '/favorites': (context) => FavoritesScreen(),
        '/flights': (context) => FlightBookingScreen(),
        '/flight-search': (context) => FlightBookingScreen(),
        '/flight-results': (context) => FlightResultsScreen(
          flightOffers: [],
          fromAirport: '',
          toAirport: '',
          departureDate: '',
          passengers: 1,
          airlineType: 'all',
        ),
        '/flight-details': (context) => FlightDetailSimple(flight: FlightOffer(
          id: '',
          totalAmount: '0',
          totalCurrency: 'USD',
          airline: '',
          departureTime: '',
          arrivalTime: '',
          duration: '',
          stops: 0,
          segments: [],
          rawData: {},
          airlineLogo: '',
        )),
        '/amazon-shopping': (context) => AmazonShoppingScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/maintenance': (context) => MaintenanceScreen(),
        '/force-update': (context) => ForceUpdateScreen(),
        '/vendor-dashboard': (context) => VendorDashboardScreen(),
        '/delivery-dashboard': (context) => DeliveryDashboardScreen(),
        // Rutas de repartidor
        '/delivery-notifications': (context) => DeliveryNotificationsScreen(),
        '/delivery-orders': (context) => DeliveryAssignedOrdersScreen(),
        '/delivery-wallet': (context) => DeliveryWalletScreen(),
        '/delivery-profile': (context) => DeliveryProfileScreen(),
        '/delivery-support': (context) => DeliverySupportChatScreen(),
        // Rutas de vendedor
          '/vendor-orders': (context) => VendorOrdersScreen(),
          '/vendor-products': (context) => VendorProductsScreen(),
          '/vendor-wallet': (context) => VendorWalletScreen(),
          '/vendor-support': (context) => VendorSupportScreen(),
          '/vendor-notifications': (context) => VendorNotificationsScreen(),
        '/work_selection': (context) => WorkSelectionScreen(),
        '/seller_application': (context) => SellerApplicationScreen(),
        '/delivery_application': (context) => DeliveryApplicationScreen(),
        '/vendor_detail': (context) => VendorDetailScreen(
          vendorId: '',
          vendorName: '',
        ),
        '/terms_conditions': (context) => TermsConditionsScreen(),
        '/privacy_policy': (context) => PrivacyPolicyScreen(),
        '/vendor_terms': (context) => VendorTermsScreen(),
        '/delivery_terms': (context) => DeliveryTermsScreen(),
        // Rutas de las 10 pantallas principales
        '/payment_method': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return PaymentMethodScreen(
            amount: args?['amount'] ?? 0.0,
            fee: args?['fee'] ?? 0.0,
            total: args?['total'] ?? 0.0,
            metadata: args?['metadata'],
          );
        },
        '/support-chat': (context) => SupportChatScreen(),
        '/change-password': (context) => ChangePasswordScreen(),
        '/shipping': (context) => ShippingScreen(),
        '/checkout': (context) => CheckoutScreen(),
        '/order-confirmation': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return OrderConfirmationScreen(
            orderNumber: args?['orderNumber'],
            total: args?['total'],
            items: args?['items'],
          );
        },
        '/news': (context) => NewsScreen(),
        '/language-settings': (context) => LanguageSettingsScreen(),
        '/chat': (context) => ChatScreen(),
        '/flight-booking-enhanced': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return FlightBookingEnhanced(
            flight: args?['flight'] ?? FlightOffer(
              id: '',
              totalAmount: '0',
              totalCurrency: 'USD',
              airline: '',
              departureTime: '',
              arrivalTime: '',
              duration: '',
              stops: 0,
              segments: [],
              rawData: {},
              airlineLogo: '',
            ),
          );
        },
      },
    );
  }

  // Método temporal para obtener un usuario demo
  static User _getDemoUser() {
    return User(
      id: '1',
      name: 'Usuario Demo',
      email: 'demo@cubalink23.com',
      phone: '+1234567890',
      balance: 150.00,
      createdAt: DateTime.now(),
    );
  }
}