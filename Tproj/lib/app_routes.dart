import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/signup_confirmation_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/account/account_center_screen.dart';
import 'screens/account/change_password_screen.dart';
import 'screens/account/address_list_screen.dart';
import 'screens/account/address_form_screen.dart';
import 'screens/account/payment_method_list_screen.dart';
import 'screens/account/payment_method_form_screen.dart';
import 'screens/inspections/inspection_request_screen.dart';
import 'screens/inspections/inspection_detail_screen.dart';
import 'screens/inspections/delivery_detail_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_map_screen.dart';
import 'screens/admin/admin_agents_screen.dart';
import 'screens/admin/admin_inspections_screen.dart';
import 'screens/admin/admin_deliveries_screen.dart';
import 'models/address.dart';
import 'models/payment_method.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String signupConfirmation = '/signup/confirmation';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String orders = '/orders';
  static const String accountCenter = '/account';
  static const String changePassword = '/account/password';
  static const String addressList = '/address/list';
  static const String addAddress = '/address/add';
  static const String editAddress = '/address/edit';
  static const String paymentMethodList = '/payment/list';
  static const String addPaymentMethod = '/payment/add';
  static const String editPaymentMethod = '/payment/edit';
  static const String inspectionRequest = '/inspection/request';
  static const String inspectionDetail = '/inspection/detail';
  static const String deliveryDetail = '/delivery/detail';
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminMap = '/admin/map';
  static const String adminAgents = '/admin/agents';
  static const String adminInspections = '/admin/inspections';
  static const String adminDeliveries = '/admin/deliveries';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case signupConfirmation:
        return MaterialPageRoute(builder: (_) => const SignupConfirmationScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case orders:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      case accountCenter:
        return MaterialPageRoute(builder: (_) => const AccountCenterScreen());
      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case addressList:
        return MaterialPageRoute(builder: (_) => const AddressListScreen());
      case addAddress:
        return MaterialPageRoute(builder: (_) => const AddressFormScreen());
      case editAddress:
        final address = settings.arguments as Address;
        return MaterialPageRoute(
          builder: (_) => AddressFormScreen(
            initialAddress: address,
            isEditing: true,
          ),
        );
      case paymentMethodList:
        return MaterialPageRoute(builder: (_) => const PaymentMethodListScreen());
      case addPaymentMethod:
        return MaterialPageRoute(builder: (_) => const PaymentMethodFormScreen());
      case editPaymentMethod:
        final paymentMethod = settings.arguments as PaymentMethod;
        return MaterialPageRoute(
          builder: (_) => PaymentMethodFormScreen(
            initialPaymentMethod: paymentMethod,
            isEditing: true,
          ),
        );
      case inspectionRequest:
        return MaterialPageRoute(builder: (_) => const InspectionRequestScreen());
      case inspectionDetail:
        final inspectionId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => InspectionDetailScreen(inspectionId: inspectionId),
        );
      case deliveryDetail:
        final deliveryId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => DeliveryDetailScreen(deliveryId: deliveryId),
        );
      case adminLogin:
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case adminMap:
        return MaterialPageRoute(builder: (_) => const AdminMapScreen());
      case adminAgents:
        return MaterialPageRoute(builder: (_) => const AdminAgentsScreen());
      case adminInspections:
        return MaterialPageRoute(builder: (_) => const AdminInspectionsScreen());
      case adminDeliveries:
        return MaterialPageRoute(builder: (_) => const AdminDeliveriesScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
