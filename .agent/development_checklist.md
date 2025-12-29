# Development Phase Checklist

Quick reference checklist for moving into the development phase.

## ✅ Pre-Development Checklist

### Backend Configuration
- [ ] Production server deployed and accessible
- [ ] `DOMAIN_URL` updated in `lib/utils/configs.dart`
- [ ] All API endpoints verified and working
- [ ] SSL certificate configured (HTTPS required)
- [ ] CORS configured for mobile app access
- [ ] Database migrations completed
- [ ] Admin panel accessible

### Firebase Setup
- [ ] Firebase project created
- [ ] Android app added with correct package name
- [ ] iOS app added with correct bundle ID
- [ ] `google-services.json` placed in `android/app/`
- [ ] `GoogleService-Info.plist` placed in `ios/Runner/`
- [ ] Email/Password authentication enabled
- [ ] Firestore database created
- [ ] Firestore security rules configured
- [ ] Firebase Storage enabled
- [ ] Storage security rules configured
- [ ] Cloud Messaging enabled
- [ ] FCM server key generated
- [ ] APNs certificate uploaded (for iOS)

### Google Maps
- [ ] Google Cloud Console project created
- [ ] Maps SDK for Android enabled
- [ ] Maps SDK for iOS enabled
- [ ] Places API enabled
- [ ] Geocoding API enabled
- [ ] API key created with proper restrictions
- [ ] API key added to Android `AndroidManifest.xml`
- [ ] API key added to iOS `Info.plist`

### Payment Gateways (Configure in Admin Panel)
- [ ] Stripe: publishable key & secret key
- [ ] Razorpay: key_id & key_secret (if used)
- [ ] PayPal: client_id & secret_key (if used)
- [ ] Other regional gateways configured as needed

### App Configuration Updates
Update `lib/utils/configs.dart`:
```dart
const DOMAIN_URL = "https://your-production-api.com";
const APP_NAME = 'Your App Name';
const INQUIRY_SUPPORT_EMAIL = 'support@yourapp.com';
const HELP_LINE_NUMBER = '+1234567890';
```

### Demo Mode
- [ ] Set `DEMO_MODE_ENABLED = false` in `lib/utils/demo_mode.dart`

---

## 📋 API Verification Checklist

### Authentication
- [ ] Login (`POST /login`)
- [ ] Register (`POST /register`)
- [ ] Logout (`GET /logout`)
- [ ] Forgot Password (`POST /forgot-password`)

### Dashboard
- [ ] Provider Dashboard (`GET /provider-dashboard`)
- [ ] Handyman Dashboard (`GET /handyman-dashboard`)
- [ ] App Configurations (`POST /configurations`)

### Services
- [ ] Service List (`GET /service-list`)
- [ ] Service Detail (`POST /service-detail`)
- [ ] Add/Edit Service (`POST /service-save`)
- [ ] Delete Service (`POST /service-delete/{id}`)
- [ ] Category List (`GET /category-list`)

### Bookings
- [ ] Booking List (`GET /booking-list`)
- [ ] Booking Detail (`POST /booking-detail`)
- [ ] Update Booking (`POST /booking-update`)
- [ ] Booking Status List (`GET /booking-status`)

### Payments
- [ ] Payment Gateways (`GET /payment-gateways`)
- [ ] Payment List (`GET /payment-list`)
- [ ] Wallet Balance (`GET /wallet-balance`)

### Push Notifications
- [ ] Notification triggers from backend
- [ ] FCM topic subscription working
- [ ] Notification click handling

---

## 🔒 Security Checklist

- [ ] JWT token expiration configured (recommended: 24h)
- [ ] API rate limiting enabled
- [ ] Input validation on all endpoints
- [ ] File upload size limits configured
- [ ] Firestore rules restrict unauthorized access
- [ ] Storage rules restrict unauthorized access
- [ ] Admin panel secured with strong credentials
- [ ] Sensitive keys stored securely (not in code)

---

## 📱 Platform-Specific

### Android
- [ ] Package name updated in `build.gradle`
- [ ] Signing keystore generated for release
- [ ] ProGuard rules configured (if needed)
- [ ] Permissions reviewed in `AndroidManifest.xml`

### iOS
- [ ] Bundle identifier updated
- [ ] Signing certificates obtained
- [ ] Required permissions added to `Info.plist`
- [ ] Push notification capability enabled
- [ ] Background modes configured (if needed)

---

## 🧪 Testing Checklist

- [ ] Login/Logout flow
- [ ] Registration with document upload
- [ ] Service creation with images
- [ ] Booking creation and status updates
- [ ] Payment processing (test mode)
- [ ] Chat messaging
- [ ] Push notifications
- [ ] Location tracking
- [ ] Subscription/Plan purchase
- [ ] App works on slow network
- [ ] App handles errors gracefully

---

## 📄 Documentation Reference

Full details available in: `.agent/development_requirements.md`

- Section 1: Complete API list
- Section 2: Third-party integration details
- Section 3: Backend services requirements
- Section 4: Authentication flow
- Section 5: Configuration details
- Section 6: Development milestones
