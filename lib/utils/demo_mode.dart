/// Demo Mode Configuration
/// This file provides dummy data and configuration for UI testing without backend.
/// Set DEMO_MODE_ENABLED to true to enable demo mode throughout the app.

import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';

/// Global flag to enable/disable demo mode
const bool DEMO_MODE_ENABLED = true;

/// Demo user type - switch between 'provider' and 'handyman'
const String DEMO_USER_TYPE = USER_TYPE_PROVIDER; // or USER_TYPE_HANDYMAN

/// Demo User Data
class DemoData {
  /// Demo Provider User
  static UserData get demoProviderUser => UserData(
        id: 1,
        uid: 'demo_provider_uid_001',
        username: 'demo_provider',
        firstName: 'John',
        lastName: 'Provider',
        email: 'demo@provider.com',
        userType: USER_TYPE_PROVIDER,
        contactNumber: '+1234567890',
        countryId: 1,
        stateId: 1,
        cityId: 1,
        address: '123 Demo Street, Demo City, DC 12345',
        status: 1,
        displayName: 'John Provider',
        profileImage: 'https://i.pravatar.cc/300?u=demo_provider',
        description:
            'Professional service provider with 5+ years of experience.',
        designation: 'Senior Provider',
        apiToken: 'demo_api_token_12345',
        createdAt: '2023-01-15 10:30:00',
        isVerifiedAccount: 1,
        totalBooking: 150,
        providerServiceRating: 4.8,
        knownLanguages: '["English", "Spanish", "French"]',
        skills: '["Plumbing", "Electrical", "Carpentry"]',
        whyChooseMe:
            '{"title": "Why Choose Me", "about_description": "Experienced professional dedicated to quality service", "reason": ["Fast Response", "Quality Work", "Affordable Prices"]}',
      );

  /// Demo Handyman User
  static UserData get demoHandymanUser => UserData(
        id: 2,
        uid: 'demo_handyman_uid_002',
        username: 'demo_handyman',
        firstName: 'Mike',
        lastName: 'Handyman',
        email: 'demo@handyman.com',
        userType: USER_TYPE_HANDYMAN,
        contactNumber: '+1987654321',
        countryId: 1,
        stateId: 1,
        cityId: 1,
        address: '456 Service Lane, Work City, WC 54321',
        providerId: 1,
        status: 1,
        displayName: 'Mike Handyman',
        profileImage: 'https://i.pravatar.cc/300?u=demo_handyman',
        description: 'Skilled handyman specializing in home repairs.',
        designation: 'Expert Handyman',
        apiToken: 'demo_api_token_67890',
        createdAt: '2023-03-20 14:45:00',
        isHandymanAvailable: true,
        handymanRating: 4.6,
        isVerifiedHandyman: 1,
      );

  /// Get demo user based on current demo user type
  static UserData get currentDemoUser => DEMO_USER_TYPE == USER_TYPE_PROVIDER
      ? demoProviderUser
      : demoHandymanUser;
}
