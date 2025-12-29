# Development Phase Requirements Document

## 📋 Project Overview

**Application:** Handyman Provider Flutter App  
**Version:** 11.15.1  
**Date:** December 29, 2024  
**Status:** UI Reskinning Complete → Ready for Development Phase

---

## 🔗 1. REQUIRED APIs

### 1.1 Authentication APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `login` | POST | User authentication with email/password | Existing |
| `register` | POST (Multipart) | New user registration with documents | Existing |
| `logout` | GET | Session termination | Existing |
| `forgot-password` | POST | Password recovery email | Existing |
| `change-password` | POST | Update user password | Existing |
| `user-email-verify` | POST | Email verification | Existing |
| `switch-language` | POST | Change user language preference | Existing |

### 1.2 User Management APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `user-detail?id={id}` | GET | Fetch user profile details | Existing |
| `update-profile` | POST | Update user profile | Existing |
| `user-list?user_type={type}` | GET | List users by type (handyman/provider/user) | Existing |
| `user-update-status` | POST | Update handyman status | Existing |
| `delete-account` | POST | Permanently delete user account | Existing |

### 1.3 Dashboard APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `provider-dashboard` | GET | Provider dashboard data | Existing |
| `handyman-dashboard` | GET | Handyman dashboard data | Existing |
| `configurations` | POST | App configuration settings | Existing |

### 1.4 Service Management APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `service-list` | GET | Get provider's services | Existing |
| `service-detail` | POST | Get service details | Existing |
| `service-save` | POST (Multipart) | Add/Edit service | Existing |
| `service-delete/{id}` | POST | Delete a service | Existing |
| `delete-image` | POST | Delete service image | Existing |
| `category-list` | GET | Get all categories | Existing |
| `subcategory-list` | GET | Get subcategories by category | Existing |

### 1.5 Booking Management APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `booking-list` | GET | Get bookings with filters | Existing |
| `booking-detail` | POST | Get booking details | Existing |
| `booking-status` | GET | Get all booking statuses | Existing |
| `booking-update` | POST | Update booking status | Existing |
| `booking-assign` | POST | Assign booking to handyman | Existing |
| `update-location` | POST | Update handyman location for booking | Existing |
| `get-location` | GET | Get handyman location | Existing |

### 1.6 Payment APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `payment-list` | GET | Get payment transactions | Existing |
| `payment-gateways` | GET | Get available payment methods | Existing |
| `save-payment` | POST | Process payment | Existing |
| `verify-transaction` | POST | Verify FlutterWave transaction | Existing |
| `wallet-list` | GET | Get wallet transactions | Existing |
| `wallet-money-withdraws` | POST | Withdraw wallet money | Existing |
| `bank-detail` | GET | Get bank details | Existing |
| `bank-list` | GET | Get user banks | Existing |
| `choose-default-bank` | POST | Set default bank | Existing |
| `delete-bank` | POST | Delete bank account | Existing |

### 1.7 Subscription/Plans APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `plan-list` | GET | Get available subscription plans | Existing |
| `save-subscription` | POST | Subscribe to a plan | Existing |
| `subscription-history` | GET | Get subscription history | Existing |
| `cancel-subscription` | POST | Cancel subscription | Existing |

### 1.8 Address/Zone APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `zones` | GET | Get available zones | Existing |
| `provider-address-list` | GET | Get provider addresses | Existing |
| `provider-zone-list` | GET | Get provider zones | Existing |
| `save-provider-address` | POST | Add/Edit address | Existing |
| `delete-provider-address/{id}` | POST | Delete address | Existing |
| `country-list` | POST | Get countries | Existing |
| `state-list` | POST | Get states by country | Existing |
| `city-list` | POST | Get cities by state | Existing |

### 1.9 Reviews/Ratings APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `service-reviews` | POST | Get service reviews | Existing |
| `handyman-reviews` | POST | Get handyman reviews | Existing |

### 1.10 Document Management APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `provider-document-list` | GET | Get provider documents | Existing |
| `provider-document-delete/{id}` | POST | Delete document | Existing |
| `document-list` | GET | Get document types | Existing |
| `save-provider-document` | POST (Multipart) | Upload document | Existing |

### 1.11 Job Request/Bidding APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `post-job-list` | GET | Get job requests | Existing |
| `post-job-detail` | POST | Get job request details | Existing |
| `save-bid` | POST | Submit a bid | Existing |
| `get-bidder-list` | GET | Get bids list | Existing |

### 1.12 Addon & Package APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `addon-list` | GET | Get addon services | Existing |
| `addon-save` | POST (Multipart) | Add/Edit addon | Existing |
| `addon-delete/{id}` | POST | Delete addon | Existing |
| `package-list` | GET | Get packages | Existing |
| `package-save` | POST (Multipart) | Add/Edit package | Existing |
| `package-delete/{id}` | POST | Delete package | Existing |

### 1.13 Time Slots APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `provider-slot` | GET | Get provider slots | Existing |
| `service-slot` | GET | Get service slots | Existing |
| `save-provider-slot` | POST | Save provider slots | Existing |
| `save-service-slot` | POST | Save service slots | Existing |
| `update-all-services` | POST | Update all service slots | Existing |

### 1.14 Shop Management APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `shop-list` | GET | Get shops | Existing |
| `shop-detail/{id}` | GET | Get shop details | Existing |
| `add-shop` | POST (Multipart) | Create shop | Existing |
| `edit-shop` | POST (Multipart) | Update shop | Existing |
| `delete-shop/{id}` | POST | Delete shop | Existing |
| `shop-document-list` | GET | Get shop documents | Existing |
| `shop-document-delete/{id}` | POST | Delete shop document | Existing |

### 1.15 Notification APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `notification-list` | POST | Get notifications | Existing |

### 1.16 Earnings/Reports APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `total-earning-list` | GET | Get earnings report | Existing |
| `commission` | GET | Get commission details | Existing |
| `tax-list` | GET | Get tax list | Existing |

### 1.17 Promotional Banner APIs

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `promotional-banner-list` | GET | Get banners | Existing |
| `save-promotional-banner` | POST | Create/Update banner | Existing |
| `delete-promotional-banner` | POST | Delete banner | Existing |

### 1.18 External APIs

| Endpoint | Service | Description | Status |
|----------|---------|-------------|--------|
| Google Places API | Google | Address autocomplete | Required |
| Google Maps SDK | Google | Map display & markers | Required |

---

## 🔌 2. THIRD-PARTY INTEGRATIONS

### 2.1 Firebase Services (Critical)

| Service | Package | Purpose | Configuration Required |
|---------|---------|---------|----------------------|
| **Firebase Core** | `firebase_core: ^4.1.0` | Core Firebase SDK | `google-services.json`, `GoogleService-Info.plist` |
| **Firebase Auth** | `firebase_auth: ^6.0.2` | Chat user authentication | Firebase project configuration |
| **Cloud Firestore** | `cloud_firestore: ^6.0.1` | Real-time chat database | Firestore rules setup |
| **Firebase Storage** | `firebase_storage: ^13.0.1` | Chat file uploads | Storage rules setup |
| **Firebase Messaging** | `firebase_messaging: ^16.0.1` | Push notifications | APNs certificates (iOS), FCM server key |
| **Firebase Crashlytics** | `firebase_crashlytics: ^5.0.1` | Crash reporting | Enable in Firebase Console |

#### Firebase Collections Required:
- `users` - User data for chat
- `messages` - Chat messages
- `contacts` - User contacts

### 2.2 Payment Gateway Integrations

| Gateway | Package | Countries | Configuration Keys |
|---------|---------|-----------|-------------------|
| **Stripe** | `flutter_stripe: ^12.0.2` | Global | `publishableKey`, `secretKey` |
| **Razorpay** | `razorpay_flutter: ^1.4.0` | India | `key_id`, `key_secret` |
| **PayPal** | `flutter_paypal_checkout` (custom) | Global | `clientId`, `secretKey` |
| **Flutterwave** | `flutterwave_standard` (custom) | Africa | `publicKey`, `secretKey` |
| **Paystack** | `flutter_paystack` (custom) | Africa | `publicKey`, `secretKey` |
| **CinetPay** | `cinetpay` (custom) | Africa | `apiKey`, `siteId` |
| **Sadad** | Custom implementation | Middle East | `merchant_id`, `secret_key` |
| **Airtel Money** | Custom implementation | Africa | `client_id`, `client_secret` |
| **PhonePe** | `phonepe_payment_sdk: ^3.0.1` | India | `merchantId`, `saltKey` |
| **Midtrans** | `midpay` (custom) | Indonesia | `clientKey`, `serverKey` |

### 2.3 In-App Purchases

| Platform | Package | Purpose |
|----------|---------|---------|
| RevenueCat | `purchases_flutter: ^9.2.3` | Subscription management |

**Required Keys:**
- `IN_APP_PURCHASE_GOOGLE_API_KEY` - Google Play API key
- `IN_APP_PURCHASE_APPLE_API_KEY` - App Store API key
- `IN_APP_PURCHASE_ENTITLEMENT_IDENTIFIER` - Subscription entitlement ID

### 2.4 Maps & Location

| Service | Package | Purpose | API Key |
|---------|---------|---------|---------|
| **Google Maps** | `google_maps_flutter: ^2.12.3` | Map display | `GOOGLE_MAPS_API_KEY` |
| **Geocoding** | `geocoding: ^4.0.0` | Address geocoding | Google Maps API key |
| **Geolocator** | `geolocator: ^14.0.2` | Location services | - |

### 2.5 Other External Services

| Service | Package | Purpose |
|---------|---------|---------|
| **URL Launcher** | `url_launcher: ^6.3.2` | External links |
| **Share Plus** | `share_plus: ^11.1.0` | Content sharing |
| **Custom Tabs** | `flutter_custom_tabs: ^2.4.0` | In-app browser |
| **Syncfusion Charts** | `syncfusion_flutter_charts: ^30.2.7` | Analytics charts |
| **PDF Viewer** | `syncfusion_flutter_pdfviewer: ^30.2.7` | Document viewing |
| **Version Update** | `playx_version_update: ^1.0.0` | Force update check |

---

## 🏗️ 3. BACKEND SERVICES TO BE DEVELOPED OR MODIFIED

### 3.1 Core Backend (Laravel API - Existing)

The app expects a Laravel-based REST API backend. The following modules need verification/configuration:

#### 3.1.1 Required Backend Endpoints Configuration

```
Base URL: https://your-domain.com/api/
```

**Action Items:**
- [ ] Configure `DOMAIN_URL` in `lib/utils/configs.dart`
- [ ] Set up SSL certificate for HTTPS
- [ ] Configure CORS for API access
- [ ] Set up API rate limiting
- [ ] Configure file upload limits

#### 3.1.2 Backend Modules to Verify

| Module | Description | Status |
|--------|-------------|--------|
| User Authentication | JWT token-based auth | Verify |
| Provider Management | Provider CRUD operations | Verify |
| Handyman Management | Handyman CRUD operations | Verify |
| Service Management | Service CRUD with images | Verify |
| Booking System | Complete booking workflow | Verify |
| Payment Processing | Payment gateway callbacks | Verify |
| Notification System | Push notification triggers | Verify |
| Subscription Management | Plan & billing management | Verify |
| Document Upload | File storage & retrieval | Verify |
| Reviews & Ratings | Rating calculation logic | Verify |
| Commission Calculation | Provider/Handyman earnings | Verify |

### 3.2 Firebase Backend Services

#### 3.2.1 Firestore Database Structure

```javascript
// Users Collection
users/{userId}
├── id: string
├── email: string
├── firstName: string
├── lastName: string
├── profileImage: string
├── uid: string (Firebase Auth UID)
├── createdAt: timestamp
└── updatedAt: timestamp

// Messages Collection
messages/{senderId}/
└── {receiverId}/
    └── {messageId}
        ├── senderId: string
        ├── receiverId: string
        ├── message: string
        ├── messageType: string ('TEXT', 'IMAGE', etc.)
        ├── createdAt: timestamp
        └── isMessageRead: boolean

// Contacts Collection (within users)
users/{userId}/contacts/{contactId}
├── uid: string
├── addedOn: timestamp
├── lastMessageTime: timestamp
└── isOnline: int
```

#### 3.2.2 Firestore Security Rules (Recommended)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null;
      
      match /contacts/{contactId} {
        allow read, write: if request.auth != null;
      }
    }
    
    match /messages/{senderId}/{receiverId}/{messageId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == senderId || request.auth.uid == receiverId);
    }
  }
}
```

#### 3.2.3 Firebase Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /chat_files/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 3.3 Push Notification Backend

#### 3.3.1 Firebase Cloud Messaging (FCM) Topics

| Topic | Subscriber | Description |
|-------|------------|-------------|
| `user_{userId}` | Individual user | Personal notifications |
| `provider_{providerId}` | Provider | Provider-specific updates |
| `handyman_{handymanId}` | Handyman | Handyman-specific updates |
| `providerApp` | All providers | Broadcast to all providers |
| `handymanApp` | All handymen | Broadcast to all handymen |

#### 3.3.2 Notification Types

| Type | Trigger | Data Required |
|------|---------|---------------|
| `add_booking` | New booking created | `booking_id` |
| `assigned_booking` | Booking assigned to handyman | `booking_id` |
| `update_booking_status` | Status changed | `booking_id`, `status` |
| `cancel_booking` | Booking cancelled | `booking_id` |
| `payment_message_status` | Payment received | `booking_id` |
| `chat` | New chat message | `sender_id`, `message` |
| `subscription` | Subscription updates | `plan_id` |

---

## 🔐 4. AUTHENTICATION & AUTHORIZATION REQUIREMENTS

### 4.1 Authentication Flow

```
┌─────────────────┐
│   Login Screen  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  API: /login    │ ──▶ Returns JWT Token + UserData
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Save to AppStore│ ──▶ Token, User ID, Email, etc.
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Firebase Auth   │ ──▶ Create/Login user for Chat
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Subscribe FCM   │ ──▶ Push notification topics
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Dashboard     │
└─────────────────┘
```

### 4.2 Token Management

| Aspect | Implementation |
|--------|----------------|
| Token Type | Bearer JWT |
| Storage | SharedPreferences (secure) |
| Header | `Authorization: Bearer {token}` |
| Refresh | Auto-regenerate on 401 response |
| Expiry | Server-defined (recommended: 24h) |

### 4.3 User Types & Roles

| User Type | Code | Access Level |
|-----------|------|--------------|
| **Provider** | `provider` | Full provider features (services, handyman management, bookings, payments) |
| **Handyman** | `handyman` | Limited features (assigned bookings, availability, earnings) |

### 4.4 Role-Based Permissions

The app supports granular permissions controlled from the backend. Key permission categories:

```dart
// Permission Constants (from app_configuration.dart)
const SERVICE = 'SERVICE';
const SERVICE_ADD = 'SERVICE_ADD';
const SERVICE_LIST = 'SERVICE_LIST';
const SERVICE_EDIT = 'SERVICE_EDIT';
const SERVICE_DELETE = 'SERVICE_DELETE';

const HANDYMAN = 'HANDYMAN';
const HANDYMAN_ADD = 'HANDYMAN_ADD';
const HANDYMAN_LIST = 'HANDYMAN_LIST';
const HANDYMAN_EDIT = 'HANDYMAN_EDIT';
const HANDYMAN_DELETE = 'HANDYMAN_DELETE';

const BOOKING = 'BOOKING';
const BOOKING_LIST = 'BOOKING_LIST';
const BOOKING_EDIT = 'BOOKING_EDIT';
const BOOKING_VIEW = 'BOOKING_VIEW';

const PAYMENT = 'PAYMENT';
const PAYMENT_LIST = 'PAYMENT_LIST';

// ... and many more
```

### 4.5 Authentication Security Requirements

| Requirement | Status | Notes |
|-------------|--------|-------|
| HTTPS Only | ⚠️ Configure | Set in `configs.dart` |
| Password Hashing | ✅ Backend | Bcrypt recommended |
| JWT Secret | ⚠️ Configure | Use strong, unique key |
| Token Validation | ✅ Implemented | Auto-refresh on 401 |
| Secure Storage | ✅ Implemented | SharedPreferences + nb_utils |
| Firebase Auth | ✅ Implemented | For chat functionality |

### 4.6 Firebase Authentication for Chat

```dart
// Default password for Firebase (from constant.dart)
const DEFAULT_PASSWORD_FOR_FIREBASE = '12345678';

// Authentication flow:
// 1. User logs in via API
// 2. App creates/signs into Firebase with user email + default password
// 3. Firebase UID stored in Laravel DB via update-profile API
```

**Security Note:** The current Firebase auth uses a static password. For production:
- Consider implementing Firebase Custom Auth Tokens
- Or use Firebase Admin SDK on backend to create users

---

## ⚙️ 5. CONFIGURATION CHECKLIST

### 5.1 App Configuration (`lib/utils/configs.dart`)

```dart
// Must be updated before development
const APP_NAME = 'Provider App';  // ✅ Update app name
const DEFAULT_LANGUAGE = 'en';     // ✅ Set default language
const DOMAIN_URL = "https://your-api-domain.com"; // ⚠️ CRITICAL - Set your API URL
const BASE_URL = "$DOMAIN_URL/api/";

// iOS App Store Link
const IOS_LINK_FOR_PARTNER = "https://apps.apple.com/...";

// Legal URLs
const TERMS_CONDITION_URL = 'https://...';
const PRIVACY_POLICY_URL = 'https://...';
const HELP_AND_SUPPORT_URL = 'https://...';
const REFUND_POLICY_URL = 'https://...';

// Support
const INQUIRY_SUPPORT_EMAIL = 'support@your-domain.com';
const HELP_LINE_NUMBER = '+1234567890';

// Payment Currencies (configure per region)
const AIRTEL_CURRENCY_CODE = "MWK";
const PAYSTACK_CURRENCY_CODE = 'NGN';
const RAZORPAY_CURRENCY_CODE = 'INR';
const PAYPAL_CURRENCY_CODE = 'USD';
const STRIPE_CURRENCY_CODE = 'INR';
const STRIPE_MERCHANT_COUNTRY_CODE = 'IN';
```

### 5.2 Android Configuration

| File | Purpose | Action |
|------|---------|--------|
| `android/app/google-services.json` | Firebase config | Replace with your file |
| `android/app/src/main/AndroidManifest.xml` | Permissions & API keys | Configure Google Maps key |
| `android/app/build.gradle` | Build configuration | Update applicationId |
| `android/app/src/main/res/values/strings.xml` | Google Maps API key | Add key |

### 5.3 iOS Configuration

| File | Purpose | Action |
|------|---------|--------|
| `ios/Runner/GoogleService-Info.plist` | Firebase config | Replace with your file |
| `ios/Runner/Info.plist` | Permissions & keys | Configure all required |
| `ios/Runner/AppDelegate.swift` | Google Maps init | Add API key |

### 5.4 Firebase Console Setup

- [ ] Create Firebase project
- [ ] Add Android app (package name)
- [ ] Add iOS app (bundle ID)
- [ ] Enable Authentication (Email/Password)
- [ ] Create Firestore database
- [ ] Configure Firestore rules
- [ ] Enable Storage
- [ ] Configure Storage rules
- [ ] Enable Cloud Messaging
- [ ] Generate FCM server key
- [ ] Configure APNs for iOS

---

## 📊 6. DEVELOPMENT PHASE MILESTONES

### Phase 1: Backend Setup & Integration (Week 1-2)

- [ ] Set up production backend server
- [ ] Configure DOMAIN_URL in app
- [ ] Verify all API endpoints working
- [ ] Set up Firebase project and configure
- [ ] Test authentication flow
- [ ] Test push notifications

### Phase 2: Payment Integration (Week 2-3)

- [ ] Configure payment gateways in admin panel
- [ ] Test Stripe integration
- [ ] Test Razorpay integration (if applicable)
- [ ] Test PayPal integration
- [ ] Test other regional gateways
- [ ] Configure webhook endpoints

### Phase 3: Feature Verification (Week 3-4)

- [ ] Test complete booking workflow
- [ ] Test service management
- [ ] Test handyman assignment
- [ ] Test chat functionality
- [ ] Test subscription system
- [ ] Test earnings & reports

### Phase 4: Testing & QA (Week 4-5)

- [ ] Unit testing
- [ ] Integration testing
- [ ] User acceptance testing
- [ ] Performance testing
- [ ] Security audit

### Phase 5: Deployment (Week 5-6)

- [ ] Configure production environment
- [ ] App Store submission preparation
- [ ] Play Store submission preparation
- [ ] Production deployment
- [ ] Monitoring setup

---

## 📝 7. IMPORTANT NOTES

### 7.1 Demo Mode

The app currently has a `DEMO_MODE_ENABLED` flag that provides fallback dummy data when APIs fail. **This must be disabled for production:**

```dart
// In lib/utils/demo_mode.dart
const bool DEMO_MODE_ENABLED = false; // Set to false for production
```

### 7.2 API Response Format

All APIs should return responses in this format:

```json
// Success
{
  "status": true,
  "message": "Success message",
  "data": { ... }
}

// Error
{
  "status": false,
  "message": "Error message"
}
```

### 7.3 Image Upload Handling

- Services support multiple images
- Maximum file size: Check backend configuration
- Supported formats: jpg, jpeg, png, gif, webp
- Chat files: Additional formats (pdf, mp4, mp3)

### 7.4 Localization

The app supports multiple languages:
- English (en) - Default
- Arabic (ar) - RTL
- German (de)
- French (fr)
- Hindi (hi)

Languages can be added by:
1. Creating language file in `lib/locale/`
2. Extending `BaseLanguage` class
3. Adding to supported locales

---

## 🚨 8. CRITICAL ACTION ITEMS

1. **Set DOMAIN_URL** - Update `lib/utils/configs.dart` with production API URL
2. **Firebase Setup** - Create project and add configuration files
3. **Google Maps API Key** - Obtain and configure for both platforms
4. **Payment Gateway Credentials** - Configure in backend admin panel
5. **Push Notification Certificates** - APNs for iOS, FCM for Android
6. **Disable Demo Mode** - Set `DEMO_MODE_ENABLED = false`
7. **Review Security Rules** - Firestore and Storage rules
8. **SSL/TLS** - Ensure all endpoints use HTTPS

---

*Document generated for Wowch Provider App - Development Phase Transition*
