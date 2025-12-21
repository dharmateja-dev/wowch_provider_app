/// Demo API Helper
/// This file provides simple API fallback mechanisms for demo mode.
/// When DEMO_MODE_ENABLED is true, screens can use this to get demo data
/// when API calls fail.
///
/// Usage in screens:
/// ```dart
/// try {
///   return await realApiCall();
/// } catch (e) {
///   if (DEMO_MODE_ENABLED) {
///     return DemoApiHelper.getDashboardData();
///   }
///   rethrow;
/// }
/// ```

import 'package:handyman_provider_flutter/models/dashboard_response.dart'
    as dashboard;
import 'package:handyman_provider_flutter/models/handyman_dashboard_response.dart'
    as handyman;
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/utils/demo_data.dart';
import 'package:handyman_provider_flutter/utils/demo_mode.dart';

/// Global Demo API Helper - Use this to get fallback data when APIs fail
class DemoApiHelper {
  //===========================================================================
  // DASHBOARD DATA
  //===========================================================================

  /// Get Provider Dashboard Data
  static dashboard.DashboardResponse getProviderDashboard() {
    return DemoDashboardData.providerDashboard;
  }

  /// Get Handyman Dashboard Data
  static handyman.HandymanDashBoardResponse getHandymanDashboard() {
    return DemoDashboardData.handymanDashboard;
  }

  //===========================================================================
  // SERVICE DATA
  //===========================================================================

  /// Get Service List
  static List<ServiceData> getServiceList({int? categoryId}) {
    if (categoryId != null) {
      return demoServices.where((s) => s.categoryId == categoryId).toList();
    }
    return demoServices;
  }

  /// Get Service Detail
  static ServiceData getServiceDetail(int serviceId) {
    return demoServices.firstWhere(
      (s) => s.id == serviceId,
      orElse: () => demoServices.first,
    );
  }

  //===========================================================================
  // HANDYMAN DATA
  //===========================================================================

  /// Get Handyman List
  static List<UserData> getHandymanList({bool? isAvailable}) {
    if (isAvailable != null) {
      return demoHandymen
          .where((h) => h.isHandymanAvailable == isAvailable)
          .toList();
    }
    return demoHandymen;
  }

  /// Get Handyman Detail
  static UserData getHandymanDetail(int handymanId) {
    return demoHandymen.firstWhere(
      (h) => h.id == handymanId,
      orElse: () => demoHandymen.first,
    );
  }

  //===========================================================================
  // WALLET DATA
  //===========================================================================

  /// Get Wallet Balance
  static double getWalletBalance() {
    return 15680.50;
  }

  //===========================================================================
  // EARNINGS DATA
  //===========================================================================

  /// Get Total Earnings as Map (for simple use cases)
  static Map<String, dynamic> getEarningsData() {
    return {
      'total_earning': 125000.00,
      'total_commission': 18750.00,
      'total_booking': 156,
      'completed_booking': 142,
      'pending_booking': 8,
      'cancelled_booking': 6,
    };
  }

  //===========================================================================
  // USER DATA
  //===========================================================================

  /// Get User Detail
  static UserData getUserDetail(int userId) {
    if (userId == DemoData.demoProviderUser.id) {
      return DemoData.demoProviderUser;
    }
    if (userId == DemoData.demoHandymanUser.id) {
      return DemoData.demoHandymanUser;
    }

    // Check customers
    final customer = demoCustomers.firstWhere(
      (c) => c.id == userId,
      orElse: () => demoCustomers.first,
    );
    return customer;
  }

  //===========================================================================
  // BOOKING STATUS COUNTS (Simple Map version)
  //===========================================================================

  /// Get Booking Status Counts as Map
  static Map<String, int> getBookingStatusCounts() {
    return {
      'total': demoBookings.length,
      'pending': demoBookings.where((b) => b.status == 'pending').length,
      'accepted': demoBookings.where((b) => b.status == 'accept').length,
      'ongoing': demoBookings.where((b) => b.status == 'on_going').length,
      'completed': demoBookings.where((b) => b.status == 'completed').length,
      'cancelled': demoBookings.where((b) => b.status == 'cancelled').length,
    };
  }

  //===========================================================================
  // HELPER METHOD FOR API FALLBACK
  //===========================================================================

  /// Check if demo mode is enabled
  static bool get isDemoMode => DEMO_MODE_ENABLED;

  /// Use this method to wrap API calls with demo fallback
  /// Example:
  /// ```dart
  /// try {
  ///   return await apiCall();
  /// } catch (e) {
  ///   return DemoApiHelper.withFallback(() => demoData, e);
  /// }
  /// ```
  static T withFallback<T>(T Function() demoDataGetter, dynamic error) {
    if (DEMO_MODE_ENABLED) {
      return demoDataGetter();
    }
    throw error;
  }
}
