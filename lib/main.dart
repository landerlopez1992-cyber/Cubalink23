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
import 'package:cubalink23/screens/work/work_selection_screen.dart';
import 'package:cubalink23/screens/work/seller_application_screen.dart';
import 'package:cubalink23/screens/work/delivery_application_screen.dart';
import 'package:cubalink23/theme.dart';
import 'package:cubalink23/models/user.dart';
import 'package:cubalink23/models/flight_offer.dart';

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
        '/work_selection': (context) => WorkSelectionScreen(),
        '/seller_application': (context) => SellerApplicationScreen(),
        '/delivery_application': (context) => DeliveryApplicationScreen(),
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