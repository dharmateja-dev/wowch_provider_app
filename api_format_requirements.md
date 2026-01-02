# API Format Requirements Analysis

## 📊 Overview

This document analyzes whether any **NEW APIs** are required or if existing APIs need **format updates** based on the demo data structure used during UI reskinning.

---

## ✅ VERDICT: NO NEW APIs REQUIRED

After thorough analysis, **all APIs used in the application already exist** in the original codebase. The demo data was created to match the existing API response structures.

---

## 📋 API Format Verification

### 1. Authentication APIs ✅ No Changes Needed

| API | Expected Format | Demo Data Matches |
|-----|-----------------|-------------------|
| `POST /login` | `{ "data": UserData }` | ✅ Yes |
| `POST /register` | `RegisterResponse` | ✅ Yes |
| `POST /forgot-password` | `BaseResponseModel` | ✅ Yes |

**Login Response Format (Expected):**
```json
{
  "data": {
    "id": 1,
    "first_name": "John",
    "last_name": "Williams",
    "email": "john@provider.com",
    "user_type": "provider",
    "contact_number": "+1234567890",
    "api_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "status": 1,
    "profile_image": "https://example.com/image.jpg"
  }
}
```

---

### 2. Provider Dashboard API ✅ No Changes Needed

**Endpoint:** `GET /provider-dashboard`

**Expected Response Format:**
```json
{
  "status": true,
  "total_booking": 156,
  "total_service": 12,
  "today_cash": 2450.00,
  "total_cash_in_hand": 15680.50,
  "total_active_handyman": 8,
  "total_revenue": 125000.00,
  "is_email_verified": 1,
  "notification_unread_count": 5,
  "remaining_payout": 8500.00,
  "service": [
    {
      "id": 1,
      "name": "Home Cleaning",
      "category_id": 1,
      "category_name": "Cleaning",
      "price": 75.00,
      "type": "fixed",
      "discount": 10,
      "status": 1,
      "is_featured": 1
    }
  ],
  "handyman": [
    {
      "id": 2,
      "first_name": "John",
      "last_name": "Doe",
      "email": "john@handyman.com",
      "user_type": "handyman",
      "status": 1,
      "handyman_rating": 4.8,
      "is_handyman_available": true
    }
  ],
  "upcomming_booking": [...],
  "commission": {
    "id": 1,
    "name": "Standard Commission",
    "commission": 15,
    "type": "percent",
    "status": 1
  },
  "provider_wallet": {
    "id": 1,
    "title": "Provider Wallet",
    "user_id": 1,
    "amount": 15680.50,
    "status": 1
  },
  "monthly_revenue": {
    "revenueData": [
      {"1": 12500},
      {"2": 15000},
      ...
    ]
  },
  "online_handyman": ["url1", "url2", "url3"],
  "is_subscribed": 1,
  "subscription": {...}
}
```

**Note:** The `monthly_revenue` field uses index-based keys (1-12) for months.

---

### 3. Handyman Dashboard API ✅ No Changes Needed

**Endpoint:** `GET /handyman-dashboard`

**Expected Response Format:**
```json
{
  "status": true,
  "total_booking": 45,
  "today_booking": 3,
  "total_revenue": 25000.00,
  "today_cash": 350.00,
  "total_cash_in_hand": 5000.00,
  "is_handyman_available": 1,
  "completed_booking": 42,
  "is_email_verified": 1,
  "notification_unread_count": 3,
  "upcomming_booking": [...],
  "commission": {
    "id": 1,
    "name": "Handyman Commission",
    "commission": 10,
    "type": "percent",
    "status": 1
  }
}
```

---

### 4. Booking APIs ✅ No Changes Needed

**Key Fields Expected in BookingData:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | int | Booking ID |
| `service_name` | string | Name of the service |
| `service_id` | int | Service reference ID |
| `customer_name` | string | Customer name |
| `customer_id` | int | Customer reference ID |
| `customer_profile_image` | string | Customer avatar URL |
| `provider_id` | int | Provider reference |
| `status` | string | Booking status code |
| `status_label` | string | Human-readable status |
| `date` | string | Booking date (YYYY-MM-DD HH:mm:ss) |
| `address` | string | Service location |
| `visit_type` | string | "on_site" or "online" |
| `amount` | num | Base service amount |
| `total_amount` | num | Final amount after discount |
| `discount` | num | Discount percentage/amount |
| `type` | string | "fixed" or "hourly" |
| `payment_status` | string | "paid" or "pending" |
| `payment_method` | string | Payment method code |
| `quantity` | int | Service quantity |
| `description` | string | Booking description |
| `start_at` | string | Service start time |
| `end_at` | string | Service end time |
| `reason` | string | Cancellation/rejection reason |
| `handyman` | array | Assigned handyman data |
| `shop_info` | object | Shop details (if applicable) |

**Booking Status Values:**
- `pending`
- `accept`
- `on_going`
- `in_progress`
- `hold`
- `cancelled`
- `rejected`
- `failed`
- `completed`
- `pending_approval`
- `waiting`
- `paid`

---

### 5. Service APIs ✅ No Changes Needed

**Expected ServiceData Format:**
```json
{
  "id": 1,
  "name": "Home Cleaning",
  "category_id": 1,
  "category_name": "Cleaning",
  "provider_id": 1,
  "provider_name": "John Provider",
  "price": 75.00,
  "type": "fixed",
  "discount": 10,
  "duration": "02:00",
  "status": 1,
  "description": "Professional home cleaning...",
  "is_featured": 1,
  "total_review": 45,
  "total_rating": 4.8,
  "visit_type": "on_site",
  "attchments": ["url1", "url2"]
}
```

---

### 6. Shop APIs ✅ No Changes Needed

**Expected ShopModel Format:**
```json
{
  "id": 1,
  "name": "Ayush Home Services",
  "address": "65A, Indrapuri, Bhopal",
  "shop_start_time": "9:00 AM",
  "shop_end_time": "6:00 PM",
  "city_name": "Bhopal",
  "state_name": "Madhya Pradesh",
  "country_name": "India",
  "shop_image": [],
  "provider_id": 1,
  "provider_name": "John Williams",
  "services": []
}
```

---

### 7. User/Handyman APIs ✅ No Changes Needed

**Expected UserData Format:**
```json
{
  "id": 2,
  "first_name": "John",
  "last_name": "Doe",
  "username": "johnd",
  "email": "john@handyman.com",
  "user_type": "handyman",
  "contact_number": "91-9876543210",
  "status": 1,
  "display_name": "John Doe",
  "profile_image": "https://...",
  "handyman_rating": 4.8,
  "is_handyman_available": true,
  "is_verified_handyman": 1,
  "handyman_type": "Company",
  "handyman_commission": "60%",
  "created_at": "2023-06-15 10:30:00"
}
```

---

### 8. Payment APIs ✅ No Changes Needed

**Expected PaymentData Format:**
```json
{
  "id": 2001,
  "booking_id": 1004,
  "customer_id": 104,
  "customer_name": "Daniel Green",
  "payment_method": "stripe",
  "payment_status": "paid",
  "txn_id": "TXN_20240115_001",
  "total_amount": 72.25,
  "datetime": "2024-01-15 13:45:00"
}
```

---

### 9. Notification APIs ✅ No Changes Needed

**Expected NotificationData Format:**
```json
{
  "id": "1",
  "read_at": null,
  "created_at": "2 hours ago",
  "profile_image": "https://...",
  "data": {
    "id": 1001,
    "type": "new_booking_received",
    "subject": "New Booking",
    "message": "New booking #4 - Pedro Norris has booked...",
    "notification_type": "booking"
  }
}
```

---

## ⚠️ IMPORTANT: API Field Naming Convention

The backend APIs use **snake_case** naming (e.g., `first_name`, `total_booking`).  
The Flutter app models convert these to **camelCase** during parsing (e.g., `firstName`, `totalBooking`).

**Example:**
```dart
DashboardResponse.fromJson(Map<String, dynamic> json) {
  totalBooking = json['total_booking'];  // snake_case from API
  totalRevenue = json['total_revenue'];
  todayCashAmount = json['today_cash'];
}
```

---

## 🔧 Backend Configuration Checklist

### Required API Response Wrapper
All APIs should return responses in this format:

**Success Response:**
```json
{
  "status": true,
  "message": "Success message",
  "data": { ... }  // or array depending on endpoint
}
```

**Error Response:**
```json
{
  "status": false,
  "message": "Error description"
}
```

### Pagination Response Format
For list APIs:
```json
{
  "status": true,
  "data": [...],
  "pagination": {
    "total": 100,
    "per_page": 25,
    "current_page": 1,
    "last_page": 4
  }
}
```

---

## 📦 Summary

| Category | New APIs Needed | Format Changes Needed |
|----------|-----------------|----------------------|
| Authentication | ❌ No | ❌ No |
| Dashboard | ❌ No | ❌ No |
| Bookings | ❌ No | ❌ No |
| Services | ❌ No | ❌ No |
| Shops | ❌ No | ❌ No |
| Users/Handyman | ❌ No | ❌ No |
| Payments | ❌ No | ❌ No |
| Notifications | ❌ No | ❌ No |
| Wallet | ❌ No | ❌ No |
| Subscriptions | ❌ No | ❌ No |

---

## ✅ Conclusion

**No new APIs are required** and **no format changes are needed** for the existing APIs. The demo data was specifically designed to match the expected API response structures from the original Handyman application.

The backend developer can refer to the model files in `lib/models/` for the exact JSON field names expected by each API endpoint.

### Quick Reference for Backend:
- `lib/models/dashboard_response.dart` - Dashboard API format
- `lib/models/booking_list_response.dart` - Booking list format
- `lib/models/booking_detail_response.dart` - Booking detail format
- `lib/models/service_model.dart` - Service format
- `lib/models/user_data.dart` - User/Handyman format
- `lib/models/shop_model.dart` - Shop format
- `lib/models/payment_list_reasponse.dart` - Payment format
- `lib/models/notification_list_response.dart` - Notification format
