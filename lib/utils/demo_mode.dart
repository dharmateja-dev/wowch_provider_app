/// Demo Mode Configuration
/// This file manages the demo/development mode for UI testing.
///
/// IMPORTANT: This is for UI RESKINNING without a backend.
/// The login will bypass real API but feel like a real login.
/// All other APIs will fallback to dummy data when they fail.

import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';

//=============================================================================
// DEMO MODE CONFIGURATION FLAGS
//=============================================================================

/// Global flag to enable demo mode (API fallback to dummy data)
/// When true, all API calls that fail will return dummy data instead of errors
const bool DEMO_MODE_ENABLED = true;

/// Auto-login flag - bypasses sign-in screen completely
/// Set to FALSE to experience the real login flow
const bool DEMO_AUTO_LOGIN = false;

/// Show demo login buttons on sign-in screen
/// Set to TRUE to show demo buttons for quick testing
const bool SHOW_DEMO_BUTTONS = true;

/// Auto-login user type - only used when DEMO_AUTO_LOGIN is true
const String DEMO_AUTO_LOGIN_USER_TYPE = USER_TYPE_PROVIDER;

//=============================================================================
// REAL USER CREDENTIALS
// These are realistic user accounts for testing
// Password must be 8-12 characters to pass validation
//=============================================================================

/// Provider User Credentials
const String DEMO_PROVIDER_EMAIL = 'john.williams@servicepro.com';
const String DEMO_PROVIDER_PASSWORD = 'Provider@1'; // 10 characters

/// Handyman User Credentials
const String DEMO_HANDYMAN_EMAIL = 'mike.johnson@servicepro.com';
const String DEMO_HANDYMAN_PASSWORD = 'Handyman@1'; // 10 characters

//=============================================================================
// REALISTIC USER DATA
// Professional user profiles that feel like real accounts
//=============================================================================

class DemoData {
  /// Provider User - A professional service provider company
  static UserData get demoProviderUser => UserData(
        id: 1,
        uid: 'prov_jwilliams_001',
        username: 'john.williams',
        firstName: 'John',
        lastName: 'Williams',
        email: DEMO_PROVIDER_EMAIL,
        userType: USER_TYPE_PROVIDER,
        contactNumber: '+1 (555) 123-4567',
        countryId: 1,
        stateId: 1,
        cityId: 1,
        address: '2847 Sunset Boulevard, Suite 200, Los Angeles, CA 90028',
        status: 1,
        displayName: 'John Williams',
        profileImage:
            'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400',
        description:
            'ServicePro is a leading home services company with over 10 years of experience. We specialize in electrical, plumbing, HVAC, and general home repairs. Our team of certified professionals is committed to delivering exceptional quality and customer satisfaction.',
        designation: 'Founder & CEO',
        apiToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.demo_provider_token',
        createdAt: '2020-06-15 09:30:00',
        isVerifiedAccount: 1,
        totalBooking: 1247,
        providerServiceRating: 4.9,
        knownLanguages: '["English", "Spanish"]',
        skills:
            '["Business Management", "Customer Service", "Team Leadership"]',
        whyChooseMe:
            '{"title": "Why Choose ServicePro?", "about_description": "With over a decade of experience and 1000+ satisfied customers, we deliver professional home services you can trust.", "reason": ["Licensed & Insured", "24/7 Emergency Service", "Satisfaction Guaranteed", "Transparent Pricing"]}',
      );

  /// Handyman User - A skilled technician working for the provider
  static UserData get demoHandymanUser => UserData(
        id: 2,
        uid: 'tech_mjohnson_002',
        username: 'mike.johnson',
        firstName: 'Mike',
        lastName: 'Johnson',
        email: DEMO_HANDYMAN_EMAIL,
        userType: USER_TYPE_HANDYMAN,
        contactNumber: '+1 (555) 987-6543',
        countryId: 1,
        stateId: 1,
        cityId: 1,
        address: '1520 Oak Street, Apt 3B, Los Angeles, CA 90015',
        providerId: 1,
        status: 1,
        displayName: 'Mike Johnson',
        profileImage:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        description:
            'Experienced technician with 8+ years in electrical and plumbing work. Certified electrician with expertise in residential and commercial installations. Known for quick response times and quality workmanship.',
        designation: 'Senior Technician',
        apiToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.demo_handyman_token',
        createdAt: '2021-03-10 14:45:00',
        isHandymanAvailable: true,
        handymanRating: 4.8,
        isVerifiedHandyman: 1,
        knownLanguages: '["English", "Spanish", "Portuguese"]',
        skills:
            '["Electrical Systems", "Plumbing", "HVAC", "Smart Home Installation"]',
      );

  /// Get demo user based on configured type
  static UserData get currentDemoUser =>
      DEMO_AUTO_LOGIN_USER_TYPE == USER_TYPE_PROVIDER
          ? demoProviderUser
          : demoHandymanUser;

  /// Get demo user for auto-login
  static UserData get autoLoginUser =>
      DEMO_AUTO_LOGIN_USER_TYPE == USER_TYPE_PROVIDER
          ? demoProviderUser
          : demoHandymanUser;

  /// Get demo user by email
  static UserData? getUserByEmail(String email) {
    if (email.toLowerCase() == DEMO_PROVIDER_EMAIL.toLowerCase()) {
      return demoProviderUser;
    }
    if (email.toLowerCase() == DEMO_HANDYMAN_EMAIL.toLowerCase()) {
      return demoHandymanUser;
    }
    // Also match old demo emails for backward compatibility
    if (email == 'demo@provider.com' || email == DEFAULT_PROVIDER_EMAIL) {
      return demoProviderUser;
    }
    if (email == 'demo@handyman.com' || email == DEFAULT_HANDYMAN_EMAIL) {
      return demoHandymanUser;
    }
    return null;
  }

  /// Validate credentials - accepts any valid-looking credentials in demo mode
  static bool validateCredentials(String email, String password) {
    // In demo mode, accept any email that looks valid with any password 8+ chars
    if (email.isNotEmpty && email.contains('@') && password.length >= 8) {
      return true;
    }
    return false;
  }

  /// Get user for any email (creates a user based on email pattern)
  static UserData getUserForEmail(String email) {
    // Check if it matches our demo emails
    final demoUser = getUserByEmail(email);
    if (demoUser != null) return demoUser;

    // Default to provider for unknown emails
    return demoProviderUser;
  }
}
