// File: lib/constants/app_routes.dart
import 'package:flutter/material.dart';

// ────── models ──────
import '../models/user.dart';
import '../models/address.dart';
import '../models/payment_method.dart';

// ────── auth ──────
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/signup_confirmation_screen.dart';
import '../screens/account/change_password_screen.dart';   // reused as placeholder
// (If you have a real ForgotPasswordScreen, import it and swap below)

// ────── user-facing ──────
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/account/account_center_screen.dart';
import '../screens/account/address_list_screen.dart';
import '../screens/account/address_form_screen.dart';
import '../screens/account/payment_method_list_screen.dart';
import '../screens/account/payment_method_form_screen.dart';
import '../screens/inspections/inspection_request_screen.dart';
import '../screens/inspections/inspection_detail_screen.dart';
import '../screens/inspections/delivery_detail_screen.dart';
import '../screens/inspections/deliveries_request_screen.dart';

// ────── admin ──────
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_map_screen.dart';
import '../screens/admin/admin_agents_screen.dart';
import '../screens/admin/add_agent_screen.dart';
import '../screens/admin/admin_inspections_screen.dart';
import '../screens/admin/admin_deliveries_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/admin/agent_info_screen.dart';

class AppRoutes {
  static const splash                = '/';
  // ───────── public auth ─────────
  static const login                 = '/login';
  static const signup                = '/signup';
  static const signupConfirmation    = '/signup/confirmation';
  static const forgotPassword        = '/forgot-password';   // ← added

  // ───────── main nav ─────────
  static const home                  = '/home';
  static const profile               = '/profile';
  static const orders                = '/orders';
  static const deliveriesRequests    = '/deliveries';

  // ───────── account ─────────
  static const accountCenter         = '/account';
  static const changePassword        = '/account/password';
  static const changeEmail           = '/account/email';     // ← added

  // addresses & payments
  static const addressList           = '/address/list';
  static const addAddress            = '/address/add';
  static const editAddress           = '/address/edit';
  static const paymentMethodList     = '/payment/list';
  static const addPaymentMethod      = '/payment/add';
  static const editPaymentMethod     = '/payment/edit';

  // inspections / deliveries
  static const inspectionRequest     = '/inspection/request';
  static const inspectionDetail      = '/inspection/detail';
  static const deliveryDetail        = '/delivery/detail';

  // ───────── admin ─────────
  static const adminLogin            = '/admin/login';
  static const adminDashboard        = '/admin/dashboard';
  static const adminMap              = '/admin/map';
  static const adminAgents           = '/admin/agents';
  static const adminAddAgent         = '/admin/agent/add';
  static const adminInspections      = '/admin/inspections';
  static const adminDeliveries       = '/admin/deliveries';

  // ────────────────────────────────────────────────────────────
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:             return MaterialPageRoute(builder: (_) => const SplashScreen());
      // auth
      case login:              return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:             return MaterialPageRoute(builder: (_) => const SignupScreen());

      case signupConfirmation:
        final user = settings.arguments as User; // required param
        return MaterialPageRoute(
          builder: (_) => SignupConfirmationScreen(user: user),
        );

      case forgotPassword:
        // Placeholder: re-using ChangePasswordScreen.
        // Replace with your real ForgotPasswordScreen if you have one.
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      // main nav
      case home:        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case profile:     return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case orders:      return MaterialPageRoute(builder: (_) => const OrdersScreen());
      case deliveriesRequests: return MaterialPageRoute(builder: (_) => const DeliveriesRequestScreen());

      // account
      case accountCenter:  return MaterialPageRoute(builder: (_) => const AccountCenterScreen());
      case changePassword: return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case changeEmail:    return MaterialPageRoute(builder: (_) => const ChangePasswordScreen()); // placeholder

      // addresses
      case addressList:  return MaterialPageRoute(builder: (_) => const AddressListScreen());
      case addAddress:   return MaterialPageRoute(builder: (_) => const AddressFormScreen());
      case editAddress:
        final address = settings.arguments as Address;
        return MaterialPageRoute(
          builder: (_) => AddressFormScreen(initialAddress: address, isEditing: true),
        );

      // payment methods
      case paymentMethodList: return MaterialPageRoute(builder: (_) => const PaymentMethodListScreen());
      case addPaymentMethod:  return MaterialPageRoute(builder: (_) => const PaymentMethodFormScreen());
      case editPaymentMethod:
        final pm = settings.arguments as PaymentMethod;
        return MaterialPageRoute(
          builder: (_) => PaymentMethodFormScreen(initialPaymentMethod: pm, isEditing: true),
        );

      // inspections / deliveries
      case inspectionRequest: return MaterialPageRoute(builder: (_) => const InspectionRequestScreen());
      case inspectionDetail:
        final id = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => InspectionDetailScreen(inspectionId: id));
      case deliveryDetail:
        final id = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => DeliveryDetailScreen(deliveryId: id));

      // admin
      case adminLogin:       return MaterialPageRoute(builder: (_) => const AdminLoginScreen());
      case adminDashboard:   return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case adminMap:         return MaterialPageRoute(builder: (_) => const AdminMapScreen());
      case adminAgents:      return MaterialPageRoute(builder: (_) => const AdminAgentsScreen());
      case adminAddAgent:    return MaterialPageRoute(builder: (_) => const AddAgentScreen());
      case adminInspections: return MaterialPageRoute(builder: (_) => const AdminInspectionsScreen());
      case adminDeliveries:  return MaterialPageRoute(builder: (_) => const AdminDeliveriesScreen());
      case '/admin/agent/details': final id = settings.arguments as String; return MaterialPageRoute(builder: (_) => AgentInfoScreen(agentId: id));
      

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
