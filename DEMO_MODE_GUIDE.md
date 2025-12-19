# Demo Mode Setup Guide

This document explains how to use the Demo Mode feature for UI testing without a backend server.

## Overview

Demo Mode allows you to:
- Login without a backend server
- View all main screens with realistic dummy data
- Test and reskin the UI without needing backend configuration

## How to Enable/Disable Demo Mode

### File: `lib/utils/demo_mode.dart`

```dart
/// Set to true to enable demo mode
const bool DEMO_MODE_ENABLED = true;

/// Change user type for testing
const String DEMO_USER_TYPE = USER_TYPE_PROVIDER; // or USER_TYPE_HANDYMAN
```

**To Enable Demo Mode:**
- Set `DEMO_MODE_ENABLED = true`

**To Disable Demo Mode:**
- Set `DEMO_MODE_ENABLED = false`

**To Switch Between Provider and Handyman:**
- Change `DEMO_USER_TYPE` to `USER_TYPE_PROVIDER` or `USER_TYPE_HANDYMAN`

## What Works in Demo Mode

### ✅ Fully Functional with Demo Data:
1. **Splash Screen** - Bypasses configuration check
2. **Sign In Screen** - Any email/password works with demo login
3. **Provider Dashboard** - Shows services, handymen, bookings, revenue chart
4. **Bookings List** - Shows demo booking data with various statuses
5. **Notifications** - Shows sample notifications
6. **Payments** - Shows payment history
7. **Profile Screen** - Uses demo user data from login

### ⚠️ Screens That Navigate But May Need Additional Demo Data:
- Service List Screen
- Service Detail Screen
- Booking Detail Screen
- Handyman List Screen
- Settings/Configuration screens
- Chat screens (requires Firebase)

## Demo Data Files

### `lib/utils/demo_mode.dart`
- Global demo mode flag
- Demo user data for Provider and Handyman

### `lib/utils/demo_data.dart`
- Demo dashboard data
- Demo services list
- Demo handymen list
- Demo bookings list
- Demo notifications list
- Demo payments list
- Demo customers list
- Revenue chart data

## Customizing Demo Data

You can modify the demo data in `lib/utils/demo_data.dart` to:
- Add more services
- Add more bookings with different statuses
- Modify user information
- Add more payments and notifications

### Example: Adding a New Demo Service

```dart
ServiceData(
  id: 7,
  name: 'Your New Service',
  categoryId: 7,
  categoryName: 'Your Category',
  providerId: 1,
  providerName: 'John Provider',
  price: 100.00,
  type: SERVICE_TYPE_FIXED,
  discount: 10,
  duration: '01:00',
  status: 1,
  description: 'Description of your service',
  isFeatured: 1,
  totalReview: 20,
  totalRating: 4.5,
  visitType: VISIT_OPTION_ON_SITE,
  imageAttachments: [
    'https://your-image-url.com/image.jpg',
  ],
),
```

## Files Modified for Demo Mode

1. `lib/utils/demo_mode.dart` - **NEW** - Main configuration
2. `lib/utils/demo_data.dart` - **NEW** - All demo data
3. `lib/screens/splash_screen.dart` - Modified to check demo mode
4. `lib/auth/sign_in_screen.dart` - Modified for demo login
5. `lib/provider/fragments/provider_home_fragment.dart` - Uses demo dashboard
6. `lib/fragments/booking_fragment.dart` - Uses demo bookings
7. `lib/fragments/notification_fragment.dart` - Uses demo notifications
8. `lib/provider/fragments/provider_payment_fragment.dart` - Uses demo payments

## Extending Demo Mode to Other Screens

To add demo mode support to another screen:

```dart
import 'package:handyman_provider_flutter/utils/demo_mode.dart';
import 'package:handyman_provider_flutter/utils/demo_data.dart';

// In your init() or data loading function:
void init() async {
  if (DEMO_MODE_ENABLED) {
    // Use demo data
    myData = demoDataList;
    future = Future.value(myData);
    setState(() {});
    return;
  }
  
  // Original API call
  future = fetchDataFromAPI();
}
```

## Notes

- Demo mode does NOT require internet connection for main screens
- Firebase features (chat, push notifications) require real Firebase config
- The demo login creates a mock user session that persists until logout
- All demo data is hardcoded and can be modified as needed
